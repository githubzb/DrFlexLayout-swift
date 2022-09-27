//
//  RxTableViewCustomEditingController.swift
//  DrFlexLayoutDemo
//
//  Created by dr.box on 2022/9/25.
//

import UIKit
import RxCocoa
import RxSwift
import DrFlexLayout

// TODO: 暂时存在问题
class RxTableViewCustomEditingController: UIViewController {

    typealias Item = String
    
    
    @objc func updateEdite() {
        isEditing = !isEditing
        listView.setEditing(isEditing, animated: true) // 执行动画
//        listView.isEditing = isEditing // 没动画
        if !isEditing {
            selectIndexPaths.removeAll()
        }
    }
    
    @objc func remove() {
        let rows = selectIndexPaths.map({$0.row}).sorted(by: <)
        source.removeItems(rows: rows, section: 0)
        publisher.accept(source)
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
        return table
    }()
    
    let source = DrSource<Item>(items: [
        "A",
        "B",
        "C",
        "D",
        "E",
        "F",
        "G",
        "H",
        "I",
        "J",
        "K",
        "L",
        "M",
        "N",
        "O",
        "P",
        "Q",
        "R",
        "S",
        "T",
        "U",
        "V",
        "W",
        "X",
        "Y",
        "Z",
    ])
    
    var selectIndexPaths: [IndexPath] = []
    
    let publisher = PublishRelay<DrSource<Item>>()
    let disposeBag = DisposeBag()
    
    deinit {
        print("---RxTableViewCustomEditingController deinit")
    }
}


extension RxTableViewCustomEditingController {
    
    func bind() {
        let dataSource = DrTableDataSource<Item> { [unowned self] item, indexPath in
            let cell = DrMutipleSelectCell(title: item, indexPath: indexPath)
            cell.selected.bind(to: self.selectCell).disposed(by: cell.disposeBag)
            return cell
        }
        
        listView.rx.items(dataSource)(publisher).disposed(by: disposeBag)
    }
    
    var selectCell: Binder<(Bool, IndexPath)> {
        Binder(self) { (vc, el) in
            if el.0 {
                vc.selectIndexPaths.append(el.1)
            }else {
                if let idx = vc.selectIndexPaths.firstIndex(where: {$0 == el.1}) {
                    vc.selectIndexPaths.remove(at: idx)
                }
            }
        }
    }
}
