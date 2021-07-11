//
//  LMZTableViewCell.swift
//  LMZMoveableCellTableView
//
//  Created by lmz on 2021/7/11.
//

import UIKit

class LMZTableViewCell: UITableViewCell {
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bgView.layer.cornerRadius = 5.0 // 优化
        bgView.layer.masksToBounds = true
 
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
