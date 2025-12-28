//
//  LMZMoveableTableView.swift
//  LMZIntelligentTableView
//
//  Created by mac on 2021/7/7.
//

import UIKit
protocol LMZMovableCellTableViewDataSource : UITableViewDataSource {
    func dataSourceArrayInTableView(tableView:LMZMoveableTableView) -> [IMoveableItemSection]
    func snapshotViewWithCell(cell:IMoveableTableViewCell) -> UIView
    
}


@objc protocol LMZMovableCellTableViewDelegate : UITableViewDelegate {
    @objc optional func tableView(_ tableView: LMZMoveableTableView, willMoveCellAtIndexPath indexPath: IndexPath)
    @objc optional func tableView(_ tableView: LMZMoveableTableView, tryMoveUnmovableCellAtIndexPath indexPath: IndexPath)
    @objc optional func tableView(_ tableView: LMZMoveableTableView, didMoveCellFromIndexPath indexPath: IndexPath)
    @objc optional func tableView(_ tableView: LMZMoveableTableView, endMoveCellAtIndexPath indexPath: IndexPath)
    @objc optional func tableView(_ tableView: LMZMoveableTableView, customizeMovalbeCell movableCellsnapshot: UIImageView)
    @objc optional func tableView(_ tableView: LMZMoveableTableView, customizeStartMovingAnimation movableCellsnapshot: UIImageView, fingerPoint point:CGPoint)
    
}

class LMZMoveableTableView: UITableView {

    var longPressGesture : UILongPressGestureRecognizer?
    var selectedIndexPath : IndexPath?
    var canHintWhenCannotMove:Bool = true
    var canEdgeScroll:Bool = true
    var edgeScrollLink:CADisplayLink?
    var edgeScrollTriggerRange:CGFloat = 150.0
    var currentScrollSpeedPerFrame:CGFloat = 0
    var snapshot = UIImageView()
    var maxScrollSpeedPerFrame:CGFloat = 20
    var canFeedback = false
    var generator = UIImpactFeedbackGenerator()
    var tempDataSource:[IMoveableItemSection] = []
    weak open var lmz_dataSource: LMZMovableCellTableViewDataSource?
    weak open var lmz_delegate: LMZMovableCellTableViewDelegate?
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        if #available(iOS 10.0, *) {
            generator = UIImpactFeedbackGenerator(style: .light)
        }
        
        lmz_initData()
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(lmz_processGesture(gesture:)))
        longPressGesture?.minimumPressDuration = 0.5
        self.addGestureRecognizer(longPressGesture!)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil {
            self.lmz_stopEdgeScroll()
        }
    }
    
    func lmz_initData() {

    }
    
    func lmz_addGesture() {
        
    }
    
    
    //长按手势
    @objc func lmz_processGesture(gesture:UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            lmz_gestureBegan(gesture: gesture)
            print("touch began..")
            break
        case .changed:
            lmz_gestureChanged(gesture: gesture)
            print("touch change..")
            break
        case .cancelled,.ended:
            lmz_gestureEndedOrCancelled(gesture: gesture)
            print("touch end..")
        default:
            break
        }
    }
    
    //手势开始
    func lmz_gestureBegan(gesture:UILongPressGestureRecognizer) {
        let point = gesture.location(in: gesture.view)
        
        // 检查是否点击在有效的 cell 上，如果不是则直接返回
        guard let selectedIndex = self.indexPathForRow(at: point) else {
            return
        }
        
        guard let cell = self.cellForRow(at: selectedIndex) else {
            return
        }
        
        //Get a data source every time you move
        if let dataSource = self.lmz_dataSource?.dataSourceArrayInTableView(tableView: self) {
            tempDataSource = dataSource
        } else {
            return
        }
        
        if self.lmz_dataSource?.tableView?(self, canMoveRowAt: selectedIndex) == false {
            if canHintWhenCannotMove {
                /*...*/
                let shakeAnimation : CAKeyframeAnimation = CAKeyframeAnimation(keyPath: "transform.translation.x")
                shakeAnimation.duration = 0.25;
                shakeAnimation.values = [-20, 20, -10, 10, 0];
                cell.layer.add(shakeAnimation, forKey: "shake")
                
            }

            self.lmz_delegate?.tableView?(self, tryMoveUnmovableCellAtIndexPath: selectedIndex)
            
            return
        }

        self.lmz_delegate?.tableView?(self, willMoveCellAtIndexPath: selectedIndex)
        
        if canEdgeScroll {
            self.lmz_startEdgeScroll()
        }
  
        selectedIndexPath = selectedIndex
        if #available(iOS 10.0, *) {
            if canFeedback {
                generator.prepare();
                generator.impactOccurred();
            }
        }
        
        if self.lmz_dataSource != nil {
            // 安全地将cell转换为IMoveableTableViewCell
            guard let moveableCell = cell as? IMoveableTableViewCell,
                  let snapView = self.lmz_dataSource?.snapshotViewWithCell(cell: moveableCell) else {
                return
            }
            snapshot = self.lmz_snapshotViewWithInputView(inputView: snapView)
        } else {
            snapshot = self.lmz_snapshotViewWithInputView(inputView: cell)
        }
        
        if self.lmz_delegate?.tableView?(self, customizeMovalbeCell: snapshot) == nil {
            snapshot.layer.shadowColor = UIColor.gray.cgColor;
            snapshot.layer.masksToBounds = false;
            snapshot.layer.cornerRadius = 0;
            snapshot.layer.shadowOffset = CGSize(width: -5, height: 0);
            snapshot.layer.shadowOpacity = 0.4;
            snapshot.layer.shadowRadius = 5;
        }
        
        snapshot.frame = CGRect(x: (cell.frame.size.width - snapshot.frame.size.width)/2.0,
                                y: cell.frame.origin.y + (cell.frame.size.height - snapshot.frame.size.height)/2.0,
                                width: snapshot.frame.size.width,
                                height: snapshot.frame.size.height)
        self.addSubview(snapshot)
        cell.isHidden = true
        
        if ((self.lmz_delegate?.tableView?(self, customizeStartMovingAnimation: snapshot, fingerPoint: point)) == nil)  {
            UIView.animate(withDuration: 0.25) { [self] in
                snapshot.center = CGPoint(x: snapshot.center.x, y: point.y)
            }
        }
    }
    
    //手势改变
    func lmz_gestureChanged(gesture:UILongPressGestureRecognizer) {
        guard let selectedIndexPath = selectedIndexPath else {
            return
        }
        
        var point: CGPoint = gesture.location(in: gesture.view)
        let limitedY = self.limitSnapshotCenterY(targetY: point.y)
        point = CGPoint(x: snapshot.center.x, y: limitedY)
        
        // Let the screenshot follow the gesture
        snapshot.center = point
        
        // 使用snapshot的center来查找对应的indexPath，更准确
        guard let currentIndexPath: IndexPath = indexPathForRow(at: point) else {
            // 如果找不到indexPath，说明snapshot在边界位置，保持当前位置即可
            return
        }
        
        /*
         不允许不同的section交换
         */
        if currentIndexPath.section >= tempDataSource.count {
            return
        }
        
        if tempDataSource[currentIndexPath.section].moveAble == false {
            return
        }
        
        if selectedIndexPath != currentIndexPath {
            guard let selectedCell: UITableViewCell = self.cellForRow(at: selectedIndexPath) else {
                return
            }
            selectedCell.isHidden = true
            
            if self.lmz_dataSource?.tableView?(self, canMoveRowAt: currentIndexPath) == false {
                return
            }
            
            lmz_updateDataSourceAndCellFromIndexPath(from: selectedIndexPath, to: currentIndexPath)
            
            self.lmz_delegate?.tableView?(self, didMoveCellFromIndexPath: currentIndexPath)
            self.selectedIndexPath = currentIndexPath
        }
    }

    
    func lmz_startEdgeScroll() {
        edgeScrollLink = CADisplayLink.init(target: self, selector: #selector(lmz_processEdgeScroll))
        edgeScrollLink!.add(to: RunLoop.main, forMode: .common)
        
    }
    
    @objc func lmz_processEdgeScroll() {
        guard let gesture = longPressGesture else {
            return
        }
        
        // 使用手势的真实位置来判断是否需要滚动，而不是snapshot.center
        // 这样可以避免因为snapshot被限制导致的判断错误
        let touchPoint: CGPoint = gesture.location(in: self)
        
        // 计算触发边缘滚动的区域，考虑contentInset
        var topInset: CGFloat = 0
        var bottomInset: CGFloat = 0
        if #available(iOS 11.0, *) {
            topInset = self.adjustedContentInset.top
            bottomInset = self.adjustedContentInset.bottom
        } else {
            topInset = self.contentInset.top
            bottomInset = self.contentInset.bottom
        }
        
        let minOffsetY: CGFloat = topInset + edgeScrollTriggerRange
        let maxOffsetY: CGFloat = self.bounds.size.height - bottomInset - edgeScrollTriggerRange
        
        var shouldScroll = false
        var newContentOffsetY: CGFloat = self.contentOffset.y
        
        if touchPoint.y < minOffsetY {
            // Cell is moving up - 向上滚动
            let moveDistance: CGFloat = (minOffsetY - touchPoint.y) / edgeScrollTriggerRange * maxScrollSpeedPerFrame
            currentScrollSpeedPerFrame = moveDistance
            newContentOffsetY = self.limitContentOffsetY(targetOffsetY: self.contentOffset.y - moveDistance)
            shouldScroll = true
        } else if touchPoint.y > maxOffsetY {
            // Cell is moving down - 向下滚动
            let moveDistance: CGFloat = (touchPoint.y - maxOffsetY) / edgeScrollTriggerRange * maxScrollSpeedPerFrame
            currentScrollSpeedPerFrame = moveDistance
            newContentOffsetY = self.limitContentOffsetY(targetOffsetY: self.contentOffset.y + moveDistance)
            shouldScroll = true
        } else {
            currentScrollSpeedPerFrame = 0
        }
        
        if shouldScroll && newContentOffsetY != self.contentOffset.y {
            // 更新contentOffset
            self.contentOffset = CGPoint(x: self.contentOffset.x, y: newContentOffsetY)
            
            // 强制布局更新，确保cell位置正确
            setNeedsLayout()
            layoutIfNeeded()
        }
        
        // 无论是否滚动，都需要更新snapshot位置和cell位置
        lmz_gestureChanged(gesture: gesture)
    }
    
    func limitContentOffsetY(targetOffsetY:CGFloat) ->CGFloat{
        var minContentOffsetY:CGFloat
        if #available(iOS 11.0, *) {
            minContentOffsetY = -self.adjustedContentInset.top;
        } else {
            minContentOffsetY = -self.contentInset.top;
        }
        var maxContentOffsetY:CGFloat = minContentOffsetY
        var contentSizeHeight:CGFloat = contentSize.height
        if #available(iOS 11.0, *) {
            contentSizeHeight += self.adjustedContentInset.top + self.adjustedContentInset.bottom
        } else {
            contentSizeHeight += self.contentInset.top + self.contentInset.bottom
        }
        if contentSizeHeight > self.bounds.size.height {
            maxContentOffsetY += contentSizeHeight - self.bounds.size.height
        }
        // 修复逻辑：限制targetOffsetY在minContentOffsetY和maxContentOffsetY之间
        return max(minContentOffsetY, min(maxContentOffsetY, targetOffsetY))
    }
    
    func limitSnapshotCenterY(targetY:CGFloat) -> CGFloat {
        // snapshot是直接添加到tableView上的，位置相对于tableView的bounds
        // 不需要考虑contentOffset，只需要确保不超出可见区域
        
        var topInset: CGFloat = 0
        var bottomInset: CGFloat = 0
        if #available(iOS 11.0, *) {
            topInset = self.adjustedContentInset.top
            bottomInset = self.adjustedContentInset.bottom
        } else {
            topInset = self.contentInset.top
            bottomInset = self.contentInset.bottom
        }
        
        // 最小Y值：确保snapshot的上边缘不超出tableView可见区域的顶部
        let minValue: CGFloat = topInset + snapshot.bounds.size.height / 2.0
        
        // 最大Y值：确保snapshot的下边缘不超出tableView可见区域的底部
        let maxValue: CGFloat = self.bounds.size.height - bottomInset - snapshot.bounds.size.height / 2.0
        
        // 限制targetY在有效范围内
        return max(minValue, min(maxValue, targetY))
    }
    func lmz_stopEdgeScroll() {
        currentScrollSpeedPerFrame = 0;
        edgeScrollLink?.invalidate();
    }
    
    func lmz_updateDataSourceAndCellFromIndexPath(from:IndexPath ,to indexPath:IndexPath) {
        if #available(iOS 10.0, *) {
            if canFeedback {
                self.generator.prepare()
                self.generator.impactOccurred()
            }
        }
        
        
        if tempDataSource[indexPath.section].moveAble == false {
            return
        }
        
        if self.numberOfSections == 1 {
            let tempItem:IMoveableItemDetail = tempDataSource[from.section].items[from.row]
            
            tempDataSource[from.section].items[from.row] = tempDataSource[indexPath.section].items[indexPath.row]
            tempDataSource[indexPath.section].items[indexPath.row] = tempItem
            moveRow(at: from, to: indexPath)
        } else {
            let tempItem:IMoveableItemDetail = tempDataSource[from.section].items[from.row]
            
            tempDataSource[from.section].items[from.row] = tempDataSource[indexPath.section].items[indexPath.row]
            tempDataSource[indexPath.section].items[indexPath.row] = tempItem
            beginUpdates()
            moveRow(at: indexPath, to: from)
            moveRow(at: from, to: indexPath)
            endUpdates()
        }
    }
    
    
    func lmz_gestureEndedOrCancelled(gesture:UILongPressGestureRecognizer) {
        if canEdgeScroll {
            self.lmz_stopEdgeScroll()
        }
        
        guard let selectedIndexPath = selectedIndexPath else {
            return
        }
        
        self.lmz_delegate?.tableView?(self, endMoveCellAtIndexPath: selectedIndexPath)
        
        guard let cell = cellForRow(at: selectedIndexPath) else {
            // 如果cell不存在，清理snapshot并返回
            snapshot.removeFromSuperview()
            return
        }
        UIView.animate(withDuration: 0.25) {  [self] in
            snapshot.transform = CGAffineTransform.identity;
            snapshot.frame = CGRect(x:(cell.frame.size.width - snapshot.frame.size.width)/2.0,
                                    y:cell.frame.origin.y + (cell.frame.size.height - snapshot.frame.size.height)/2.0,
                                    width:snapshot.frame.size.width,
                                    height:snapshot.frame.size.height);
        } completion: { (finish) in
            cell.isHidden = false
            self.snapshot.removeFromSuperview()
        }
    }

    //获取快照
    func lmz_snapshotViewWithInputView(inputView:UIView) -> UIImageView{
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0)
        guard let ctx = UIGraphicsGetCurrentContext() else { return
            UIImageView()
        }
        inputView.layer.render(in: ctx)
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let snapshot:UIImageView = UIImageView(image: image)
        return snapshot
    }

}


