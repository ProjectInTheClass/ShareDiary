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

class WriteViewController: UIViewController {
    var uid: String? = nil
    var groupRef: CollectionReference? = nil
    var diaryRef: CollectionReference? = nil
    var userRef: CollectionReference? = nil
    var storageRef: StorageReference? = nil
    var images: [UIImage] = []
    
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var iv: UIImageView!
    @IBOutlet weak var cv: UICollectionView!
//    writeCollectionViewCell
    
    @IBOutlet weak var datePicker: UIDatePicker!
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.tv.delegate = self
//        self.tv.dataSource = self
        self.cv.delegate = self
        self.cv.dataSource = self
        self.cv.register(UINib(nibName: "WriteCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WriteCollectionViewCell")
//        self.cv.register(CloseButtonView.self, forSupplementaryViewOfKind: "close-badge", withReuseIdentifier: "close-badge")
//        self.cv.register( UINib(nibName: String(decribing: WriteCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: "WriteCollectionViewCell")
        // Do any additional setup after loading the view.
        firebaseInit()
//         datePicker.date
        
//        let badgeAnchor = NSCollectionLayoutAnchor(edges: [.top, .trailing], fractionalOffset: CGPoint(x: 0.3, y: -0.3)) // 1
//        let badgeSize = NSCollectionLayoutSize(widthDimension: .absolute(20),
//                                              heightDimension: .absolute(20)) // 2
//        let badge = NSCollectionLayoutSupplementaryItem(
//            layoutSize: badgeSize,
//            elementKind: ItemBadgeSupplementaryViewController.badgeElementKind,
//            containerAnchor: badgeAnchor) // 3
//
//        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25),
//                                             heightDimension: .fractionalHeight(1.0))
//        let item = NSCollectionLayoutItem(layoutSize: itemSize, supplementaryItems: [badge]) // 4
//        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
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
        storageRef = Storage.storage().reference()
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
            print("assets: \(assets)")
            self.images.removeAll()
            for asset in assets {
                PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: nil) { (image, info) in
                    // Do something with image
//                    print(image)
                    if let image = image {
                        self.images.append(image)
                        self.iv.image = image
//                        self.cv.reloadData()
                    }
                }
            }
            self.cv.reloadData()
        })
    }
    @IBAction func expandBtnTabbed(_ sender: Any) {
        self.tv.isHidden = !self.tv.isHidden
        print("self.tv.isHidden = \(self.tv.isHidden)")
    }
    @IBAction func writeBtnTabbed(_ sender: Any) {
        // save diary
        let newDiary = Diary(authorId: self.uid!, date: datePicker.date, tag: [], sharedGroupId: [], imageUrls: [], videoUrls: [], text: "", emotion: "")
        print(newDiary)
        self.cv.reloadData()
        print(self.images)
        // and update and save imges to storage
        
//        for (idx, img) in images.enumerated() {
//            storageRef.
//        }
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
//extension WriteViewController: UITableViewDataSource, UITableViewDelegate {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = self.tv.dequeueReusableCell(withIdentifier: "writeTableViewCell", for: indexPath)
////        var content = cell.defaultContentConfiguration()
////        content.text = cellData[indexPath.row].groupName
////        content.secondaryText = "(\(cellData[indexPath.row].diaryCount))"
////        cell.contentConfiguration = content
//        return cell
//
////        writeTableViewCell
//    }
//
//
//}

extension WriteViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
//        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        return UICollectionViewCell()
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WriteCollectionViewCell", for: indexPath) as? WriteCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.iv.image = self.images[indexPath.row]
        print("indexPath: \(indexPath), cell: \(cell)")
        return cell
    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let itemSpacing: CGFloat = 10 // 가로에서 cell과 cell 사이의 거리
//        let textAreaHeight: CGFloat = 65 // textLabel이 차지하는 높이
//        let width: CGFloat = (collectionView.bounds.width - itemSpacing)/2 // 셀 하나의 너비
//        let height: CGFloat = width * 10/7 + textAreaHeight //셀 하나의 높이
//
//        return CGSize(width: width, height: height)
//        }
    
}



//final class CloseButtonView: UICollectionReusableView {
//    // MARK: View
//    private let button: UIButton = {
//        let button = UIButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setImage(SwiftGenAssets.closeBadge.image, for: .normal)
//        return button
//    }()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        configure()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("Not implemented")
//    }
//}
//
//extension CloseButtonView {
//    func configure() {
//        addSubview(button)
//
//        NSLayoutConstraint.activate([
//            button.centerXAnchor.constraint(equalTo: centerXAnchor),
//            button.centerYAnchor.constraint(equalTo: centerYAnchor)
//        ])
//    }
//}
//func requestCameraPermission(){
//    AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
//        if granted {
//            print("Camera: 권한 허용")
//        } else {
//            print("Camera: 권한 거부")
//        }
//    })
//}
//class EmojiTextField: UITextField {
//
//       // required for iOS 13
//       override var textInputContextIdentifier: String? { "" }
//
//        override var textInputMode: UITextInputMode? {
//            for mode in UITextInputMode.activeInputModes {
//                if mode.primaryLanguage == "emoji" {
//                    return mode
//                }
//            }
//
//            return nil
//        }
//
////    override init(frame: CGRect) {
////            super.init(frame: frame)
////
////            commonInit()
////        }
////
////        required init?(coder: NSCoder) {
////            super.init(coder: coder)
////
////             commonInit()
////        }
//
////        func commonInit() {
////            NotificationCenter.default.addObserver(self, selector: #selector(inputModeDidChange), name: NSNotification.Name.UITextInputCurrentInputModeDidChange, object: nil)
////        }
////
////        @objc func inputModeDidChange(_ notification: Notification) {
////            guard isFirstResponder else {
////                return
////            }
////
////            DispatchQueue.main.async { [weak self] in
////                self?.reloadInputViews()
////            }
////        }
//    }
//extension String {
//    func onlyEmoji() -> String {
//        return self.filter({$0.isEmoji})
//    }
//}
//
//extension Character {
//    var isEmoji: Bool {
//        guard let scalar = unicodeScalars.first else { return false }
//        return scalar.properties.isEmoji && (scalar.value > 0x238C || unicodeScalars.count > 1)
//    }
//}
//struct EmojiContentView: View {
//
//    @State private var text: String = ""
//    @State private var isEmoji: Bool = true
//
//    var body: some View {
//
//        HStack{
//            EmojiTextField(text: $text, placeholder: "Enter emoji", isEmoji: $isEmoji)
//                .onReceive(Just(text), perform: { _ in
//                    // This allow only emoji
//                    self.text = self.text.onlyEmoji()
//                    /*
//                     //This allow only emoji and allow only 3 emoji
//                     self.text = String(self.text.onlyEmoji().prefix(3))
//                     */
//                })
//        }
//    }
//}
