//
//  WriteViewController.swift
//  ShareDiary
//
//  Created by 김현철 on 2022/06/02.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import BSImagePicker
import Photos
import WSTagsField
class EmojiTextField: UITextField {

       // required for iOS 13
       override var textInputContextIdentifier: String? { "" }

        override var textInputMode: UITextInputMode? {
            for mode in UITextInputMode.activeInputModes {
                if mode.primaryLanguage == "emoji" {
                    return mode
                }
            }
            return nil
        }

    override init(frame: CGRect) {
            super.init(frame: frame)

            commonInit()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)

             commonInit()
        }
//    UITextInputCurrentInputModeDidChange
//    NSNotification.Name.UITextInputCurrentInputModeDidChange
        func commonInit() {
            NotificationCenter.default.addObserver(self, selector: #selector(inputModeDidChange), name: UITextInputMode.currentInputModeDidChangeNotification, object: nil)
        }

        @objc func inputModeDidChange(_ notification: Notification) {
            guard isFirstResponder else {
                return
            }

            DispatchQueue.main.async { [weak self] in
                self?.reloadInputViews()
            }
        }
    
}

class WriteViewController: UIViewController {
    var uid: String? = nil
    var groupRef: CollectionReference? = nil
    var diaryRef: CollectionReference? = nil
    var userRef: CollectionReference? = nil
    var storageRef: StorageReference? = nil
    var saveDiary: Diary? = nil
    
    var ddid: String? = nil
    var images: [UIImage] = []
    var myGroup: [Group] = []
    var loadGroupId: [String] = []
    
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var cv: UICollectionView!
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var tagTextField: UITextField!
    @IBOutlet weak var emojiTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    override func viewDidAppear(_ animated: Bool) {
        
        print("[viewDidAppear]")
        print("ddid = \(ddid)")
        
        if let user = Auth.auth().currentUser {
            print("current User exist, user = \(user)")
            uid = user.uid
        } else {
            uid = "vqe2pHo1KhONLfFadMwtpBlF37t2"
            print("no current user, set uid = \(uid!)")
        }
        self.images.removeAll()
        self.myGroup.removeAll()
        textView.text = ""
        tagTextField.text = ""
        emojiTextField.text = ""
        datePicker.date = .now
        
        if let ddid2 = ddid {
            print("from Home, ddid = \(ddid2)")
            // load diary
            diaryRef?.document(ddid2).getDocument(as: Diary.self, completion: { res in
                switch res {
                case .success(let diary):
                    print("diary: \(diary)")
                    
                    // load images
                    for imgurl in diary.imageUrls {
                        print("imgurl = \(imgurl)")
                        self.storageRef?.child(imgurl).getData(maxSize: 10 * 1024 * 1024, completion: { data, err in
                            if let err = err {
                                print("err while downloading img, err = \(err)")
                            }
                            if let data = data {
                                let img = UIImage(data: data)
                                print("success download, img = \(img)")
                                self.images.append(img!)
                                self.cv.reloadData()
                            }
                        })
                    }
                    
                    // fill other fields
                    self.textView.text = diary.text
                    self.tagTextField.text = diary.tag.joined(separator: ", ")
                    self.emojiTextField.text = diary.emotion
                    self.datePicker.date = diary.date
                    self.loadGroupId = diary.sharedGroupId
                    self.tv.reloadData()
                    
                case .failure(let error):
                    print("Error decoding diary: \(error)")
                }
            })
        }
        self.cv.reloadData()
        // get my group
        groupRef?.whereField("memberId", arrayContains: uid!).getDocuments(completion: { snap, err in
            if let snap = snap {
                for doc in snap.documents {
                    let g = Group(data: doc.data())!
                    if (g.groupName == "Private") {
                        self.myGroup.insert(g, at: 0)
                    } else {
                        self.myGroup.append(g)
                    }
                    self.tv.reloadData()
                }
            }
            
            if let err = err {
                print("err: \(err)")
            }
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("[viewDidDisappear]")
        ddid = nil
    }
//    @IBOutlet weak var keyHeight: NSLayoutConstraint!
//
//    @objc func keyboardWillShow(_ sender: Notification) {
//        if let userInfo:NSDictionary = sender.userInfo as NSDictionary?,
//           let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as? NSValue {
//            let keyboardRectangle = keyboardFrame.cgRectValue
//            let keyboardHeight = keyboardRectangle.height
//            keyHeight.constant = keyboardHeight
//        }
//    }
//
//    @objc func keyboardWillHide(_ sender: Notification) {
//        //우리가 지정한 constaraint
//        keyHeight.constant = 1
//    }
    override func viewDidLoad() {
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        super.viewDidLoad()
        self.tv.allowsMultipleSelection = true
        self.tv.dataSource = self
        self.tv.delegate = self
        
        self.cv.delegate = self
        self.cv.dataSource = self
        self.cv.register(UINib(nibName: "WriteCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WriteCollectionViewCell")
        firebaseInit()
    }
    func firebaseInit() {
        groupRef = Firestore.firestore().collection("groups")
        diaryRef = Firestore.firestore().collection("diaries")
        userRef = Firestore.firestore().collection("users")
        storageRef = Storage.storage().reference(withPath: "images")
    }

    @IBAction func selectBtnTabbed(_ sender: Any) {
        let imagePicker = ImagePickerController()

        presentImagePicker(imagePicker, select: { (asset) in
            // User selected an asset. Do something with it. Perhaps begin processing/upload?
        }, deselect: { (asset) in
            // User deselected an asset. Cancel whatever you did when asset was selected.
        }, cancel: { (assets) in
            // User canceled selection.
        }, finish: { (assets) in
            // User finished selection assets.
            if (assets.count > 5) {
                self.showToast(message: "최대 등록 가능 사진 수는 5개입니다.")
                return;
            }
            self.images.removeAll()
            
            for asset in assets {
                PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: nil) { (image, info) in
                    // Do something with image
                    if let image = image {
                        let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
                        if isDegraded { return }
                        self.images.append(image)
                        self.cv.reloadData()
                    }
                }
            }

        })
    }
    func showToast(message : String, font: UIFont = UIFont.systemFont(ofSize: 14.0)) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 150, y: self.view.frame.size.height/2, width: 300, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 5, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    @IBAction func expandBtnTabbed(_ sender: Any) {
        let sen = sender as! UIButton
        self.tv.isHidden = !self.tv.isHidden
        if (self.tv.isHidden) {
            sen.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        } else {
            sen.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        }
        print("selected: \(self.tv.indexPathsForSelectedRows!)")
    }
    @IBAction func writeBtnTabbed(_ sender: Any) {
        // save diary
        print("writeBtnTabbed")
        if images.count == 0 {
            showToast(message: "이미지를 넣어주세요.")
            return
        }
        if textView.text == "" {
            showToast(message: "내용을 입력해주세요")
            return
        }
        if tagTextField.text == "" {
            showToast(message: "태그를 입력해주세요.")
            return
        }
        if emojiTextField.text == "" {
            showToast(message: "기분을 입력해주세요")
            return
        }

        if let tmp = ddid {
            print("update Diary \(tmp)")
            
            for i in images.count..<5 {
                storageRef?.child("\(tmp)_\(i).jpg").delete(completion: { err in
                    if let err = err {
                        print("error while deleting \(tmp)_\(i).jpg, err = \(err)");
                        
                    } else {
                        print("delete \(tmp)_\(i).jpg success")
                    }
                })
            }
            ddid = tmp
        } else {
            print("new Diary")
            ddid = diaryRef?.document().documentID
        }
        
        // save images
        for (idx, img) in images.enumerated() {
            let meta = StorageMetadata()
            meta.contentType = "image/jpeg"
            storageRef?.child("\(ddid!)_\(idx).jpg").putData(img.jpegData(compressionQuality: 0.5)!, metadata: meta) { meta, err in
                if let err = err {
                    print("err while uploading img,\(self.ddid!)_\(idx).jpg, err = \(err)")
                }
            }
        }
        let newDiary = Diary(id: ddid!, authorId: uid!, date: datePicker.date, tag: tagTextField.text?.components(separatedBy: [",", " ", "#"]).filter{$0 != ""} as! [String], sharedGroupId: self.tv.indexPathsForSelectedRows!.map{myGroup[$0.row].id}, imageUrls: images.enumerated().map{"\(ddid!)_\($0.offset).jpg"}, videoUrls: [], text: textView.text, emotion: emojiTextField.text!)
        
        
            
            
        if let ret = try? diaryRef?.document(ddid!).setData(from: newDiary) {
            print("일기쓰기 성공, ret = \(ret)")
            print("newDiary = \(newDiary)")
//            let success = UIAlertController(title: "일기가 작성되었습니다.", message: "", preferredStyle: .alert)
//            success.addAction(UIAlertAction(title: "확인", style: .cancel))
//            self.present(success, animated: true)
            showToast(message: "일기 쓰기 완료")
        } else {
            print("일기쓰기 실패")
            showToast(message: "일기 쓰기 실패")
        }
        self.view.endEditing(true)

        _ = navigationController?.popToRootViewController(animated: true)
        tabBarController?.selectedIndex = 0
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

extension WriteViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WriteCollectionViewCell", for: indexPath) as? WriteCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.iv.image = self.images[indexPath.row]
        return cell
    }
}

// keyboard down
extension WriteViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touch")
        self.view.endEditing(true)
    }
}


extension WriteViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myGroup.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupTableViewCell", for: indexPath)
        
        let selectedIndexPaths = tableView.indexPathsForSelectedRows
        let rowIsSelected = selectedIndexPaths != nil && selectedIndexPaths!.contains(indexPath)
        cell.accessoryType = rowIsSelected ? .checkmark : .none
        var content = cell.defaultContentConfiguration()
        content.text = myGroup[indexPath.row].groupName
        if (content.text == "Private") {
            cell.accessoryType = .checkmark
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        
        
        if self.loadGroupId.contains(myGroup[indexPath.row].id) {
            cell.accessoryType = .checkmark
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            self.loadGroupId = self.loadGroupId.filter{$0 != myGroup[indexPath.row].id}
        }
        cell.contentConfiguration = content
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .checkmark
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        if (indexPath.row != 0) {
            cell.accessoryType = .none
        } else {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }
}
