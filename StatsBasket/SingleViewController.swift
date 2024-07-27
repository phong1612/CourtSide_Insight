//
//  SingleViewController.swift
//  StatsBasket
//
//  Created by Phong Dinh on 5/1/24.
//

import UIKit
import Starscream
import AVFoundation
class SingleViewController: UIViewController, WebSocketDelegate {
    
    var check = false
    var update: (() -> Void)?
    var socket: WebSocket!
    @IBOutlet var control: UISegmentedControl!
    @IBOutlet var point: UITextField!
    @IBOutlet var attempt: UITextField!
    @IBOutlet var made: UITextField!
    @IBOutlet var percent: UITextField!
    @IBOutlet var screen: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        control.selectedSegmentIndex = 0
        point.text = "0"
        point.textAlignment = .center
        point.isEnabled = false
        attempt.text = "0"
        attempt.textAlignment = .center
        attempt.isEnabled = false
        made.text = "0"
        made.textAlignment = .center
        made.isEnabled = false
        percent.text = "0.0%"
        percent.textAlignment = .center
        percent.isEnabled = false
        navigationItem.setHidesBackButton(true, animated: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .done, target: self, action: #selector(tapSignOut))
        // Do any additional setup after loading the view.
        
        let alert = UIAlertController(title: "Rules", message: "Please make sure to spend 2 seconds after each shot to maximize accuracy.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "This closes alert"), style: .default, handler: {_ in
            self.startServer()
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    func startServer() {
        let data_url = URL(string: "ws://192.168.0.29:6000")!  // WebSocket server address
        socket = WebSocket(request: URLRequest(url: data_url))
        socket.delegate = self
        socket.connect()
    }
    
    @objc func tapSignOut(_sender: UIButton) {
        update?()
        socket.disconnect()
        navigationController?.popViewController(animated: true)
    }
    
    func signout() {
        update?()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func changeView(_sender: UISegmentedControl) {
        print(_sender.selectedSegmentIndex)
        if(_sender.selectedSegmentIndex == 1) {
            //let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard?.instantiateViewController(identifier: "entry") as! EntryViewController
            guard let username = UserDefaults().value(forKey: "user") as? String else {
                    return
            }
            vc.title = "Hello, " + username + "!"
            vc.update = {
                DispatchQueue.main.async {
                    self.signout()
                }
            }
            socket.disconnect()
            navigationController?.pushViewController(vc, animated: false)
            
        }
        control.selectedSegmentIndex = 0
        //self.viewDidLoad()
    }
    
    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        switch event {
            case .connected(let headers):
                print("WebSocket connected with headers: \(headers)")
            
            case .disconnected(let reason, let code):
                print("WebSocket disconnected with reason: \(reason) and code: \(code)")
            
            case .text(let string):
                if let jsonData = string.data(using: .utf8),
                    let data = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                    // Check if the message contains an image
                    if let encodedFrame = data["frame"] as? String,
                       let imageData = Data(base64Encoded: encodedFrame),
                       let image = UIImage(data: imageData) {
                            DispatchQueue.main.async {
                                self.screen.image = image
                            }
                        }
                    // Check if the message contains text
                    if let attemptshoot = data["attempt"] as? String {
                        DispatchQueue.main.async {
                            self.displayAttempt(attemptshoot: attemptshoot)
                        }
                    }
                    if let shotmade = data["made"] as? String {
                        DispatchQueue.main.async {
                            self.displayMade(shotmade: shotmade)
                        }
                    }
                    if let percentage = data["stat"] as? String {
                        DispatchQueue.main.async {
                            self.displayStat(percentage: percentage)
                        }
                    }
                    if let points = data["team"] as? String {
                        DispatchQueue.main.async {
                            self.displayPoint(points: points)
                        }
                    }
                }
                default:
                    break
                }
    }
    func displayAttempt(attemptshoot: String) {
        attempt.text = attemptshoot
    }
    func displayMade(shotmade: String) {
        made.text = shotmade
    }
    func displayStat(percentage: String) {
        percent.text = percentage + "%"
    }
    func displayPoint(points: String) {
        point.text = points
    }
}
