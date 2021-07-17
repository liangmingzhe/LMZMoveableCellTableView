//
//  ViewController.swift
//  LMZMoveableCellTableView
//
//  Created by lmz on 2021/7/6.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,LMZMovableCellTableViewDataSource,LMZMovableCellTableViewDelegate {
    
    var dataSource:[IMoveableItemSection] = [
        MoveableItemSection(titleString: "西行纪", sectionHeight: 20, can: true, cells: [
                                MoveableItemDetail(titleString: "持国天", detailString: "东方守护神", heigh: 60),
                                MoveableItemDetail(titleString: "帝释天", detailString: "天界首领", heigh: 60),
                                MoveableItemDetail(titleString: "孙悟空", detailString: "第一妖猴", heigh: 60)])
        ,
        MoveableItemSection(titleString: "千古绝尘", sectionHeight: 20, can: true, cells: [
                                MoveableItemDetail(titleString: "上古主神", detailString: "古帝剑", heigh: 70),
                                MoveableItemDetail(titleString: "白玦真神", detailString: "太苍神枪", heigh: 70),
                                MoveableItemDetail(titleString: "天启", detailString: "紫电鞭", heigh: 70)]),
        MoveableItemSection(titleString: "水浒传", sectionHeight: 20, can: false, cells: [
                                MoveableItemDetail(titleString: "鲁智深", detailString: "拳打镇关西", heigh: 60),
                                MoveableItemDetail(titleString: "潘金莲", detailString: "大朗喝药", heigh: 60)]),
    ]

        
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
        let tableview = LMZMoveableTableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height), style: .plain)
        tableview.lmz_delegate = self
        tableview.lmz_dataSource = self
        tableview.canFeedback = true
        tableview.register(UINib (nibName: "LMZTableViewCell", bundle: nil), forCellReuseIdentifier: "111")
        tableview.dataSource = self
        tableview.delegate = self
        tableview.allowsSelection = false
        tableview.separatorStyle = .none
        self.view.addSubview(tableview)
        tableview.reloadData()
    }
    func snapshotViewWithCell(cell: IMoveableTableViewCell) -> UIView {
        return cell.bgView
    }

    func dataSourceArrayInTableView(tableView: LMZMoveableTableView) -> [IMoveableItemSection] {
        return dataSource
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource[section].items.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell :LMZTableViewCell = tableView.dequeueReusableCell(withIdentifier: "111") as! LMZTableViewCell
        cell.config(cell: dataSource[indexPath.section].items[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataSource[indexPath.section].items[indexPath.row].cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return dataSource[section].height
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource[section].title
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        
        return dataSource[indexPath.section].moveAble
        
    }
    func tableView(_ tableView: LMZMoveableTableView, customizeMovalbeCell movableCellsnapshot: UIImageView) {
        movableCellsnapshot.layer.shadowColor = UIColor.black.cgColor;
        movableCellsnapshot.layer.masksToBounds = false;
        movableCellsnapshot.layer.cornerRadius = 10;
        movableCellsnapshot.layer.shadowOffset = CGSize(width: 0, height: 0)
        movableCellsnapshot.layer.shadowOpacity = 1;
        movableCellsnapshot.layer.shadowRadius = 10;
    }
    


    
    
    

}

