//
//  RXNewsHeaderView.swift
//  DrFlexLayoutDemo
//
//  Created by dr.box on 2022/4/4.
//

import UIKit
import DrFlexLayout

class RXNewsHeaderView: UIView {
    
    let type: RxNewsType
    
    init(type: RxNewsType) {
        self.type = type
        super.init(frame: .zero)
        backgroundColor = .white
        layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layoutUI(){
        dr_flex.paddingHorizontal(15).paddingVertical(10).define { flex in
            flex.addItem(UILabel()).define { flex in
                let lb = flex.view as! UILabel
                lb.text = "\(type)"
                lb.textColor = .black
                lb.font = .systemFont(ofSize: 15, weight: .bold)
            }
        }
    }
}
