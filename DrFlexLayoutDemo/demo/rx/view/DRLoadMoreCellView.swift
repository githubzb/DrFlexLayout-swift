//
//  DRLoadMoreCellView.swift
//  DrFlexLayoutDemo
//
//  Created by dr.box on 2022/4/4.
//

import UIKit
import DrFlexLayout
import RxCocoa
import RxSwift

class DRLoadMoreCellView: UIView, DrTableCellUpdateable {
    
    var disposeBag = DisposeBag()
    let loadMore = PublishSubject<(item: Item, section: Int, type: RxNewsType)>()
    var item: Item
    var type: RxNewsType
    var hasMore: Bool
    var section: Int
    
    init(item: Item, type: RxNewsType, hasMore: Bool, section: Int) {
        self.item = item
        self.type = type
        self.hasMore = hasMore
        self.section = section
        super.init(frame: .zero)
        backgroundColor = .white
        layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateItem(item: Any, indexPath: IndexPath) -> Bool {
        if case let .loadMore(hasMoreData, type) = convertItemType(item, type: Item.self) {
            self.hasMore = hasMoreData
            self.type = type
            self.item = convertItemType(item, type: Item.self)
            self.section = indexPath.section
            layoutUI()
            return true
        }
        return false
    }
    
    private func layoutUI() {
        subviews.forEach({$0.dr_flex.removeFromSuperview()})
        dr_flex.height(44).justifyContent(.center).alignItems(.center).define { flex in
            if hasMore {
                flex.addItem(UIButton(type: .custom)).height(40).width(80%).define { flex in
                    let btn = flex.view as! UIButton
                    btn.setTitle("加载更多", for: .normal)
                    btn.setTitleColor(.orange, for: .normal)
                    btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
                    btn.rx.tap.map({[unowned self] in (item: self.item, section: self.section, type: self.type)})
                        .bind(to: self.loadMore)
                        .disposed(by: disposeBag)
                }
            }else {
                flex.addItem(UILabel()).define { flex in
                    let lb = flex.view as! UILabel
                    lb.text = "没有更多数据了"
                    lb.textColor = .black
                    lb.font = .systemFont(ofSize: 14, weight: .regular)
                }
            }
        }
    }
}
