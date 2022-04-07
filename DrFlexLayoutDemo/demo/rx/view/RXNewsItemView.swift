//
//  RXNewsItemView.swift
//  DrFlexLayoutDemo
//
//  Created by dr.box on 2022/4/4.
//

import UIKit
import DrFlexLayout
import Kingfisher

class RXNewsItemView: UIView {

    let model: RxNewsItem
    let section: Int
    let row: Int
    
    init(model: RxNewsItem, section: Int, row: Int) {
        self.model = model
        self.section = section
        self.row = row
        super.init(frame: .zero)
        backgroundColor = .white
        layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layoutUI(){
        dr_flex.paddingHorizontal(15).direction(.row).paddingTop(30).define { flex in
            flex.addItem(UIImageView()).size(CGSize(width: 120, height: 80)).define { flex in
                let imgView = flex.view as! UIImageView
                imgView.contentMode = .scaleAspectFill
                imgView.clipsToBounds = true
                imgView.kf.setImage(with: model.icon)
            }
            flex.addItem().paddingLeft(8).paddingTop(8).flex(1).define { flex in
                flex.addItem(UILabel()).define { flex in
                    let lb = flex.view as! UILabel
                    lb.text = model.title
                    lb.textColor = .black
                    lb.font = .systemFont(ofSize: 15, weight: .bold)
                    lb.numberOfLines = 2
                }
                flex.addItem(UILabel()).marginTop(12).define { flex in
                    let lb = flex.view as! UILabel
                    lb.text = model.subTitle
                    lb.textColor = .lightGray
                    lb.font = .systemFont(ofSize: 12, weight: .regular)
                    lb.numberOfLines = 0
                }
            }
        }
    }
    
}
