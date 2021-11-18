//
//  FlexTableViewController.swift
//  DrFlexLayoutDemo
//
//  Created by dr.box on 2021/11/15.
//

import UIKit
import DrFlexLayout

class FlexTableViewController: UIViewController {
    
    let table = DrFlexTableView(style: .plain)
    
    let v = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(table)
        
        let header = UIView()
        header.backgroundColor = .blue
        header.dr_flex.addItem(self.v).height(100).marginHorizontal(20).marginVertical(20).backgroundColor(.yellow)
        table.tableHeaderView = header

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.table.tableHeaderView?.backgroundColor = .red
            self.v.backgroundColor = .blue
            self.v.dr_flex.height(200)
            let v = UIView()
            v.backgroundColor = .green
            self.table.tableHeaderView?.dr_flex.addItem(v).height(20).marginHorizontal(20).marginVertical(20)
            self.table.layoutTableHeaderView()
        }
        
        table.numberOfSections(self) { _ in
            return 5
        }
        
        table.numberOfRowsInSection(self) { target, section in
            return target.number
        }
        
        table.cellInit(self) { _, indexPath in
            let v = UIView()
            v.backgroundColor = .white
            v.dr_flex.addItem().margin(10).height(50).define { flex in
                flex.view?.backgroundColor = .orange
                flex.view?.layer.cornerRadius = 10
            }
            return v
        }
        
        table.cellClick(self) { target, indexPath in
            target.clickCell(indexPath: indexPath)
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "刷新",
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(refresh))
    }
    
    @objc func refresh(){
        table.reload()
    }
    
    var number: Int {
        10
    }
    
    func clickCell(indexPath: IndexPath) {
        print("------点击：\(indexPath.row)")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        table.frame = view.bounds
    }
    
    deinit {
        print("----deinit")
    }
}
