import json
import websockets
from ultralytics import YOLO
import asyncio
import cv2
import base64
import time

from player import Player
server_url = "http://172.20.10.2:7000/video_feed"
# Server URL

basketball = YOLO("/Users/jasondinh/Desktop/Project_Self/SDP/YOLOV8/BasketballDetect/weights/best.pt")
#number = YOLO("/Users/jasondinh/Desktop/Project_Self/SDP/YOLOV8/SDP_number3/weights/best.pt")

def check(ob1, ob2):
    [x1, y1, i1, j1] = ob1.xyxy
    [x2, y2, i2, j2] = ob2.xyxy
    x1, y1, i1, j1 = int(x1), int(y1), int(i1), int(j1)
    x2, y2, i2, j2 = int(x2), int(y2), int(i2), int(j2)
    if x2 < i1 or i2 < x1 or j1 < y2 or j2 < y1:
        return False
    return True

async def stats(res, count_shoot1, count_shoot2, count_made1, count_made2, z1, z2, check_delay_shoot, check_delay_made, check, s1, s2):
    
    for result in res:
        boxes = result.boxes
        for box in boxes:
            id = int(box.cls[0])
            if basketball.names[id] == 'shoot' and check_delay_shoot == False:
                if check:
                    count_shoot1 += 1
                else:
                    count_shoot2 += 1
                check_delay_shoot = True
                
            if basketball.names[id] == 'made' and check_delay_made == False:
                
                if check:
                    count_made1 += 1
                    s1 += 2
                    check = False
                else:
                    count_made2 += 1
                    s2 += 2
                    check = True
                check_delay_made = True
            
        if count_shoot1 != 0:
            z1 = float(count_made1/count_shoot1) * 100
        if count_shoot2 != 0:
            z2 = float(count_made2/count_shoot2) * 100
    return count_shoot1, count_shoot2, count_made1, count_made2, z1, z2, check_delay_shoot, check_delay_made, check, s1, s2

def intersect(coor, player):
    x1_min, y1_min, x1_max, y1_max = coor[0], coor[1], coor[2], coor[3]
    x2_min, y2_min, x2_max, y2_max = player[0], player[1], player[2], player[3]

    return not (x1_max < x2_min or x2_max < x1_min or y1_max < y2_min or y2_max < y1_min)
async def video_process(websocket):
    #vid = cv2.VideoCapture("Solo.mp4")
    #vid = cv2.VideoCapture(server_url)
    vid = cv2.VideoCapture(0)
    # vid.set(cv2.CAP_PROP_FRAME_WIDTH, 480)  # Set width
    # vid.set(cv2.CAP_PROP_FRAME_HEIGHT, 320) # Set height
    frame_dur = 1/16

    
    #vid.set(cv2.CAP_PROP_FPS, 30)
    if not vid.isOpened():
        exit()
    delay_shoot = 0
    delay_made = 0
    check_delay_shoot = False
    check_delay_made = False
    count_shoot1 = 0
    count_shoot2 = 0
    count_made1 = 0
    count_made2 = 0
    t1_score = 0
    t2_score = 0
    stat = 0
    team1 = True
    z1 = 0.0
    z2 = 0.0
    while vid.isOpened():
        ret, frame = vid.read()
        if not ret:
            break
        
        time_frame_next = time.time() + frame_dur
        res = await asyncio.get_event_loop().run_in_executor(None, basketball.predict, frame)
        #lap = await asyncio.get_event_loop().run_in_executor(None, number.predict, frame)
        if check_delay_shoot:
            if delay_shoot < 60:
                delay_shoot += 1
            else:
                delay_shoot = 0
                check_delay_shoot = False
        if check_delay_made:
            if delay_made < 60:
                delay_made += 1
            else:
                delay_made = 0
                check_delay_made = False
        _, buffer = cv2.imencode('.jpg', frame)
        image_data = base64.b64encode(buffer).decode('utf-8')
        count_shoot1, count_shoot2, count_made1, count_made2, z1, z2, check_delay_shoot, check_delay_made, team1, t1_score, t2_score = await stats(res, count_shoot1, count_shoot2, count_made1, count_made2, z1, z2, check_delay_shoot, check_delay_made, team1, t1_score, t2_score)
        
        if count_shoot1 + count_shoot2 != 0:
            stat = float((count_made1 + count_made2) / (count_shoot1 + count_shoot2) * 100)
        data = {
            'frame': image_data,
            'attempt1': str(count_shoot1),
            'attempt2': str(count_shoot2),
            'attempt': str(count_shoot1 + count_shoot2),
            'made1': str(count_made1),
            'made2': str(count_made2),
            'made': str(count_made1 + count_made2),
            'stat1': str(z1),
            'stat2': str(z2),
            'stat': str(stat),
            'team1': str(t1_score),
            'team2': str(t2_score),
            'team': str(t1_score + t2_score)
        }
        await websocket.send(json.dumps(data))
        while time.time() < time_frame_next:
            if not vid.read()[0]:
                break
start_serv = websockets.serve(video_process, "192.168.0.29", 6000)
asyncio.get_event_loop().run_until_complete(start_serv)
asyncio.get_event_loop().run_forever()
    
