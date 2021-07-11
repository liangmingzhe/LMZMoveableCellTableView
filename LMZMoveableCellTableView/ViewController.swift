//
//  ViewController.swift
//  LMZMoveableCellTableView
//
//  Created by lmz on 2021/7/6.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,LMZMovableCellTableViewDataSource,LMZMovableCellTableViewDelegate {
    var dataSource:[NSMutableArray] = [["1111111","2222222","3333333","4444444"],["测试1","测试2"],["条件1","条件2"],["场景1","场景2"]]
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
        self.view.addSubview(tableview)
        tableview.reloadData()
    }

    func snapshotViewWithCell(cell: LMZTableViewCell) -> UIView {
        return cell.bgView
    }

    func dataSourceArrayInTableView(tableView: LMZMoveableTableView) -> [NSMutableArray] {
        return dataSource
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource[section].count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell :LMZTableViewCell = tableView.dequeueReusableCell(withIdentifier: "111") as! LMZTableViewCell
        
        cell.title.text = (dataSource[indexPath.section][indexPath.row] as! String)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "11111"
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        }
        return false
        
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

