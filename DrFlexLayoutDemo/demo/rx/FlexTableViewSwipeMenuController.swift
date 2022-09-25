//
//  FlexTableViewSwipeMenuController.swift
//  DrFlexLayoutDemo
//
//  Created by dr.box on 2022/9/24.
//

import UIKit
import DrFlexLayout
import RxSwift
import RxCocoa

class FlexTableViewSwipeMenuController: UIViewController {

    typealias Item = String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(listView)
        bind()
        publisher.accept(source)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        listView.frame = view.bounds
    }
    
    let listView: DrFlexTableView = {
        let table = DrFlexTableView(style: .plain)
        table.backgroundColor = .white
        table.separatorStyle = .singleLine
        return table
    }()
    
    let source = DrSource<Item>(items: [
        "A",
        "B",
        "C",
        "D",
        "E",
        "F",
    ])
    
    let publisher = PublishRelay<DrSource<Item>>()
    let disposeBag = DisposeBag()
}


extension FlexTableViewSwipeMenuController {
    
    func bind() {
        let dataSource = DrTableDataSource<Item> { item, indexPath in
           let v = UIView()
            v.dr_flex.height(60).paddingHorizontal(20).justifyContent(.center).define { flex in
                flex.addItem(UILabel()).define { flex in
                    let lb = flex.view as! UILabel
                    lb.text = item
                    lb.font = .systemFont(ofSize: 15, weight: .regular)
                    lb.textColor = .black
                }
            }
            return v
        }
        
        // 添加删除按钮（方式一）
//        dataSource.cellCanEdit { item, indexPath in
//            true
//        }
//        dataSource.cellEditingStyle { item, indexPath in
//            return .delete
//        }
//        dataSource.cellEditCommit { [weak self] item, indexPath, type in
//            self?.source.removeItem(row: indexPath.row, section: indexPath.section)
//            if let source = self?.source {
//                self?.publisher.accept(source)
//            }
//        }
        
        
        // 添加删除按钮（方式二）
        dataSource.cellCanEdit { item, indexPath in
            true
        }
        let items = [
            DrSwipeMenuItem(title: "删除", backgroundColor: .red),
            DrSwipeMenuItem(title: "订阅", backgroundColor: .blue)
        ]
        dataSource.addCellSwipeMenu(items: items) { [weak self] item, indexPath, menuItemIndex in
            guard let source = self?.source else {
                return
            }
            if menuItemIndex == 0 { // 删除
                source.removeItem(row: indexPath.row, section: indexPath.section)
                self?.publisher.accept(source)
            }else { // 订阅
                print("----订阅：\(item)")
            }
        }
        listView.rx.items(dataSource)(publisher).disposed(by: disposeBag)
    }
}
