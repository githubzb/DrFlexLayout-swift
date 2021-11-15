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
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        table.frame = view.bounds
    }
}
