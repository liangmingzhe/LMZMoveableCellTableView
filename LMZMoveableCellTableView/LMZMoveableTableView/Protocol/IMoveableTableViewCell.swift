//
//  IMoveableTableViewCell.swift
//  LMZMoveableCellTableView
//
//  Created by lmz on 2021/7/17.
//

import Foundation
import UIKit

// 将拖动的截图View 增加面向协议，以支持多种Cell
protocol IMoveableTableViewCell {
    var bgView: UIView { get set }
}


//Section 协议
protocol IMoveableItemSection {
    var title: String {get set}
    var height: CGFloat {get set}
    var moveAble: Bool {get set}
    var items: [IMoveableItemDetail] {get set}
}

//Section 类
class MoveableItemSection: IMoveableItemSection {
    var title: String = ""
    var height: CGFloat = 0
    var items: [IMoveableItemDetail] = []
    var moveAble: Bool = true
    
    //初始化
    init(titleString:String, sectionHeight:CGFloat,can move:Bool, cells:[IMoveableItemDetail]) {
        title = titleString
        height = sectionHeight
        moveAble = move
        items = cells
    }
}

//row 协议
protocol IMoveableItemDetail {
    var title: String {get set}         // 主标题
    var detail: String {get set}        // 副标题
    var cellHeight: CGFloat {get set}   // cell 高度
    //根据需要补充...
}

//row 类
class MoveableItemDetail: IMoveableItemDetail {
    
    var title: String = ""
    
    var detail: String = ""
    
    var cellHeight: CGFloat = 0

    //初始化
    init(titleString:String, detailString:String, heigh:CGFloat) {
        title = titleString
        detail = detailString
        cellHeight = heigh
    }
}
