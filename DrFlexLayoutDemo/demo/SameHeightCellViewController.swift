//
//  SameHeightCellViewController.swift
//  DrFlexLayoutDemo
//
//  Created by dr.box on 2022/10/29.
//

import UIKit
import DrFlexLayout
import RxSwift

class SameHeightCellViewController: UIViewController {
    
    @objc private func clickRefreshBtn() {
        listView.refresh(needLayout: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(listView)
        bind()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "刷新",
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(clickRefreshBtn))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        listView.frame = view.bounds
    }

    private let listView: DrFlexTableView = {
        let table = DrFlexTableView(style: .plain)
        table.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        table.separatorColor = .red
        table.separatorStyle = .singleLine
        table.backgroundColor = .white
        table.rowHeight = 50 // 每个cell高度固定，cell随用随初始化，这样就不会一次性初始化全部的cell了
//        table.isSameHeight = true // 每个cell高度固定，以第一个cell计算的高度作为rowHeight
//        table.sectionHeaderHeight = 40
//        table.sectionFooterHeight = 40
        table.isSameSectionHeaderHeight = true
        table.isSameSectionFooterHeight = true
        return table
    }()
    
    private var dataList: [[String]] = [] {
        didSet {
            listView.reload()
        }
    }
    
}


extension SameHeightCellViewController {
    
    private func bind() {
        listView.numberOfSections(self) { target in
            target.dataList.count
        }
        listView.numberOfRowsInSection(self) { target, section in
            target.dataList[section].count
        }
        listView.cellInit(self) { target, indexPath in
            let v = UIView()
            v.backgroundColor = .white
            v.dr_flex.paddingHorizontal(20).direction(.row).alignItems(.center).define { flex in
                flex.addItem(UILabel()).define { flex in
                    let lb = flex.view as! UILabel
                    lb.text = target.dataList[indexPath.section][indexPath.row]
                    lb.font = .systemFont(ofSize: 17, weight: .regular)
                    lb.textColor = .hexColor("#2F2F2F")
                }
            }
            print("====init cell")
            return v
        }
        
        listView.headerInit(self) { target, section in
            let v = UIView()
            v.backgroundColor = .orange
            v.dr_flex.height(40).paddingHorizontal(20).justifyContent(.center).alignItems(.center).define { flex in
                flex.addItem(UILabel()).define { flex in
                    let lb = flex.view as! UILabel
                    lb.text = "SectionHeader: \(section)"
                    lb.font = .systemFont(ofSize: 17, weight: .semibold)
                    lb.textColor = .white
                }
            }
            print("====init header")
            return v
        }
        
        listView.footerInit(self) { target, section in
            let v = UIView()
            v.backgroundColor = .cyan
            v.dr_flex.height(40).paddingHorizontal(20).justifyContent(.center).alignItems(.center).define { flex in
                flex.addItem(UILabel()).define { flex in
                    let lb = flex.view as! UILabel
                    lb.text = "SectionFooter: \(section)"
                    lb.font = .systemFont(ofSize: 17, weight: .semibold)
                    lb.textColor = .white
                }
            }
            print("====init footer")
            return v
        }
        
        listView.cellUpdate(self) { target, cell, indexPath in
            print("=====cell refresh")
            return true
        }
        
        reloadData()
        
    }
    
    private func reloadData() {
        _ = Observable<[[String]]>.create { obs in
            var list: [[String]] = []
            for _ in 0...1000 {
                var arr: [String] = []
                for j in 0...100 {
                    arr.append("Row index: \(j)")
                }
                list.append(arr)
            }
            obs.onNext(list)
            obs.onCompleted()
            return Disposables.create()
        }
        .subscribe(on: SerialDispatchQueueScheduler(internalSerialQueueName: "fetch"))
        .bind(to: rx.dataList)
    }
}
