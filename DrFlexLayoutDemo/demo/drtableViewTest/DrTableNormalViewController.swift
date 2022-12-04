//
//  DrTableNormalViewController.swift
//  DrFlexLayoutDemo
//
//  Created by dr.box on 2022/12/4.
//

import UIKit
import DrFlexLayout

class DrTableNormalViewController: UIViewController {
    
    let tableView: DrTableView = {
        let table = DrTableView(style: .plain)
        table.separatorStyle = .singleLine
        table.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        return table
    }()
    
    let list =  ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        
        let dataSource = DrTableViewItemSource<String>{ item, indexPath in
            DrViewBuilder("cell"){ reuseView in
                if let v = reuseView { // 复用的视图
                    return v
                }
                let v = UIView()
                v.dr_flex.paddingHorizontal(20).paddingVertical(20).define { flex in
                    flex.addItem(UILabel()).define { flex in
                        let lb = flex.view as! UILabel
                        lb.text = item
                        lb.font = .systemFont(ofSize: 17, weight: .semibold)
                        lb.textColor = .black
                    }
                }
                return v
            }
        }

        dataSource.bindSource(self) { target in
            target.list
        }
        tableView.dataSource = dataSource
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.frame = view.bounds
    }
    
}
