import Foundation
import UIKit

import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

var db: Firestore? = nil
var userCollection: CollectionReference? = nil
var diaryCollection: CollectionReference? = nil
var groupCollection: CollectionReference? = nil

var storage: Storage? = nil

var uid: String? = nil
var groups: [String] = []

var showDiarys: [Diary] = []

var diarysAll: [Diary] = []
var privateDiarys: [Diary] = []

var isPrivate: Bool = false

class HomeViewContoller: UIViewController {
    
    @IBOutlet weak var tagSearchBar: UISearchBar!

    @IBOutlet weak var privateSegment: UISegmentedControl!
    
    @IBOutlet weak var tv: UITableView!
    
    @IBAction func privateSegmentListenr(_ sender: Any) {
        switch privateSegment.selectedSegmentIndex
        {
            case 0:
                isPrivate = false
                showDiarys = diarysAll
                self.tv.reloadData()
                break
            case 1:
                isPrivate = true
                showDiarys = privateDiarys
                self.tv.reloadData()
                break
            default:
                break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        // dload diaroies
        diaryLoad()
    }
    
    func diaryLoad() {
        diaryCollection?.whereField("sharedGroupId", arrayContains: "gUw4ilJm3pJH8dCP7doE").getDocuments(completion: {
            (qs, e) in
            print(qs?.count)
                if let e = e {
                    print(e)
                } else {
                    for document in qs!.documents {
                        diarysAll.append(
                            Diary(authorId: document["authorId"] as! String,
                                  date: Date(),
                                  tag: document["tag"] as! [String],
                                  sharedGroupId: document["sharedGroupId"] as! [String],
                                  imageUrls: document["imageUrls"] as! [String],
                                  videoUrls: document["videoUrls"] as! [String],
                                  text: document["text"] as! String,
                                  emotion: document["emotion"] as! String)
                        )
                    }
                }
            
                for diary in diarysAll {
                    if (diary.authorId == uid) {
                        privateDiarys.append(diary)
                    }
                }
                
                showDiarys = diarysAll
            
                privateDiarys = diarysAll.filter({$0.authorId == uid!})
                
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
//    uid = FirebaseAuth.Auth.auth().currentUser?.uid
    uid = "RZ8Vzj8VyzP4mIOmfpPnCJD6qGY2"
    groupCollection?.whereField("memberId", arrayContains: uid!).getDocuments(){(qs, e) in
        if let e = e {
            print(e)
            groups = []
        } else {
            for document in qs!.documents {
                groups.append(document.documentID)
            }
        }
    }
}



extension HomeViewContoller: UITableViewDelegate, UITableViewDataSource {
    // 셀의 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showDiarys.count
    }
    
    // 각 셀에 대한 설정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: "HomeTableCell", for: indexPath) as! HomeTableCell
        
        let diary = showDiarys[indexPath.row]
        
        cell.commentLabel.text = diary.text
        
        let dateString = diary.date.description
        let endIdx: String.Index = dateString.index(dateString.startIndex, offsetBy: 10)
        cell.dateLabel.text = String(dateString[...endIdx])
        cell.emojiLabel.text = diary.emotion
        cell.tagsLabel.text = diary.tag.reduce("", {$0 + " #" + $1})
        cell.timeLabel.text = "최근" // todo 수정
        
        cell.iv.contentMode = .scaleAspectFit
        
        let imageRef = storage?.reference(withPath: diary.imageUrls[0])
        imageRef?.getData(maxSize: 10 * 1024 * 1024) { data, error in
            if let error = error {
                print(error)
              } else {
                  cell.iv.image = UIImage(data: data!)
              }
        }
        
        userCollection?.whereField("id", isEqualTo: diary.authorId).getDocuments(completion: {(qs, e) in
            if let e = e {
                print(e)
                cell.userNameLabel.text = ""
            } else {
                for document in qs!.documents {
                    cell.userNameLabel.text =  document.data()["username"] as! String
                }
            }
        })
        
        cell.isUserInteractionEnabled = false
        
        return cell
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
        self.tv.reloadData()
    }
}
