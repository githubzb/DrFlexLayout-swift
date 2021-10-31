//
//  StyleViewController.swift
//  DrFlexLayoutDemo
//
//  Created by dr.box on 2021/10/31.
//

import UIKit
import DrFlexLayout

class StyleViewController: UIViewController {
    
    private let rectView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.dr_flex.layoutByAsync()
    }
    
    override func loadView() {
        let v = UIView()
        v.backgroundColor = .white
        v.dr_flex.justifyContent(.center).alignItems(.center).define { flex in
            var style = DrStyle()
//            style.round = DrRoundStyle(topLeft: 20, topRight: 0, bottomLeft: 0, bottomRight: 20)
//            var gradient = DrGradientStyle()
//            gradient.colors = [UIColor.red.cgColor, UIColor .green.cgColor, UIColor.blue.cgColor]
//            gradient.startPoint = CGPoint(x: 0, y: 1)
//            gradient.endPoint = CGPoint(x: 1, y: 1)
//            style.gradient = gradient
            style.border = DrBorderStyle(width: 2)
            
            flex.addItem(self.rectView).size(CGSize(width: 200, height: 100)).style(style)
            
            flex.addItem(UIButton(type: .custom)).size(CGSize(width: 120, height: 30)).marginTop(10).define { flex in
                if let btn = flex.view as? UIButton {
                    btn.setTitle("更新", for: .normal)
                    btn.setTitleColor(.white, for: .normal)
                    btn.backgroundColor = .blue
                    btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
                    btn.addTarget(self, action: #selector(clickBtn), for: .touchUpInside)
                }
            }
        }
        view = v
    }
    
    @objc func clickBtn(){
        
        var style = DrStyle(cornerRadius: 20)
//        var style = DrStyle()
        style.shadow = DrShadowStyle(offset: CGSize(width: 3, height: 3), blurRadius: 20, color: .black, opacity: 0.5)
//        style.round = DrRoundStyle(topLeft: 0, topRight: 20, bottomLeft: 20, bottomRight: 0)
        var gradient = DrGradientStyle()
        gradient.colors = [UIColor.red.cgColor, UIColor .green.cgColor, UIColor.blue.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 1)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        style.gradient = gradient
        
        self.rectView.dr_flex.style(style)
        
        view.dr_flex.layout()
    }

}
