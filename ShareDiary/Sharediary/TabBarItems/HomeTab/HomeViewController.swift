import Foundation
import UIKit

import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

import ImageSlideshow
import ImageSlideshowAlamofire

import FINNBottomSheet
import simd

var db: Firestore? = nil
var userCollection: CollectionReference? = nil
var diaryCollection: CollectionReference? = nil
var groupCollection: CollectionReference? = nil

var storage: Storage? = nil

var uid: String? = nil
var blockedUid: [String] = []

var groups: [String] = []
var groupsName: [String] = []

var selectedGroups: [String] = []

var showDiarys: [Diary] = []

var diarysAll: [Diary] = []
var selectedDiarys: [Diary] = []
var privateDiarys: [Diary] = []

var isPrivate: Bool = false

var loadCnt = 0

class HomeViewContoller: UIViewController, ImageSlideshowDelegate {
    
    @IBOutlet weak var tagSearchBar: UISearchBar!

    @IBOutlet weak var privateSegment: UISegmentedControl!
    
    @IBOutlet weak var tv: UITableView!
    
    @IBAction func groupViewClicked(_ sender: UIButton) {
        var pickerData : [[String:String]] = []
        
        if(groups.count < 1) {
            return
        }
        
        for i in 0...(groups.count - 1) {
            pickerData.append([
                "value": groups[i],
                "display": groupsName[i]
            ])
        }
                
        MultiPickerDialog().show(title: "그룹 선택",doneButtonTitle:"선택 완료", cancelButtonTitle:"취소" ,options: pickerData, selected:  selectedGroups) {
                    values -> Void in
                    //print("SELECTED \(value), \(showName)")
                    print("callBack \(values)")
                    var finalText = ""
                    selectedGroups.removeAll()
            
                    for (index,value) in values.enumerated(){
                        selectedGroups.append(value["value"]!)
                        finalText = finalText  + value["display"]! + (index < values.count - 1 ? " , ": "")
                        print(finalText)
                    }
            
                    sender.titleLabel?.text = finalText
            
            selectedDiarys = diarysAll.filter({(d: Diary) in selectedGroups.contains(where: {(gid: String) in d.sharedGroupId.contains(where: {$0 == gid})})})
            showDiarys = selectedDiarys
            
            sortShowDiaries()
            
            recentStr = Array.init(repeating: [:], count: showDiarys.count)
            recentName.removeAll()
            self.tv.reloadData()
                }
    }
    
    @IBAction func privateSegmentListenr(_ sender: Any) {
        switch privateSegment.selectedSegmentIndex
        {
            case 0:
                isPrivate = false
                showDiarys = selectedDiarys
                sortShowDiaries()
            recentStr = Array.init(repeating: [:], count: showDiarys.count)
            recentName.removeAll()
                self.tv.reloadData()
                break
            case 1:
                isPrivate = true
                showDiarys = privateDiarys
                sortShowDiaries()
            recentName.removeAll()
            recentStr = Array.init(repeating: [:], count: showDiarys.count)
                self.tv.reloadData()
                break
            default:
                break
        }
    }
    
    override func viewDidLoad() {
        
        loadCnt += 1
        
        print("viewDidLoad")
        
        // firestore load
        firebaseLoad()
        
        // 셀 리소스 파일 가져오기
        let myTableViewCellNib = UINib(nibName: String(describing: HomeTableCell.self), bundle: nil)
        
        // 셀에 리소스 등록
        self.tv.register(myTableViewCellNib, forCellReuseIdentifier: "HomeTableCell")
        
        // 셀 크기 설정
        self.tv.rowHeight = 519
//        self.tv.estimatedRowHeight = 500
        
        // delegate 연결
        self.tv.delegate = self
        self.tv.dataSource = self
        self.tagSearchBar.delegate = self
        self.tagSearchBar.placeholder = "태그를 입력해 주세요."
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (loadCnt == 1) {
            loadCnt += 1
            return
        }
        loadCnt += 1

        print("viewWillAppear")

        groups = []
        groupsName = []

        selectedGroups = []

        diarysAll = []
        selectedDiarys = []
        privateDiarys = []

        isPrivate = false
        
        // firestore load
        firebaseLoad()

        self.tagSearchBar.placeholder = "태그를 입력해 주세요."
    }

func diaryLoad() {
    if(groups.count < 1) {
        return
    }
    print("blocked!!")
    print(blockedUid)
        for i in 0...(groups.count - 1) {
            diaryCollection?.whereField("sharedGroupId", arrayContains: groups[i]).getDocuments(completion: {
                (qs, e) in
                    if let e = e {
                        print(e)
                    } else {
//                        (document["date"] as! Timestamp).
                        
                        for document in qs!.documents {
                            if (!diarysAll.contains(where: {$0.id == document["id"] as! String}) && !blockedUid.contains(document["authorId"] as! String)) {
                                diarysAll.append(
                                    Diary(
                                        id: document["id"] as! String,
                                            authorId: document["authorId"] as! String,
                                        date: Date(timeIntervalSince1970: TimeInterval((document["date"] as! Timestamp).seconds)),
                                          tag: document["tag"] as! [String],
                                          sharedGroupId: document["sharedGroupId"] as! [String],
                                          imageUrls: document["imageUrls"] as! [String],
                                          videoUrls: document["videoUrls"] as! [String],
                                          text: document["text"] as! String,
                                          emotion: document["emotion"] as! String)
                                )
                            }
                        }
                    }
                
                    for diary in diarysAll {
                        if (diary.authorId == uid) {
                            privateDiarys.append(diary)
                        }
                    }
                    
                
                
                selectedDiarys = diarysAll
                showDiarys = selectedDiarys
                    privateDiarys = diarysAll.filter({$0.authorId == uid!})
                    
                    sortShowDiaries()
                recentStr = Array.init(repeating: [:], count: showDiarys.count)
                recentName.removeAll()
                    self.tv.reloadData()
                }
            )
        }
    }
    
    
    func firebaseLoad() {
        db = Firestore.firestore()
        
        storage = Storage.storage()
        
        userCollection = db!.collection("users")
        diaryCollection = db!.collection("diaries")
        groupCollection = db!.collection("groups")
        
        //todo auth 연결 후 다시 적용
        uid = FirebaseAuth.Auth.auth().currentUser?.uid
        if (uid == nil) {
            uid = "vqe2pHo1KhONLfFadMwtpBlF37t2"
        }
        
        groupCollection?.whereField("memberId", arrayContains: uid!).getDocuments(){(qs, e) in
            if let e = e {
                print(e)
                groups = []
            } else {
                print(qs!.documents.count)
                for document in qs!.documents {
                    groups.append(document.documentID)
                    groupsName.append(document.data()["groupName"] as! String)
                }
            }
            
            blockedUid.removeAll()
            userCollection?.whereField("id", isEqualTo: uid!).getDocuments(completion: {(qs, e) in
                if let e = e {
                    print(e)
                } else {
                    for document in qs!.documents {
                        let tmp: [String] = document.data()["blockedUserId"] as! [String]
                        for i in tmp {
                            blockedUid.append(i)
                        }
                    }
                }
            })
            
            self.diaryLoad()
        }


    }
    
    func addBlockUser(id: String) {
        userCollection?.whereField("id", isEqualTo: uid!).getDocuments(){(qs, e) in
            if let e = e {
                print(e)
                groups = []
            } else {
                for document in qs!.documents {
                    document.reference.updateData([
                        "blockedUserId": FieldValue.arrayUnion([id])
                    ])
                }
            }
        }
    }
    
}


var recentStr : [[Int:String]] = []
var recentName : [Int:String] = [:]

extension HomeViewContoller: UITableViewDelegate, UITableViewDataSource {
    // 셀의 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showDiarys.count
    }
    

    
    // 각 셀에 대한 설정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: "HomeTableCell", for: indexPath) as! HomeTableCell
        
        let diary = showDiarys[indexPath.row]
        
        var flag1 = false
        var flag2 = false
        
        print("!!!!!" + diary.text)
        
        cell.imageSlideShow.setImageInputs([])
//        print(String(indexPath.row) + "images are")
//        print(cell.imageSlideShow.images)
        
        var cnt = 0
        
        for i in diary.imageUrls {
            var str = i
            if (!i.starts(with: "images/")){
                str = "images/" + i;
            }
            
            recentStr[indexPath.row][cnt] = str
            cnt += 1
            
            storage?.reference(withPath: str).downloadURL() { (url, error) in
//                if (cell.imageSlideShow.images.count >= diary.imageUrls.count) {
//                    print("cell.imageSlideShow.images.count >= diary.imageUrls.count")
//                    cell.imageSlideShow.setImageInputs(cell.imageSlideShow.images)
//                    return
//                }
                
                if (!flag1) {
                    flag1 = true
                    cell.imageSlideShow.setImageInputs([])
//                    print("flag is now true")
                }
                
                if(!recentStr[indexPath.row].contains(where: {$1 == str})){
                    return
                }
                
                if(url != nil) {
//                    print("url != nil")
                    cell.imageSlideShow.setImageInputs(cell.imageSlideShow.images + [AlamofireSource(url: url!)])
                } else {
//                    print("url == nil !!!!!!!!!!!!!!!!!")
                }
            }
        }
        
        cell.commentLabel.text = diary.text
        
        let dateString = diary.date.description.localizedLowercase
//        print(diary.text)
//        print(dateString)
        let endIdx: String.Index = dateString.index(dateString.startIndex, offsetBy: 10)
        cell.dateLabel.text = String(dateString[...endIdx])
        cell.emojiLabel.text = diary.emotion
//        print(diary.emotion)
        cell.tagsLabel.text = diary.tag.reduce("", {$0 + " #" + $1})
//        print(diary.tag.reduce("", {$0 + " #" + $1}))
        cell.timeLabel.text = "최근" // todo 수정
        
        cell.imageSlideShow.slideshowInterval = 2.0
        
        cell.imageSlideShow.activityIndicator = DefaultActivityIndicator()
        cell.imageSlideShow.delegate = self
        
//        print(diary.text)
//        print(diary.imageUrls)
        
        
        recentName[indexPath.row] = diary.authorId
        
        userCollection?.whereField("id", isEqualTo: diary.authorId).getDocuments(completion: {(qs, e) in
//            print("diary.authorId is " + diary.authorId)
            
            if (!flag2) {
                flag2 = true
            } else {
                return
            }
            
            if (diary.authorId != recentName[indexPath.row]) {
                return
            }
            
            if let e = e {
                print(e)
                cell.userNameLabel.text = ""
            } else {
                for document in qs!.documents {
//                    print("username is " + (document.data()["username"] as! String))
                    cell.userNameLabel.text =  document.data()["username"] as! String
                }
            }
        })
        

    
//        let imageRef = storage?.reference(withPath: diary.imageUrls[0])
//        imageRef?.getData(maxSize: 10 * 1024 * 1024) { data, error in
//            if let error = error {
//                print(error)
//              } else {
//                  cell.imageSlideShow.setImageInputs(storage?.reference(withPath: ))
//              }
//        }
        
        cell.isUserInteractionEnabled = false
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if showDiarys[indexPath.row].authorId == uid {
            let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { action, view, completion in
                diaryCollection?.document(showDiarys[indexPath.row].id).delete();
                
                showDiarys.remove(at: indexPath.row)
                selectedDiarys.remove(at: indexPath.row)

                tableView.deleteRows(at: [indexPath], with: .automatic)
                
                completion(true)
            }

            let editAction = UIContextualAction(style: .normal, title: "수정") { action, view, completion in
                let storyboard: UIStoryboard = UIStoryboard(name: "WriteTab",bundle: nil)
                guard let secondViewController = storyboard.instantiateViewController(withIdentifier: "WriteTab") as? WriteViewController else { return }
                
                // 화면 전환 애니메이션 설정
                secondViewController.modalTransitionStyle = .coverVertical
        
                // 전환된 화면이 보여지는 방법 설정 (fullScreen)
                secondViewController.modalPresentationStyle = .fullScreen
                
                secondViewController.ddid = showDiarys[indexPath.row].id
                
                self.navigationController?.pushViewController(secondViewController, animated: true)
                
                completion(true)
            }

            let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
            configuration.performsFirstActionWithFullSwipe = false

            return configuration
        } else {
            let blockAction = UIContextualAction(style: .destructive, title: "차단") { action, view, completion in
                // 유저 차단
                self.addBlockUser(id: showDiarys[indexPath.row].authorId)

                showDiarys.remove(at: indexPath.row)
                selectedDiarys.remove(at: indexPath.row)

                tableView.deleteRows(at: [indexPath], with: .automatic)

                completion(true)
            }

            let configuration = UISwipeActionsConfiguration(actions: [blockAction])
            configuration.performsFirstActionWithFullSwipe = false

            return configuration
        }
    }
    
}

extension HomeViewContoller: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let tag : String = searchBar.text!
        if (isPrivate) {
            showDiarys = privateDiarys.filter({$0.tag.contains(where: {$0.contains(tag)})})
            
            if (tag == "") {
                showDiarys = privateDiarys
            }
        } else {
            showDiarys = diarysAll.filter({$0.tag.contains(where: {$0.contains(tag)})})
            
            if (tag == "") {
                showDiarys = diarysAll
            }
        }
        self.tagSearchBar.resignFirstResponder()
        
        sortShowDiaries()
        
        recentStr = Array.init(repeating: [:], count: showDiarys.count)
        recentName.removeAll()
        self.tv.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.tagSearchBar.resignFirstResponder()
    }
}

func sortShowDiaries() {
    showDiarys = showDiarys.sorted(by: {$0.date > $1.date})
//    showDiarys = showDiarys.reversed()
}


