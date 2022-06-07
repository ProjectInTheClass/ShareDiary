//
//  GroupViewController.swift
//  ShareDiary
//
//  Created by 김현철 on 2022/06/01.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
class GroupViewController: UIViewController {
    
    var cellData: [CellData] = []
    var uid: String? = nil
    var groupRef: CollectionReference? = nil
    var diaryRef: CollectionReference? = nil
    var userRef: CollectionReference? = nil
    let refresh = UIRefreshControl()
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        firebaseInit()
        loadData()
        self.initRefresh()
    }
    
    func firebaseInit() {
        if let user = Auth.auth().currentUser {
            print("current User exist, user = \(user)")
            uid = user.uid
        } else {
            uid = "vqe2pHo1KhONLfFadMwtpBlF37t2"
            print("no current user, set uid = \(uid!)")
        }
        groupRef = Firestore.firestore().collection("groups")
        diaryRef = Firestore.firestore().collection("diaries")
        userRef = Firestore.firestore().collection("users")
    }
    
    func loadData() {
        // get my group
        cellData.removeAll()
        
        groupRef?.whereField("memberId", arrayContains: uid!).getDocuments(completion: { snap, err in
            if let snap = snap {
                for doc in snap.documents {
                    self.diaryRef?.whereField("sharedGroupId", arrayContains: doc.documentID).getDocuments(completion: { snap, err in
                        if let snap = snap {
                            if doc.data()["groupName"] as! String == "Private" {
                                self.cellData.insert(CellData(groupName: doc.data()["groupName"] as! String, diaryCount: snap.count, groupId: doc.documentID), at: 0)
                            } else {
                                self.cellData.append(CellData(groupName: doc.data()["groupName"] as! String, diaryCount: snap.count, groupId: doc.documentID))
                            }
                            self.tableView.reloadData()
                        }
                    })
                }
            } else {
                print("err while getting group = \(err!)");
            }
        })
        
    }
    
    @IBAction func addBtnTabbed(_ sender: Any) {
        let actionSheet = UIAlertController(title: "그룹 추가", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "그룹 생성", style: .default, handler: { action in
            let alert = UIAlertController(title: "그룹 생성", message: nil, preferredStyle: .alert)
            alert.addTextField { field in
                field.placeholder = "그룹 이름을 입력해주세요."
            }
            alert.addAction(UIAlertAction(title: "취소", style: .cancel))
            alert.addAction(UIAlertAction(title: "생성", style: .default, handler: { action in
                if let gname = alert.textFields?.first?.text {
                    if gname != "Private" {
                        let check = UIAlertController(title: "그룹 생성", message: "\(gname) 그룹을 생성합니다.", preferredStyle: .alert)
                        check.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
                        check.addAction(UIAlertAction(title: "생성", style: .default, handler: { action in
                            let newGid = self.groupRef?.document().documentID
                            let newGroup = Group(id: newGid!, groupName: gname, memberId: [self.uid!], inviteCode: "", createdAt: .now)
                            let ret = try? self.groupRef?.addDocument(from: newGroup) {err in
                                if let err = err {
                                    print("err = \(err)")
                                } else {
                                    self.loadData()
                                    let success = UIAlertController(title: "그룹이 생성되었습니다.", message: "", preferredStyle: .alert)
                                    success.addAction(UIAlertAction(title: "확인", style: .cancel))
                                    self.present(success, animated: true)
                                }
                            }
                        }))
                        self.present(check, animated: true)
                    } else {
                        print("생성실패")
                        let fail = UIAlertController(title: "생성 실패", message: "\(gname) 이름으로 그룹을 생성할 수 없습니다.", preferredStyle: .alert)
                        fail.addAction(UIAlertAction(title: "확인", style: .cancel))
                        self.present(fail, animated: true)
                    }
                }
            }))
            self.present(alert, animated: true)
        }))
        
        
        actionSheet.addAction(UIAlertAction(title: "그룹 가입", style: .default, handler: { action in
            let alert = UIAlertController(title: "그룹 가입", message: nil, preferredStyle: .alert)
            alert.addTextField { field in
                field.placeholder = "그룹 코드를 입력해주세요."
            }
            alert.addAction(UIAlertAction(title: "취소", style: .cancel))
            alert.addAction(UIAlertAction(title: "가입", style: .default, handler: { action in
                if let gid = alert.textFields?.first?.text {
                    self.groupRef?.document(gid).getDocument(completion: { snap, err in
                        if let snap = snap, snap.exists {
                            let check = UIAlertController(title: "그룹 가입", message: "\(snap.data()?["groupName"] as! String) 그룹에 가입합니다.", preferredStyle: .alert)
                            check.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
                            check.addAction(UIAlertAction(title: "가입", style: .default, handler: { action in
                                self.groupRef?.document(gid).updateData(["memberId": FieldValue.arrayUnion([self.uid!])], completion: { err in
                                    if let err = err {
                                        print("memberId union failed, err = \(err)")
                                    } else {
                                        self.loadData()
                                    }
                                });
                                
                            }))
                            self.present(check, animated: true)
                        } else {
                            print("가입실패")
                            let fail = UIAlertController(title: "가입 실패", message: "잘못된 그룹 코드입니다.", preferredStyle: .alert)
                            fail.addAction(UIAlertAction(title: "확인", style: .cancel))
                            self.present(fail, animated: true)
                        }
                    })
                }

            }))
            self.present(alert, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(actionSheet, animated: true)
    }
    func showToast(message : String, font: UIFont = UIFont.systemFont(ofSize: 14.0)) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 10.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension GroupViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "groupTableCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = cellData[indexPath.row].groupName
        content.secondaryText = "(\(cellData[indexPath.row].diaryCount))"
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.row == 0 {
            return nil
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "탈퇴") { action, view, completion in
            self.groupRef!.document(self.cellData[indexPath.row].groupId).updateData(["memberId": FieldValue.arrayRemove([self.uid!])])
            self.cellData.remove(at: indexPath.row)
//            // Atomically add a new region to the "regions" array field.
//            washingtonRef.updateData([
//                "regions": FieldValue.arrayUnion(["greater_virginia"])
//            ])
//
//            // Atomically remove a region from the "regions" array field.
//            washingtonRef.updateData([
//                "regions": FieldValue.arrayRemove(["east_coast"])
//            ])
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        let shareAction = UIContextualAction(style: .normal, title: "초대") { action, view, completion in
            var objectsToShare = [String]()
//            if let text = textField.text {
//                objectsToShare.append(text)
//                print("[INFO] textField's Text : ", text)
//            }
            objectsToShare.append(self.cellData[indexPath.row].groupId)
            
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.view
            
//            activityVC.excludedActivityTypes = [.airDrop, .addToReadingList]
            
            self.present(activityVC, animated: true, completion: nil)
            
            completion(true)
        }


//        action.backgroundColor = .white
        

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, shareAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
}



extension GroupViewController {
    
    func initRefresh() {
        refresh.addTarget(self, action: #selector(refreshTable(refresh:)), for: .valueChanged)
        refresh.backgroundColor = UIColor.clear
        self.tableView.refreshControl = refresh
    }
 
    @objc func refreshTable(refresh: UIRefreshControl) {
        print("refreshTable")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.loadData()
//            self.tableView.reloadData()
            refresh.endRefreshing()
        }
    }
 
    //MARK: - UIRefreshControl of ScrollView
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        if(velocity.y < -0.1) {
//            self.refreshTable(refresh: self.refresh)
//        }
//    }
 
}


struct CellData {
    var groupName: String
    var diaryCount: Int
    var groupId: String
}
