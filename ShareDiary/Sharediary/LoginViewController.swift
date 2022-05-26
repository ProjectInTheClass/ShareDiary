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
                /*let vcName = self.storyboard?.instantiateViewController(withIdentifier: "MainView")
                vcName?.modalPresentationStyle = .fullScreen
                vcName?.modalTransitionStyle = .crossDissolve
                self.present(vcName!, animated: true, completion: nil)*/
            }
            else{
                print("login fail")
                let LoginFailAlert = UIAlertController(title: "알림", message: "존재하지 않는 유저 정보입니다.", preferredStyle: .alert)
                let ok = UIAlertAction(title: "확인", style: .default, handler: nil)
                LoginFailAlert.addAction(ok)
                self.present(LoginFailAlert, animated: true, completion: nil)
            }
            //#TODO login fail reason
        }
    }
    
    @IBAction func SigninButton(_ sender: Any) {
        Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (user,error) in
            if user != nil{
                print("Signin Success")
                let SigninSuccessAlert = UIAlertController(title: "알림", message: "회원가입이 완료되었습니다.", preferredStyle: .alert)
                let ok = UIAlertAction(title: "확인", style: .default, handler: nil)
                SigninSuccessAlert.addAction(ok)
                self.present(SigninSuccessAlert, animated: true, completion: nil)
            }
            else{
                print("Signin Fail")
                let SigninFailAlert = UIAlertController(title: "알림", message: "회원가입에 실패했습니다.", preferredStyle: .alert)
                let ok = UIAlertAction(title: "확인", style: .default, handler: nil)
                SigninFailAlert.addAction(ok)
                self.present(SigninFailAlert, animated: true, completion: nil)
            }
            //#TODO signin fail reason
        }
    }
    
    
    @IBAction func ForgotPassword(_ sender: Any) {
        Auth.auth().sendPasswordReset(withEmail: email.text!){
            (error) in
            if error != nil{
                print("Fail Email")
                let FailEmailAlert = UIAlertController(title: "알림", message: "없는 이메일 주소입니다.", preferredStyle: .alert)
                let ok = UIAlertAction(title: "확인", style: .default, handler: nil)
                FailEmailAlert.addAction(ok)
                self.present(FailEmailAlert, animated: true,completion: nil)
            }
            else{
                print("Send Emial")
                let SendEmailAlert = UIAlertController(title: "알림", message: "이메일을 전송했습니다.", preferredStyle: .alert)
                let ok = UIAlertAction(title: "확인", style: .default, handler: nil)
                SendEmailAlert.addAction(ok)
                self.present(SendEmailAlert, animated: true,completion: nil)
            }
        }
    }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
