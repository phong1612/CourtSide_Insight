//
//  EntryViewController.swift
//  StatsBasket
//
//  Created by Phong Dinh on 4/13/24.
//

import UIKit
import Starscream
import AVFoundation
class EntryViewController: UIViewController, WebSocketDelegate {
    var update: (() -> Void)?
    var number: WebSocket!
    @IBOutlet var control: UISegmentedControl!
    @IBOutlet var attempt1: UITextField!
    @IBOutlet var attempt2: UITextField!
    @IBOutlet var madeshot1: UITextField!
    @IBOutlet var madeshot2: UITextField!
    @IBOutlet var percent1: UITextField!
    @IBOutlet var percent2: UITextField!
    @IBOutlet var screen: UIImageView!
    @IBOutlet var team1: UITextField!
    @IBOutlet var team2: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        control.selectedSegmentIndex = 1
        attempt1.text = "0"
        madeshot1.text = "0"
        percent1.text = "0.0%"
        attempt2.text = "0"
        madeshot2.text = "0"
        percent2.text = "0.0%"
        team1.text = "0"
        team2.text = "0"
        attempt1.textAlignment = .center
        madeshot1.textAlignment = .center
        percent1.textAlignment = .center
        attempt2.textAlignment = .center
        madeshot2.textAlignment = .center
        percent2.textAlignment = .center
        team1.textAlignment = .center
        team2.textAlignment = .center
        team1.isEnabled = false
        team2.isEnabled = false
        attempt1.isEnabled = false
        madeshot1.isEnabled = false
        percent1.isEnabled = false
        attempt2.isEnabled = false
        madeshot2.isEnabled = false
        percent2.isEnabled = false
        navigationItem.setHidesBackButton(true, animated: true)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .done, target: self, action: #selector(tapSignOut))
        
        let alert = UIAlertController(title: "Rules", message: "When playing 2 teams, each team only have 1 chance to shoot the ball. After that, it's the other team's turn.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "This closes alert"), style: .default, handler: {_ in
            self.startServer()
        }))

        self.present(alert, animated: true, completion: nil)
        
    }
    
    func startServer() {
        let data_url = URL(string: "ws://192.168.0.29:6000")!  // WebSocket server address
        number = WebSocket(request: URLRequest(url: data_url))
        number.delegate = self
        number.connect()
    }
    
    @objc func tapSignOut(_sender: UIButton) {
        update?()
        number.disconnect()
        navigationController?.popToRootViewController(animated: true)
        
    }
    @IBAction func tapChange(_sender: UISegmentedControl) {
        if (_sender.selectedSegmentIndex == 0) {
            navigationController?.popViewController(animated: true)
        }
    }
    func websocketDidConnect(socket: WebSocketClient) {
            print("WebSocket connected")
    }
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?){
        print("WebSocket disconnected: \(error?.localizedDescription ?? "Unknown error")")
    }
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
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
                    if let attemptshoot = data["attempt1"] as? String {
                        DispatchQueue.main.async {
                            self.displayAttempt1(attemptshoot: attemptshoot)
                        }
                    }
                    if let attemptshoot = data["attempt2"] as? String {
                        DispatchQueue.main.async {
                            self.displayAttempt2(attemptshoot: attemptshoot)
                        }
                    }
                    if let made = data["made1"] as? String {
                        DispatchQueue.main.async {
                            self.displayMade1(made: made)
                        }
                    }
                    if let made = data["made2"] as? String {
                        DispatchQueue.main.async {
                            self.displayMade2(made: made)
                        }
                    }
                    if let stat = data["stat1"] as? String {
                        DispatchQueue.main.async {
                            self.displayStat1(stat: stat)
                        }
                    }
                    if let stat = data["stat2"] as? String {
                        DispatchQueue.main.async {
                            self.displayStat2(stat: stat)
                        }
                    }
                    if let score = data["team1"] as? String {
                        DispatchQueue.main.async {
                            self.updateTeam1(score: score)
                        }
                    }
                    if let score = data["team2"] as? String {
                        DispatchQueue.main.async {
                            self.updateTeam2(score: score)
                        }
                    }
                }
                default:
                    break
                }
    }
    func displayAttempt1(attemptshoot: String) {
        attempt1.text = attemptshoot
    }
    func displayAttempt2(attemptshoot: String) {
        attempt2.text = attemptshoot
    }
    func displayMade1(made: String) {
        madeshot1.text = made
    }
    func displayMade2(made: String) {
        madeshot2.text = made
    }
    func displayStat1(stat: String) {
        percent1.text = stat + "%"
    }
    func displayStat2(stat: String) {
        percent2.text = stat + "%"
    }
    func updateTeam1(score: String) {
        team1.text = score
    }
    func updateTeam2(score: String) {
        team2.text = score
    }
}
