import Foundation
import UIKit

import ImageSlideshow

class HomeTableCell: UITableViewCell {
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    
    @IBOutlet weak var imageSlideShow: ImageSlideshow!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
