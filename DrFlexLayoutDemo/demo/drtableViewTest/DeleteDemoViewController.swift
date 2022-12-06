//
//  DeleteDemoViewController.swift
//  DrFlexLayoutDemo
//
//  Created by dr.box on 2022/12/5.
//

import UIKit
import DrFlexLayout

class DeleteDemoViewController: UIViewController {
    
    
    let tableView: DrTableView = {
        let table = DrTableView(style: .plain)
        table.separatorStyle = .singleLine
        table.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        table.backgroundColor = .hexColor("#F5F5F5")
        table.rowHeight = 60
        return table
    }()
    
    var list: [Contact] = [
        Contact(name: "drbox", mobile: "18290909874"),
        Contact(name: "jack", mobile: "18290909874"),
        Contact(name: "joy", mobile: "18290909874"),
        Contact(name: "tom", mobile: "18290909874"),
        Contact(name: "cat", mobile: "18290909874"),
        Contact(name: "LiLi", mobile: "18290909874"),
        Contact(name: "Marry", mobile: "18290909874"),
        Contact(name: "Kity", mobile: "18290909874"),
        Contact(name: "Loser", mobile: "18290909874"),
        Contact(name: "Bob", mobile: "18290909874"),
        Contact(name: "drbox2", mobile: "18290909874"),
        Contact(name: "jack2", mobile: "18290909874"),
        Contact(name: "joy2", mobile: "18290909874"),
        Contact(name: "Tom2", mobile: "18290909874"),
        Contact(name: "Kity2", mobile: "18290909874"),
        Contact(name: "Long", mobile: "18290909874"),
    ]

    private var isEditingForTable: Bool {
        get {
            tableView.isEditing
        }
        set {
            tableView.isEditing = newValue
            let title = newValue ? "取消" : "编辑"
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: title,
                                                                     style: .plain,
                                                                     target: self,
                                                                     action: #selector(clickEditBarBtn))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        isEditingForTable = false
        
        let dataSource = DrTableViewItemSource<Contact> { item, indexPath in
            DrViewBuilder("cell") { reuseView in
                let v: ContactCellView
                if let _v = reuseView as? ContactCellView {
                    v = _v
                }else {
                    v = ContactCellView()
                }
                v.model = item
                return v
            }
        }
        
        dataSource.onCanEdit(self) { target, item, indexPath in
            true
        }
        dataSource.onEditingStyle(self) { target, item, indexPath in
            return .delete
        }
        dataSource.onTitleForDelete(self) { target, item, indexPath in
            "删除"
        }
        dataSource.onCommitEdit(self) { target, item, indexPath, editStyle, view in
            print("===删除：\(view), item: \(item)")
            target.list.remove(at: indexPath.row)
            target.tableView.reload()
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

    @objc func clickEditBarBtn() {
        isEditingForTable = !isEditingForTable
    }
}


extension DeleteDemoViewController {
    
    struct Contact {
        let name: String
        let mobile: String
    }
    
    class ContactCellView: UIView {
        
        private let nameLabel: UILabel = {
            let lb = UILabel()
            lb.textColor = .hexColor("#2A2A2A")
            lb.font = .systemFont(ofSize: 17, weight: .semibold)
            lb.textAlignment = .left
            return lb
        }()
        private let mobileLabel: UILabel = {
            let lb = UILabel()
            lb.textColor = .hexColor("#2A2A2A")
            lb.font = .systemFont(ofSize: 14, weight: .regular)
            lb.textAlignment = .left
            return lb
        }()
        var model: Contact? {
            didSet {
                if nameLabel.text != model?.name {
                    nameLabel.text = model?.name
                    nameLabel.dr_flex.markDirty()
                }
                if mobileLabel.text != model?.mobile {
                    mobileLabel.text = model?.mobile
                    mobileLabel.dr_flex.markDirty()
                }
            }
        }
        
        init() {
            super.init(frame: .zero)
            layoutUI()
            backgroundColor = .white
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func layoutUI() {
            dr_flex.paddingHorizontal(20).justifyContent(.center).height(60).define { flex in
                flex.addItem(nameLabel)
                flex.addItem(mobileLabel).marginTop(8)
            }
        }
        
    }
    
}
