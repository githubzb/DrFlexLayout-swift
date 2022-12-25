//
//  SectionIndexTitlesDemoViewController.swift
//  DrFlexLayoutDemo
//
//  Created by dr.box on 2022/12/24.
//

import UIKit
import DrFlexLayout

class SectionIndexTitlesDemoViewController: UIViewController {

    typealias Item = DrTableViewGroupSource<Contact>.Group<Contact>
    
    let tableView: DrTableView = {
        let table = DrTableView(style: .plain)
        table.separatorStyle = .singleLine
        table.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        table.backgroundColor = .hexColor("#F5F5F5")
        return table
    }()
    
    let list: [Item] = [
        Item(items: [
            Contact(name: "drbox", mobile: "17009898767"),
            Contact(name: "drbox1", mobile: "17009898767"),
            Contact(name: "drbox2", mobile: "17009898767"),
            Contact(name: "drbox3", mobile: "17009898767"),
            Contact(name: "drbox4", mobile: "17009898767"),
            Contact(name: "drbox5", mobile: "17009898767"),
            Contact(name: "drbox6", mobile: "17009898767"),
            Contact(name: "drbox7", mobile: "17009898767"),
            Contact(name: "drbox8", mobile: "17009898767"),
            Contact(name: "drbox9", mobile: "17009898767"),
            Contact(name: "drbox10", mobile: "17009898767"),
        ], header: "D字母开头", footer: nil),
        Item(items: [
            Contact(name: "joby1", mobile: "17009898767"),
            Contact(name: "joby2", mobile: "17009898767"),
            Contact(name: "joby3", mobile: "17009898767"),
            Contact(name: "joby4", mobile: "17009898767"),
            Contact(name: "joby5", mobile: "17009898767"),
            Contact(name: "joby6", mobile: "17009898767"),
            Contact(name: "joby7", mobile: "17009898767"),
            Contact(name: "joby8", mobile: "17009898767"),
            Contact(name: "joby9", mobile: "17009898767"),
            Contact(name: "joby10", mobile: "17009898767"),
        ], header: "J字母开头", footer: nil),
        Item(items: [
            Contact(name: "pack1", mobile: "17009898767"),
            Contact(name: "pack2", mobile: "17009898767"),
            Contact(name: "pack3", mobile: "17009898767"),
            Contact(name: "pack4", mobile: "17009898767"),
            Contact(name: "pack5", mobile: "17009898767"),
            Contact(name: "pack6", mobile: "17009898767"),
            Contact(name: "pack7", mobile: "17009898767"),
            Contact(name: "pack8", mobile: "17009898767"),
            Contact(name: "pack9", mobile: "17009898767"),
            Contact(name: "pack10", mobile: "17009898767"),
        ], header: "P字母开头", footer: nil)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        
        let dataSource = DrTableViewGroupSource<Contact> { item, indexPath in
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
        } headerBuilder: { group, section in
            DrViewBuilder("header") { reuseView in
                let v: HeaderFooterView
                if let _v = reuseView as? HeaderFooterView {
                    v = _v
                }else {
                    v = HeaderFooterView()
                }
                v.title = ((group.header as? String) ?? "") + "（\(group.itemCount)）Header"
                return v
            }
        } footerBuilder: { group, section in
            nil
        }

        dataSource.bindSource(self) { target in
            target.list
        }
        
        dataSource.bindSectionIndexTitles(self) { target in
            ["D", "J", "P"]
        }
        
        dataSource.onSectionIndexTitlesMap(self) { target, title, index in
            print("===点击title: \(title), index: \(index)")
            return index // 返回将要移动到的section索引
        }

        tableView.dataSource = dataSource
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.frame = view.bounds
    }

}



extension SectionIndexTitlesDemoViewController {
    
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
