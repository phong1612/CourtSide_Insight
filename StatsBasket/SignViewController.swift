//
//  SignViewController.swift
//  StatsBasket
//
//  Created by Phong Dinh on 4/13/24.
//

import UIKit

class SignViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var user: UITextField!
    @IBOutlet var pass: UITextField!
    @IBOutlet var confirm: UITextField!
    private var popup = false
    var update: (() -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Sign Up"
        user.delegate = self
        pass.delegate = self
        confirm.delegate = self
        //navigationItem.setHidesBackButton(true, animated: true)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(back))
        // Do any additional setup after loading the view.
    }
    @objc func back() {
        update?()
        navigationController?.popViewController(animated: true)
    }
    @IBAction func tapSignUp(_ sender: UIButton) {
        var check = true
        guard let count = UserDefaults().value(forKey: "count") as? Int else {
            return
        }
        let username = user.text!
        let password = pass.text!
        let confirmation = confirm.text!
        if(username == "" || password == "" || confirmation == "") {
            showemp()
        }
        if(confirmation != password) {
            showdif()
        }
        else {
            for i in 0..<count {
                guard let UserAccount = UserDefaults().value(forKey: "account_\(i + 1)") as? [String] else {
                    return
                }
                if(UserAccount.contains(username)) {
                    user.text = ""
                    pass.text = ""
                    confirm.text = ""
                    let alert = UIAlertController(title: "Invalid", message: "Your username already existed", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "This closes alert"), style: .default, handler: .none))

                            // This part of code inits alert view
                    self.present(alert, animated: true, completion: nil)
                    check = false
                    break
                }
            }
        }
        
        guard let count = UserDefaults().value(forKey: "count") as? Int else {
            return
        }
        if(password == confirmation && password != "" && check) {
            UserDefaults().set(count + 1, forKey: "count")
            UserDefaults().set([username, password], forKey: "account_\(count + 1)")
            update?()
            navigationController?.popViewController(animated: true)
            let alert = UIAlertController(title: "Confirmed", message: "Your account has been registered", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "This closes alert"), style: .default, handler: .none))

                    // This part of code inits alert view
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    
    func showdif() {
        let alert = UIAlertController(title: "Invalid", message: "Your confirmation password is different from your password", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "This closes alert"), style: .default, handler: .none))

                // This part of code inits alert view
        self.present(alert, animated: true, completion: nil)
        
    }
    func showemp() {
        let alert = UIAlertController(title: "Empty!", message: "Your username or password or password confirmation is empty", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "This closes alert"), style: .default, handler: .none))

                // This part of code inits alert view
        self.present(alert, animated: true, completion: nil)
    }
}
