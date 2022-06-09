//
//  OptionViewController.swift
//  ShareDiary
//
//  Created by 박근원 on 2022/06/08.
//

import Foundation
import UIKit

import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift


class OptionViewController: UIViewController{
    
    @IBOutlet weak var Current_User_Label: UILabel!
    
    override func viewDidLoad() {
        Current_User_Label.text = Auth.auth().currentUser?.email
    }
    @IBAction func LogOutButton(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            let storyboard: UIStoryboard = UIStoryboard(name: "Login",bundle: nil)
            let LoginView = storyboard.instantiateInitialViewController()
            LoginView?.modalPresentationStyle = .fullScreen
            LoginView?.modalTransitionStyle = .crossDissolve
            self.present(LoginView!, animated: true, completion: nil)
            
        } catch{
            print(error.localizedDescription)
            print("Logout Error!")
        }
    }
    @IBAction func WithdrawalButton(_ sender: Any) {
        let WithdrawlCheck = UIAlertController(title: "알림", message: "정말 회원 탈퇴 하시겠습니까?", preferredStyle: .alert)
        let delete = UIAlertAction(title: "취소",style: .default, handler: nil)
        let ok = UIAlertAction(title: "확인", style: .default){ (ok) in
            let Current_User = Auth.auth().currentUser
            let DB = Firestore.firestore()
            
            DB.collection("users").document(Current_User!.uid).delete()
           
            Current_User?.delete(){ (error) in
                if error != nil{
                    print("Signout Error!")
                }
                else{
                    let storyboard: UIStoryboard = UIStoryboard(name: "Login",bundle: nil)
                    let LoginView = storyboard.instantiateInitialViewController()
                    LoginView?.modalPresentationStyle = .fullScreen
                    LoginView?.modalTransitionStyle = .crossDissolve
                    self.present(LoginView!, animated: true, completion: nil)
                    
                    let AccountDeletedAlert = UIAlertController(title: "알림", message: "회원 탈퇴했습니다.", preferredStyle: .alert)
                    let okDelete = UIAlertAction(title: "확인", style: .default,handler: nil)
                    AccountDeletedAlert.addAction(okDelete)
                    self.present(AccountDeletedAlert,animated: true,completion: nil)
                    
                }
                
            }
            
            
        }
        WithdrawlCheck.addAction(ok)
        WithdrawlCheck.addAction(delete)
        self.present(WithdrawlCheck, animated: true, completion: nil)
    }
    
}
