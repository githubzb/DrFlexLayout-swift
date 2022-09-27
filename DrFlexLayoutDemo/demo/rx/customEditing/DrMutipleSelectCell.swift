//
//  DrMutipleSelectCell.swift
//  DrFlexLayoutDemo
//
//  Created by dr.box on 2022/9/25.
//

import UIKit
import DrFlexLayout
import RxSwift
import RxCocoa
import SwiftUI

class DrMutipleSelectCell: UIView {

    private func layoutUI() {
        dr_flex.addItem(containerView).paddingHorizontal(20).alignItems(.center).direction(.row).define { flex in
            flex.addItem(contentView).height(60).justifyContent(.center).flex(1).define { flex in
                flex.addItem(UILabel()).define { flex in
                    let lb = flex.view as! UILabel
                    lb.text = title
                    lb.font = .systemFont(ofSize: 15, weight: .regular)
                    lb.textColor = .black
                }
            }
        }
    }
    
    init(title: String, indexPath: IndexPath){
        self.title = title
        self.indexPath = indexPath
        super.init(frame: .zero)
        backgroundColor = .white
        layoutUI()
        let tap = selectBtn.rx.tap.map({[unowned self] _ -> Bool in !self.selectBtn.isSelected}).share(replay: 1, scope: .forever)
        tap.bind(to: selectBtn.rx.isSelected)
            .disposed(by: disposeBag)
        tap.map({[unowned self] in ($0, self.indexPath)}).bind(to: selected).disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let containerView = UIView()
    private let contentView = UIView()
    private let selectBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "checkbox"), for: .selected)
        btn.setImage(UIImage(named: "uncheckbox"), for: .normal)
        return btn
    }()
    
    var indexPath: IndexPath
    let title: String
    let selected = PublishRelay<(Bool, IndexPath)>()
    let disposeBag = DisposeBag()
    var isEditing: Bool = false
}

extension DrMutipleSelectCell: DrTableCellUpdateable {
    
    func updateItem(item: Any, indexPath: IndexPath) -> Bool {
        self.indexPath = indexPath
        return false
    }
}

extension DrMutipleSelectCell: DrCellEditing {
    
    func setEditing(_ isEditing: Bool, animated: Bool) {
        self.isEditing = isEditing
        containerView.subviews.forEach({$0.dr_flex.removeFromSuperview()})
        if isEditing {
            containerView.dr_flex.addItem(selectBtn)
                .size(width: 30, height: 30)
                .marginRight(15)
        }else {
            selectBtn.isSelected = false
        }
        containerView.dr_flex.addItem(contentView)
        if superview != nil {
            UIView.animate(withDuration: animated ? 0.23 : 0, delay: 0, options: [.curveEaseInOut]) {
                self.containerView.dr_flex.layout()
            } completion: { _ in}
        }
    }
}
