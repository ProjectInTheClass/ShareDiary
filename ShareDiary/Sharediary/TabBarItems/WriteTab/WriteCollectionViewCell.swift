//
//  WriteCollectionViewCell.swift
//  ShareDiary
//
//  Created by 김현철 on 2022/06/02.
//

import UIKit

class WriteCollectionViewCell: UICollectionViewCell {
    var cornerRadius: CGFloat = 15.0
    @IBOutlet weak var iv: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Apply rounded corners to contentView
        contentView.layer.cornerRadius =  cornerRadius
        contentView.layer.masksToBounds = true
        
        // Set masks to bounds to false to avoid the shadow
        // from being clipped to the corner radius
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false
        
        // Apply a shadow
        layer.shadowRadius = 8.0
        layer.shadowOpacity = 0.10
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 5)
    }
    
//    override func prepareForReuse() {
//        
//    }

}
