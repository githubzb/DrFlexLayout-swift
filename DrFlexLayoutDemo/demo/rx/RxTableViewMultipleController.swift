//
//  RxTableViewMultipleController.swift
//  DrFlexLayoutDemo
//
//  Created by dr.box on 2022/9/25.
//

import UIKit
import DrFlexLayout
import RxSwift
import RxCocoa

// 实现多选步骤：
// 1、table.allowsMultipleSelectionDuringEditing = true
// 2、dataSource.cellCanEdit { item, indexPath in
//      return true
//   }

class RxTableViewMultipleController: UIViewController {

    typealias Item = String
    
    @objc func updateEdite() {
        isEditing = !isEditing
        listView.setEditing(isEditing, animated: true) // 执行动画
//        listView.isEditing = isEditing // 没动画
    }
    
    @objc func remove() {
        if let rows = listView.indexPathsForSelectedRows?.map({$0.row}) {
            source.removeItems(rows: rows, section: 0)
            publisher.accept(source)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(listView)
        bind()
        publisher.accept(source)
        isEditing = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        listView.frame = view.bounds
    }
    
    
    override var isEditing: Bool {
        didSet {
            if isEditing {
                self.navigationItem.rightBarButtonItems = [
                    UIBarButtonItem(title: "取消编辑",
                                    style: .plain,
                                    target: self,
                                    action: #selector(updateEdite)),
                    UIBarButtonItem(title: "删除",
                                    style: .plain,
                                    target: self,
                                    action: #selector(remove))
                ]
            }else {
                self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "编辑",
                                                                         style: .plain,
                                                                         target: self,
                                                                         action: #selector(updateEdite))]
            }
        }
    }

    let listView: DrFlexTableView = {
        let table = DrFlexTableView(style: .plain)
        table.backgroundColor = .white
        table.separatorStyle = .singleLine
        table.allowsMultipleSelectionDuringEditing = true
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


extension RxTableViewMultipleController {
    
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
        
        dataSource.cellCanEdit { item, indexPath in
            return true
        }
        
        dataSource.cellClick.filter({[unowned self]_ in !self.listView.isEditing})
            .bind { (item, indexPath) in
                print("-----点击：\(item)")
            }
            .disposed(by: disposeBag)
        
        listView.rx.items(dataSource)(publisher).disposed(by: disposeBag)
    }
}
