//
//  DrTableViewListController.swift
//  DrFlexLayoutDemo
//
//  Created by admin on 2022/12/5.
//

import UIKit

class DrTableViewListController: UITableViewController {
    
    let itemList: [(title: String, vc: ()->UIViewController)] = [
        ("ItemDataSource", {ItemDataSourceViewController()}),
        ("GroupDataSource", {GroupDataSourceViewController()}),
        ("可变高度", {MutableHeightTableViewController()}),
        ("删除操作", {DeleteDemoViewController()})
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 44
        tableView.separatorStyle = .singleLine
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

}


extension DrTableViewListController {
    
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
        let (title, builder) = itemList[indexPath.row]
        let vc = builder()
        vc.title = title
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
