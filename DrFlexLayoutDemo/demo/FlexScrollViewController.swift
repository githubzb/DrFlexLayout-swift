//
//  FlexScrollViewController.swift
//  DrFlexLayoutDemo
//
//  Created by DHY on 2021/11/23.
//

import UIKit
import DrFlexLayout

class FlexScrollViewController: UIViewController {

    var scrollView: DrFlexScrollView {
        view as! DrFlexScrollView
    }
    
    override func loadView() {
        view = DrFlexScrollView(direction: .vertical, itemAlign: .center)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.addContentSubview(UIView()).dr_flex.width(80%).height(100).backgroundColor(.blue)
        scrollView.addContentSubview(UIView()).dr_flex.width(80%).marginTop(20).cornerRadius(radius: 10).padding(15).alignItems(.center).justifyContent(.center).define { flex in
            flex.view?.backgroundColor = .blue
            flex.addItem(UILabel()).define { flex in
                let lb = flex.view as? UILabel
                lb?.text = "这里是文本内容"
                lb?.textColor = .white
                lb?.font = .systemFont(ofSize: 15, weight: .semibold)
            }
        }
    }
    
}
