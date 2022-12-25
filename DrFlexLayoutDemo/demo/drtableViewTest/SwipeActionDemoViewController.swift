//
//  SwipeActionDemoViewController.swift
//  DrFlexLayoutDemo
//
//  Created by dr.box on 2022/12/25.
//

import UIKit
import DrFlexLayout

class SwipeActionDemoViewController: UIViewController {
    
    deinit {
        print("---SwipeActionDemoViewController deinit")
    }
    
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
        
        dataSource.onCanEdit(self) { target, item, indexPath in
            return true
        }
        
        dataSource.onLeadingSwipeAction(target: self) { target, item, indexPath in
            print("====leadingAction: \(indexPath)")
            let act1 = DrSwipeActionsConfiguration.Action(title: "关注", bgColor: .blue) { completionHandler in
                target.clickFollow(item: item, indexPath: indexPath)
                completionHandler(true)
            }
            let act2 = DrSwipeActionsConfiguration.Action(title: "删除", bgColor: .red) { completionHandler in
                target.clickDelete(item: item, indexPath: indexPath)
                completionHandler(true)
            }
            return DrSwipeActionsConfiguration(actions: [act1, act2], performsFirstActionWithFullSwipe: true)
        }
        
        dataSource.onTrailingSwipeAction(target: self) { target, item, indexPath in
            print("====trailingAction: \(indexPath)")
            let act1 = DrSwipeActionsConfiguration.Action(title: "拨打", bgColor: .blue) { completionHandler in
                print("====拨打：\(item), index: \(indexPath)")
                completionHandler(true)
            }
            let act2 = DrSwipeActionsConfiguration.Action(title: "短信", bgColor: .red) { completionHandler in
                print("====短信：\(item), index: \(indexPath)")
                completionHandler(true)
            }
            return DrSwipeActionsConfiguration(actions: [act1, act2], performsFirstActionWithFullSwipe: true)
        }
        
        listView.dataSource = dataSource
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        listView.frame = view.bounds
    }

    
    // 关注
    private func clickFollow(item: Contact, indexPath: IndexPath) {
        print("====关注: \(item), index: \(indexPath)")
    }
    // 删除
    private func clickDelete(item: Contact, indexPath: IndexPath) {
        print("====删除: \(item), index: \(indexPath)")
        list.remove(at: indexPath.row)
        listView.deleteRows(at: [indexPath], with: .left)
    }
    
}


extension SwipeActionDemoViewController {
    
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
