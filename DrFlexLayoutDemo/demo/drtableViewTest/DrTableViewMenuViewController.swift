//
//  DrTableViewMenuViewController.swift
//  DrFlexLayoutDemo
//
//  Created by dr.box on 2023/3/1.
//

import UIKit
import DrFlexLayout

class DrTableViewMenuViewController: UIViewController {
    
    let listView: DrTableView = {
        let table = DrTableView(style: .plain)
        table.separatorStyle = .singleLine
        table.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        table.backgroundColor = .hexColor("#F5F5F5")
        table.rowHeight = 60
        return table
    }()
    
    var list: [Contact] = [
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
        view.addSubview(listView)
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
        
        dataSource.bindSource(self) { target in
            target.list
        }
        
        dataSource.menuDelegate = self
        
        listView.dataSource = dataSource
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        listView.frame = view.bounds
    }
    
}

extension DrTableViewMenuViewController: DrTableMenuDelegate {
    
    func menuConfiguration(indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let act1 = UIAction(title: "action1") { _ in
            print("click action1")
        }
        let act2 = UIAction(title: "action2") { _ in
            print("click action2")
        }
        let act3 = UIAction(title: "action3") { _ in
            print("click action3")
        }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            UIMenu(title: "menu test", children: [act1, act2, act3])
        }
    }
    
    func menuPreviewForHighlighting(configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        nil
    }
    
    func menuPreviewForDismissing(configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        nil
    }
    
    func menuClickPreview(configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        
    }
    
}


extension DrTableViewMenuViewController {
    
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
