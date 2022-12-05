//
//  ItemDataSourceViewController.swift
//  DrFlexLayoutDemo
//
//  Created by admin on 2022/12/5.
//

import UIKit
import DrFlexLayout

class ItemDataSourceViewController: UIViewController {

    let tableView: DrTableView = {
        let table = DrTableView(style: .plain)
        table.separatorStyle = .singleLine
        table.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        table.backgroundColor = .hexColor("#F5F5F5")
        table.rowHeight = 70 // 如果每个cell都是一样高，并且是固定的高度，可以设置该属性，以提高性能
        return table
    }()
    
    let list: [Contact] = [
        Contact(name: "drbox", mobile: "18310009897"),
        Contact(name: "drbox1", mobile: "18310009897"),
        Contact(name: "drbox2", mobile: "18310009897"),
        Contact(name: "drbox3", mobile: "18310009897"),
        Contact(name: "drbox4", mobile: "18310009897"),
        Contact(name: "drbox5", mobile: "18310009897"),
        Contact(name: "drbox6", mobile: "18310009897"),
        Contact(name: "drbox7", mobile: "18310009897"),
        Contact(name: "drbox8", mobile: "18310009897"),
        Contact(name: "drbox9", mobile: "18310009897"),
        Contact(name: "drbox10", mobile: "18310009897"),
        Contact(name: "drbox11", mobile: "18310009897"),
        Contact(name: "drbox12", mobile: "18310009897"),
        Contact(name: "drbox13", mobile: "18310009897"),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)

        let dataSource = DrTableViewItemSource<Contact> { item, indexPath in
            DrViewBuilder("cell"){ reuseView in
                let v: ContactCellView
                if let _v = reuseView as? ContactCellView {
                    v = _v // 复用的视图
                }else {
                    v = ContactCellView()
                }
                v.model = item
                return v
            }
        } headerBuilder: { // 如果不需要header，该参数可以设置为nil
            DrViewBuilder("header") { reuseView in
                if let v = reuseView {
                    return v
                }
                let header = HeaderFooterView()
                header.title = "通讯录Header"
                return header
            }
        } footerBuilder: { // 如果不需要footer，该参数可以设置为nil
            DrViewBuilder("footer") { reuseView in
                if let v = reuseView {
                    return v
                }
                let footer = HeaderFooterView()
                footer.title = "通讯录Footer"
                return footer
            }
        }

        dataSource.bindSource(self) { target in // 绑定元数据
            target.list
        }
        
        dataSource.onClick(self) { target, item, indexPath, view in
            print("===click item: \(item), indexPath: \(indexPath), view: \(view)")
        }
        
        dataSource.onWillDisplay(self) { target, item, indexPath, view in
            print("===willDisplay item: \(item), indexPath: \(indexPath), view: \(view)")
        }
        tableView.dataSource = dataSource
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.frame = view.bounds
    }

}


extension ItemDataSourceViewController {
    
    struct Contact {
        let name: String
        let mobile: String
    }
    
    class HeaderFooterView: UIView {
        
        private let titleLabel: UILabel = {
            let lb = UILabel()
            lb.textColor = .white
            lb.font = .systemFont(ofSize: 18, weight: .semibold)
            lb.textAlignment = .left
            return lb
        }()
        
        var title: String? {
            didSet {
                if titleLabel.text != title {
                    titleLabel.text = title
                    titleLabel.dr_flex.markDirty()
                }
            }
        }
        
        init() {
            super.init(frame: .zero)
            layoutUI()
            backgroundColor = .hexColor("#38BAF3")
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func layoutUI() {
            dr_flex.height(30).justifyContent(.center).paddingHorizontal(20).define { flex in
                flex.addItem(titleLabel)
            }
        }
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
            dr_flex.paddingHorizontal(20).justifyContent(.center).height(70).define { flex in
                flex.addItem(nameLabel)
                flex.addItem(mobileLabel).marginTop(8)
            }
        }
        
    }
}
