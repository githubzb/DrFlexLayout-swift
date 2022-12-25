//
//  DrFlexTableTestViewController.swift
//  DrFlexLayoutDemo
//
//  Created by dr.box on 2022/12/24.
//

import UIKit
import DrFlexLayout

class DrFlexTableTestViewController: UIViewController {
    
    private var listView: DrFlexTableView = {
        let table = DrFlexTableView(style: .plain)
        table.separatorStyle = .singleLine
        table.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        table.isSameHeight = true
        return table
    }()
    
    private var isStyle1 = true {
        didSet {
            let title = isStyle1 ? "style1" : "style2"
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: title,
                                                                     style: .plain,
                                                                     target: self,
                                                                     action: #selector(clickNavBarItem))
        }
    }
    
    private var items: [Item] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(listView)
        isStyle1 = true
        listView.cellInit(self) { target, indexPath in
            print("-----初始化cell: \(indexPath.row)")
            let item = target.items[indexPath.row]
            switch item {
            case let .style1(title):
                return Style1Cell(title: title)
                
            case let .style2(title, subtitle):
                return Style2Cell(title: title, subtitle: subtitle)
            }
        }
        listView.numberOfRowsInSection(self) { target, section in
            target.items.count
        }
        reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        listView.frame = view.bounds
    }
    
    @objc private func clickNavBarItem() {
        self.isStyle1 = !self.isStyle1
        reloadData()
    }
    
    private func reloadData() {
        self.items.removeAll()
        if isStyle1 {
            for i in 0...50 {
                self.items.append(.style1(title: "标题（\(i)）"))
            }
        }else {
            for i in 0...50 {
                self.items.append(.style2(title: "标题（\(i)）", subtitle: "副标题（\(i)）"))
            }
        }
        listView.reload()
    }
    
}


extension DrFlexTableTestViewController {
    
    enum Item {
        case style1(title: String)
        case style2(title: String, subtitle: String)
    }
    
    class Style1Cell: UIView {
        
        let title: String
        
        init(title: String) {
            self.title = title
            super.init(frame: .zero)
            layoutUI()
            backgroundColor = .white
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func layoutUI() {
            dr_flex.height(60).paddingHorizontal(20).direction(.row).alignItems(.center).define { flex in
                flex.addItem(UILabel()).define { flex in
                    let lb = flex.view as! UILabel
                    lb.text = title
                    lb.font = .systemFont(ofSize: 17, weight: .regular)
                    lb.textColor = .black
                }
            }
        }
    }
    
    class Style2Cell: UIView {
        
        let title: String
        let subtitle: String
        
        init(title: String, subtitle: String) {
            self.title = title
            self.subtitle = subtitle
            super.init(frame: .zero)
            layoutUI()
            backgroundColor = .white
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func layoutUI() {
            dr_flex.height(60).paddingHorizontal(20).direction(.row).alignItems(.center).define { flex in
                flex.addItem(UILabel()).define { flex in
                    let lb = flex.view as! UILabel
                    lb.text = title
                    lb.font = .systemFont(ofSize: 17, weight: .regular)
                    lb.textColor = .black
                }
                flex.addItem(UILabel()).flex(1).define { flex in
                    let lb = flex.view as! UILabel
                    lb.text = title
                    lb.font = .systemFont(ofSize: 14, weight: .regular)
                    lb.textColor = .black
                    lb.textAlignment = .right
                }
            }
        }
    }
}
