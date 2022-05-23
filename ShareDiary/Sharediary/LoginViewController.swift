//
//  LoginViewController.swift
//  ShareDiary
//
//  Created by 박근원 on 2022/05/24.
//

import Foundation
import UIKit

import Firebase
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController{
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    
    
    @IBAction func LoginButton(_ sender: Any) {
        Auth.auth().signIn(withEmail: email.text!, password: password.text!) { (user,error) in
            if user != nil{
                print("Login success!")
            }
            else{
                print("login fail")
            }
        }
    }
    
    @IBAction func SigninButton(_ sender: Any) {
        Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (user,error) in
            if user != nil{
                print("Signin Success")
            }
            else{
                print("Signin Fail")
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
