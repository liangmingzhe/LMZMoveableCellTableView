//
//  LMZTableViewCell.swift
//  LMZMoveableCellTableView
//
//  Created by lmz on 2021/7/11.
//

import UIKit

class LMZTableViewCell: UITableViewCell, IMoveableTableViewCell {
    
    
    @IBOutlet weak var bkgView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!
    
    var bgView = UIView()
    var color = UIColor()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bkgView.layer.cornerRadius = 5.0 // 优化
        bkgView.layer.masksToBounds = true
        bgView = bkgView
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    // 适配数据
    func config(cell: IMoveableItemDetail) {
        title.text = cell.title
        bkgView.backgroundColor = rdColor()
        detail.text = cell.detail
    }
    func rdColor() -> UIColor {
        return UIColor(red: CGFloat(arc4random_uniform(37))/255.0, green: CGFloat(140)/255.0, blue: CGFloat(arc4random_uniform(250))/255.0, alpha: 1)
    }
}
