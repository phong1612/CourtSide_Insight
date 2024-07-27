//
//  ViewController.swift
//  StatsBasket
//
//  Created by Phong Dinh on 3/27/24.
//

import UIKit
class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var signin: UIButton!
    @IBOutlet var signup: UIButton!
    @IBOutlet var user: UITextField!
    @IBOutlet var pass: UITextField!
    var default_user = "JasonDinh"
    var default_pass = "123456"
    var account = [[String]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Sign In"
        user.delegate = self
        pass.delegate = self
        // Do any additional setup after loading the view.
        if(!UserDefaults().bool(forKey: "setup")) {
            UserDefaults().set(true, forKey: "setup")
            UserDefaults().set(1, forKey: "count")
        }
        UserDefaults().set([default_user,default_pass], forKey: "account_1")
        updateTask()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        updateTask()
        return true
    }
    @IBAction func tapSignIn(_ sender: Any) {
        let username = user.text!
        let password = pass.text!
        if(account.contains([username, password])) {
            UserDefaults().set(username, forKey: "user")
            let vc = storyboard?.instantiateViewController(identifier: "single") as! SingleViewController
            vc.title = "Hello, " + username + "!"
            vc.update = {
                DispatchQueue.main.async {
                    self.updateTask()
                }
            }
            navigationController?.pushViewController(vc, animated: true)
        }
        else if(username == "" || password == "") {
            let alert = UIAlertController(title: "Invalid", message: "Your username or password is empty", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "This closes alert"), style: .default, handler: .none))

                    // This part of code inits alert view
            self.present(alert, animated: true, completion: nil)
        }
        else{
            let alert = UIAlertController(title: "Incorrect", message: "Your username or password is incorrect", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "This closes alert"), style: .default, handler: .none))

                    // This part of code inits alert view
            self.present(alert, animated: true, completion: nil)
            self.updateTask()
        }
    }
    @IBAction func tapSignUp(_ sender: Any) {
        let su = storyboard?.instantiateViewController(identifier: "signup") as! SignViewController
        su.title = "New User"
        su.update = {
            DispatchQueue.main.async {
                self.updateTask()
            }
        }
        navigationController?.pushViewController(su, animated: true)
    }
    func updateTask() {
        user.text = ""
        pass.text = ""
        var checkaccount = [[String]]()
        guard let count = UserDefaults().value(forKey: "count") as? Int else {
            return
        }
        for i in 0..<count {
            if let acc = UserDefaults().value(forKey: "account_\(i + 1)") as? [String] {
                checkaccount.append(acc)
            }
        }
        
        for acc in checkaccount {
            var check = false
            for i in account {
                if i.contains(acc[0]) {
                    check = true
                    break
                }
            }
            if !check {
                account.append(acc)
            }
        }
        UserDefaults().set(account.count, forKey: "count")
        for i in 0..<account.count {
            UserDefaults().set(account[i], forKey: "account_\(i + 1)")
        }
    }
}

