//
//  ViewController.swift
//  DrFlexLayoutDemo
//
//  Created by dr.box on 2021/10/11.
//

import UIKit
import DrFlexLayout

class ViewController: UITableViewController {
    
    let itemList: [(title: String, vc: UIViewController)] = [
        ("基础使用篇", NormalViewController()),
        ("Style使用篇", StyleViewController()),
        ("TableView1", FlexTableViewController()),
        ("TableView2", FlexTableViewController2()),
        ("ScrollView", FlexScrollViewController()),
        ("RemoveView", RemoveViewController()),
        ("RxTableView", RXTableViewController()),
        ("RxNormalTableView", RxNormalTableViewController()),
        ("RxSwipeMenuTableView", FlexTableViewSwipeMenuController()),
        ("RxMutipleSelectTableView", RxTableViewMultipleController()),
        ("RxCustomEditingTableView", RxTableViewCustomEditingController()),
        ("BubbleView", BubbleViewController()),
        ("hidden", HiddenViewController()),
        ("SameHeightCell", SameHeightCellViewController()),
        ("CollectionView", CollectionViewController()),
        ("DrTableNormal", DrTableNormalViewController()),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Flex Layout"
        
        tableView.rowHeight = 44
        tableView.separatorStyle = .singleLine
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
}


extension ViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        itemList.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        if #available(iOS 14.0, *) {
            var config = UIListContentConfiguration.valueCell()
            config.text = itemList[indexPath.row].title
            cell.contentConfiguration = config
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let (title, vc) = itemList[indexPath.row]
        vc.title = title
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
