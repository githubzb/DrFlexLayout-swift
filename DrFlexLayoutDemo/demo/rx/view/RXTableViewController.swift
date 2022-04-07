//
//  RXTableViewController.swift
//  DrFlexLayoutDemo
//
//  Created by dr.box on 2022/4/4.
//

import UIKit
import DrFlexLayout
import RxSwift
import ReactorKit

class RXTableViewController: UIViewController, View {
    
    typealias Reactor = RxTableViewModel
    typealias DataSource = DrTableDataSource<Item>
    
    var disposeBag = DisposeBag()
    private var table: DrFlexTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configUI()
        reactor = RxTableViewModel()
        reactor?.action.onNext(.reloadData)
    }
    
    private func configUI() {
        table = DrFlexTableView(style: .plain)
        view.addSubview(table)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        table.frame = view.bounds
    }
    
    func bind(reactor: RxTableViewModel) {
        let dataSource = DataSource { [weak self] (item, indexPath) in
            switch item {
            case .news(let model):
                return RXNewsItemView(model: model, section: indexPath.section, row: indexPath.row)
            case let .loadMore(hasMoreData, type):
                let cell = DRLoadMoreCellView(item: item, type: type, hasMore: hasMoreData, section: indexPath.section)
                if let reactor = self?.reactor {
                    cell.loadMore
                        .map({Reactor.Action.loadMore(type: $0.type, section: $0.section)})
                        .bind(to: reactor.action)
                        .disposed(by: cell.disposeBag)
                }
                return cell
            }
        } headerBuilder: { item, section in
            RXNewsHeaderView(type: item.header()!)
        }

        table.rx.items(dataSource)(reactor.state.map(\.source))
            .disposed(by: disposeBag)
        
        // 绑定点击事件
        dataSource.cellClick.bind(to: clickCell).disposed(by: disposeBag)
    }
    
    
    var clickCell: Binder<(item: Item, indexPath: IndexPath)> {
        Binder(self) { (vc, tuple) in
            print("----click section: \(tuple.indexPath.section), row: \(tuple.indexPath.row)")
            if case let .news(news) = tuple.item {
                print("----item.title: \(news.title)")
            }
        }
    }
    
}
