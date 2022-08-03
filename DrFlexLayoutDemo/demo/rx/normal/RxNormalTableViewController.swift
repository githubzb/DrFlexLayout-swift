//
//  RxNormalTableViewController.swift
//  DrFlexLayoutDemo
//
//  Created by dr.box on 2022/8/3.
//

import UIKit
import DrFlexLayout
import ReactorKit
import RxSwift
import RxCocoa

class RxNormalTableViewController: UIViewController, View {
    
    
    @objc func clickRefreshBtn() {
        reactor?.action.onNext(.reloadData)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(listView)
        reactor = NormalReactor()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "刷新", style: .plain, target: self, action: #selector(clickRefreshBtn))
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        listView.frame = view.bounds
    }

    
    typealias Reactor = NormalReactor
    
    var disposeBag = DisposeBag()
    private let listView: DrFlexTableView = {
        let table = DrFlexTableView(style: .plain)
        table.separatorInset = .init(top: 0, left: 15, bottom: 0, right: 15)
        table.separatorStyle = .singleLine
        table.backgroundColor = .white
        return table
    }()
    
}

// MARK: - Binding
extension RxNormalTableViewController {
    
    func bind(reactor: NormalReactor) {
        let dataSource = DrTableDataSource<NormalCellViewModel> { item, indexPath in
            NormalCell(viewModel: item)
        }
        listView.rx.items(dataSource)(reactor.state.map(\.items)).disposed(by: disposeBag)
    }
}
