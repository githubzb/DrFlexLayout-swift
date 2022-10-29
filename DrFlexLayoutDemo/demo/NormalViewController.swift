//
//  NormalViewController.swift
//  DrFlexLayoutDemo
//
//  Created by dr.box on 2021/10/31.
//

import UIKit
import DrFlexLayout

class NormalViewController: UIViewController {

    override func loadView() {
        let v = UIView()
        v.dr_flex
            .justifyContent(.center)
            .alignItems(.center)
            .backgroundColor(.white)
            .define { flex in
                flex.addItem().width(50%).aspectRatio(1).backgroundColor(.orange).layoutFinished { v in
                    v?.layer.cornerRadius = (v?.bounds.height ?? 0.0) / 2.0
                }
                
                flex.addItem()
                    .size(CGSize(width: 200, height: 40))
                    .backgroundColor(.orange)
                    .alignItems(.center)
                    .direction(.row)
                    .define { flex in
                        let lb1 = UILabel()
                        lb1.font = .systemFont(ofSize: 15, weight: .medium)
                        lb1.textColor = .white
                        lb1.backgroundColor = .blue
                        lb1.text = "a text"
                        flex.addItem(lb1).flex(1).margin(8) // 与下面的组合效果一致
//                        flex.addItem(lb1).grow(1).shrink(0).basis(0).margin(8)
                        let lb2 = UILabel()
                        lb2.font = .systemFont(ofSize: 15, weight: .medium)
                        lb2.textColor = .white
                        lb2.backgroundColor = .blue
                        lb2.text = "this is label"
                        flex.addItem(lb2).flex(1).margin(8) // 与下面的组合效果一致
//                        flex.addItem(lb2).grow(1).shrink(0).basis(0).margin(8)
                    }
                
                flex.addItem()
                    .size(CGSize(width: 50, height: 50))
                    .marginTop(10)
                    .backgroundColor(.orange)
                    .borderWidth(10).define({ flex in
                        flex.addItem().flex(1).backgroundColor(.blue)
                    }).layoutFinished { v in
                        if let v = v {
                            print("----v.frame: \(v.frame)")
                        }
                    }
                
            }
        view = v
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(otherView) // 添加非flex布局视图，不受flex的影响
        otherView.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        otherView.backgroundColor = .green
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
//        view.dr_flex.layout()
        view.dr_flex.layoutByAsync()
        
    }
    
    private let otherView = OtherView()
}

class OtherView: UIView {
    
    private func layoutUI() {
        v.dr_flex.justifyContent(.center).alignItems(.center).define { flex in
            flex.addItem().size(30).backgroundColor(.red)
            flex.addItem().size(30).marginTop(10).backgroundColor(.orange)
        }
    }
    
    init() {
        super.init(frame: .zero)
        addSubview(v)
        layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        v.frame = bounds
        v.dr_flex.layout()
    }
    
    let v = UIView()
}

