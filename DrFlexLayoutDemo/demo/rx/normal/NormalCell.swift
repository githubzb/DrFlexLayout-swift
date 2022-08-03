//
//  NormalCell.swift
//  DrFlexLayoutDemo
//
//  Created by dr.box on 2022/8/3.
//

import UIKit
import DrFlexLayout

class NormalCell: UIView {
    
    private func layoutUI() {
        dr_flex.paddingVertical(20).paddingHorizontal(15).define { flex in
            flex.addItem(UILabel()).define { flex in
                let lb = flex.view as! UILabel
                lb.text = model.title
                lb.font = .systemFont(ofSize: 15, weight: .semibold)
                lb.textColor = .black
            }
            flex.addItem(UILabel()).marginTop(8).define { flex in
                let lb = flex.view as! UILabel
                lb.text = model.subTitle
                lb.font = .systemFont(ofSize: 15, weight: .semibold)
                lb.textColor = .lightGray
                lb.numberOfLines = 0
            }
        }
    }

    init(viewModel: NormalCellViewModel) {
        self.model = viewModel
        super.init(frame: .zero)
        layoutUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let model: NormalCellViewModel
}

struct NormalCellViewModel {
    
    let title: String
    let subTitle: String
}
