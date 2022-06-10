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
import FirebaseCore
import FirebaseFirestoreSwift

class LoginViewController: UIViewController{
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touch")
        self.view.endEditing(true)
    }
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    var name: String!
    
    
    @IBAction func LoginButton(_ sender: Any) {
        Auth.auth().signIn(withEmail: email.text!, password: password.text!) { (user,error) in
            if user != nil{
                if ((Auth.auth().currentUser?.isEmailVerified) != nil){
                    
                    print("Login success!")
                    
                    let storyboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
                    let mainView = storyboard.instantiateInitialViewController()
                    mainView?.modalPresentationStyle = .fullScreen
                    mainView?.modalTransitionStyle = .crossDissolve
                    self.present(mainView!, animated: true, completion: nil)
                    
                    
                }
                else{
                    print("verification error")
                }
            }
            else{
                print("login fail")
                let LoginFailAlert = UIAlertController(title: "알림", message: "존재하지 않는 유저 정보입니다.", preferredStyle: .alert)
                let ok = UIAlertAction(title: "확인", style: .default, handler: nil)
                LoginFailAlert.addAction(ok)
                self.present(LoginFailAlert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func SigninButton(_ sender: Any) {
        Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (user,error) in
            if user != nil{
                Auth.auth().currentUser?.sendEmailVerification(){ error in
                    let EnterNameTextFieldAlert = UIAlertController(title: "이름 입력", message: "앱 내에서 보여질 이름을 정해주세요. 입력을 완료하시면 인증 이메일을 확인해주세요",preferredStyle: .alert)
                    EnterNameTextFieldAlert.addTextField{ (NameTextField) in
                        NameTextField.placeholder="이름 입력"
                        
                    }
                    let okToEnterName = UIAlertAction(title: "확인", style: .default){ (ok) in
                        self.name = EnterNameTextFieldAlert.textFields?[0].text
                        let DB = Firestore.firestore()
                        let Current_User = Auth.auth().currentUser
                    
                        if self.name != nil{
                            DB.collection("users").document(Current_User!.uid).setData(
                                ["id" : Current_User!.uid,
                                "useremail" : self.email.text!,
                                "username" : self.name!,
                                "blockedUserId" : [],
                                ])
                            let newGid = DB.collection("groups").document().documentID

                            DB.collection("groups").document(newGid).setData(
                                ["id": newGid,
                                 "groupName": "Private",
                                 "memberId": [Current_User!.uid],
                                 "inviteCode": " ",
                                 "createdAt": Date.now,
                                ])
                           
                        }
                    }
                    EnterNameTextFieldAlert.addAction(okToEnterName)
                        
                    self.present(EnterNameTextFieldAlert, animated: true, completion: nil)
                    
                    
                }
            }
            else{
                print("Signin Fail")
                let SigninFailAlert = UIAlertController(title: "알림", message: "회원가입에 실패했습니다.", preferredStyle: .alert)
                let ok = UIAlertAction(title: "확인", style: .default, handler: nil)
                SigninFailAlert.addAction(ok)
                self.present(SigninFailAlert, animated: true, completion: nil)
            }
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


