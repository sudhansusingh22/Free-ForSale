//
//  DemoCell.swift
//  FoldingCell
//

import UIKit
import FoldingCell

class DemoCell: FoldingCell {
    @IBOutlet weak var closeNumberLabel: UILabel!
    @IBOutlet weak var openNumberLabel: UILabel!
    
    var number: Int = 0 {
        didSet {
            closeNumberLabel.text = String(number)
            openNumberLabel.text = String(number)
        }
    }
    override func awakeFromNib() {
        
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        
        super.awakeFromNib()
    }
    
    override func animationDuration(itemIndex:NSInteger, type:AnimationType)-> NSTimeInterval {
        
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }

}
