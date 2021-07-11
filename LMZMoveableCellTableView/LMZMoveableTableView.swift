//
//  LMZMoveableTableView.swift
//  LCIntelligentTableView
//
//  Created by mac on 2021/7/7.
//

import UIKit
@objc protocol LCMovableCellTableViewDataSource : UITableViewDataSource {
    func dataSourceArrayInTableView(tableView:LMZMoveableTableView) -> [NSMutableArray]
    @objc optional func snapshotViewWithCell(cell:LCTableViewCell) -> UIView
    
}


@objc protocol LCMovableCellTableViewDelegate : UITableViewDelegate {
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
    var tempDataSource:[NSMutableArray] = []
    weak open var lmz_dataSource: LCMovableCellTableViewDataSource?
    weak open var lmz_delegate: LCMovableCellTableViewDelegate?
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        if #available(iOS 10.0, *) {
            generator = UIImpactFeedbackGenerator(style: .light)
        }
        
        lc_initData()
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(lc_processGesture(gesture:)))
        longPressGesture?.minimumPressDuration = 0.5
        self.addGestureRecognizer(longPressGesture!)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil {
            self.lc_stopEdgeScroll()
        }
    }
    
    func lc_initData() {

    }
    
    func lc_addGesture() {
        
    }
    
    
    //长按手势
    @objc func lc_processGesture(gesture:UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            lc_gestureBegan(gesture: gesture)
            print("touch began..")
            break
        case .changed:
            lc_gestureChanged(gesture: gesture)
            print("touch change..")
            break
        case .cancelled,.ended:
            lc_gestureEndedOrCancelled(gesture: gesture)
            print("touch end..")
        default:
            break
        }
    }
    
    
    //手势开始
    func lc_gestureBegan(gesture:UILongPressGestureRecognizer) {
        let point = gesture.location(in: gesture.view)
        let selectedIndex : IndexPath = self.indexPathForRow(at: point)!
            
        let cell:UITableViewCell = self.cellForRow(at: selectedIndex)!
        
        if selectedIndex.section != 0 {
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
            self.lc_startEdgeScroll()
        }
        //Get a data source every time you move
        if self.lmz_dataSource != nil {
            tempDataSource = (self.lmz_dataSource?.dataSourceArrayInTableView(tableView: self))!
        }
        selectedIndexPath = selectedIndex
        if #available(iOS 10.0, *) {
            if canFeedback {
                generator.prepare();
                generator.impactOccurred();
            }
        }
        
        if self.lmz_dataSource != nil {
            guard let snapView = (self.lmz_dataSource!.snapshotViewWithCell?(cell: cell as! LCTableViewCell)) else {
                return
            }
            snapshot = self.lc_snapshotViewWithInputView(inputView: snapView)
        } else {
            snapshot = self.lc_snapshotViewWithInputView(inputView: cell)
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
    func lc_gestureChanged(gesture:UILongPressGestureRecognizer) {
        var point:CGPoint = gesture.location(in: gesture.view)
        point = CGPoint(x: snapshot.center.x, y: self.limitSnapshotCenterY(targetY: point.y))
        
        //Let the screenshot follow the gesture
        snapshot.center = point;
        guard let currentIndexPath:IndexPath = indexPathForRow(at: point) else {
            return
        }
        guard selectedIndexPath != nil else {
            return
        }
        guard let selectedCell:UITableViewCell = self.cellForRow(at: selectedIndexPath!) else {
            return
        }
        selectedCell.isHidden = true

        if ((self.lmz_dataSource?.tableView?(self, canMoveRowAt: currentIndexPath)) == nil) {
            return
        }
        
        if (selectedIndexPath != currentIndexPath) && (selectedIndexPath?.section == currentIndexPath.section) {
            lc_updateDataSourceAndCellFromIndexPath(from: selectedIndexPath!, to: currentIndexPath)
            
            self.lmz_delegate?.tableView?(self, didMoveCellFromIndexPath: currentIndexPath)
            selectedIndexPath = currentIndexPath
        }
        
    }
    
    //手势结束
    func lc_gestureEnd(gesture:UILongPressGestureRecognizer) {
        
    }
    
    
    func lc_startEdgeScroll() {
        edgeScrollLink = CADisplayLink.init(target: self, selector: #selector(lc_processEdgeScroll))
        edgeScrollLink!.add(to: RunLoop.main, forMode: .common)
        
    }
    
    @objc func lc_processEdgeScroll() {
        let minOffsetY:CGFloat = self.contentOffset.y + edgeScrollTriggerRange
        let maxOffsetY:CGFloat = self.contentOffset.y + self.bounds.size.height - edgeScrollTriggerRange;
        
        let touchPoint:CGPoint = snapshot.center;
        
        if touchPoint.y < minOffsetY {
            //Cell is moving up
            let moveDistance:CGFloat = (minOffsetY - touchPoint.y)/edgeScrollTriggerRange * maxScrollSpeedPerFrame
            currentScrollSpeedPerFrame = moveDistance
            
            self.contentOffset = CGPoint(x: self.contentOffset.x, y: self.limitContentOffsetY(targetOffsetY: self.contentOffset.y - moveDistance))
        } else if touchPoint.y > maxOffsetY {
            //Cell is moving down
            let moveDistance:CGFloat = (touchPoint.y - maxOffsetY)/edgeScrollTriggerRange * maxScrollSpeedPerFrame;
            currentScrollSpeedPerFrame = moveDistance;
            self.contentOffset = CGPoint(x:self.contentOffset.x, y: self.limitContentOffsetY(targetOffsetY: self.contentOffset.y + moveDistance));
        }
        setNeedsLayout()
        layoutIfNeeded()
        lc_gestureChanged(gesture: longPressGesture!)
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
        return min(maxContentOffsetY, max(minContentOffsetY, targetOffsetY))
    }
    
    func limitSnapshotCenterY(targetY:CGFloat) -> CGFloat {
        let minValue:CGFloat = snapshot.bounds.size.height/2.0 + self.contentOffset.y
        let maxValue:CGFloat = self.contentOffset.y + self.bounds.size.height - snapshot.bounds.size.height/2.0
        return min(maxValue, max(minValue, targetY));
    }
    func lc_stopEdgeScroll() {
        currentScrollSpeedPerFrame = 0;
        edgeScrollLink?.invalidate();
    }
    
    func lc_updateDataSourceAndCellFromIndexPath(from:IndexPath ,to indexPath:IndexPath) {
        if #available(iOS 10.0, *) {
            if canFeedback {
                self.generator.prepare()
                self.generator.impactOccurred()
            }
        }
        
        if from.section != indexPath.section {
            return
        }
        if self.numberOfSections == 3 {
            tempDataSource[from.section].exchangeObject(at: from.row, withObjectAt: indexPath.row)
            
            moveRow(at: from, to: indexPath)
        } else {
            //exchange data
            print("lmz: ** target index section:\(indexPath.section),row:\(indexPath.row)")
            //如果是第一组的最后一组非交换。而是添加
            let fromData = tempDataSource[from.section][from.row]
            let toData = tempDataSource[indexPath.section][indexPath.row]
            let fromArray = tempDataSource[from.section]
            let toArray = tempDataSource[indexPath.section]
            
            fromArray.replaceObject(at: from.row, with: toData)
            toArray.replaceObject(at: indexPath.row, with: fromData)
            tempDataSource[indexPath.section] = toArray
            if #available(iOS 11.0, *) {
                if currentScrollSpeedPerFrame > 10 {
                    reloadRows(at: [from,indexPath], with: .none)
                } else {
                    beginUpdates()
                    moveRow(at: indexPath, to: from)
                    moveRow(at: from, to: indexPath)
                    endUpdates()
                }
            } else {
                beginUpdates()
                moveRow(at: indexPath, to: from)
                moveRow(at: from, to: indexPath)
                endUpdates()
            }
            
        }
    }
    
    
    func lc_gestureEndedOrCancelled(gesture:UILongPressGestureRecognizer) {
            
        if canEdgeScroll {
            self.lc_stopEdgeScroll()
        }
        self.lmz_delegate?.tableView?(self, endMoveCellAtIndexPath: selectedIndexPath!)
        
        
        guard (selectedIndexPath != nil) else {
            return
        }
        let cell:UITableViewCell = cellForRow(at: selectedIndexPath!) ?? UITableViewCell()
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
    func lc_snapshotViewWithInputView(inputView:UIView) -> UIImageView{
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


