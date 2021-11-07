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
            
            var gradient = DrGradientStyle(colors: [UIColor.red, UIColor.green, UIColor.orange],
                                           locations: [0, 0.4, 0.6])
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 1)
            flex.addItem(self.rectView)
                .size(CGSize(width: 200, height: 100))
                .cornerRadius(topLeft: 20, topRight: 0, bottomLeft: 0, bottomRight: 20)
                .border(width: 2, color: .blue)
                .gradient(style: gradient)
                .shadow(offset: CGSize(width: 0, height: 2), blurRadius: 5, color: .black, opacity: 0.5)
            
            flex.addItem(UIButton(type: .custom)).size(CGSize(width: 120, height: 30)).marginTop(10).define { flex in
                if let btn = flex.view as? UIButton {
                    btn.setTitle("更新1", for: .normal)
                    btn.setTitleColor(.white, for: .normal)
                    btn.backgroundColor = .blue
                    btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
                    btn.addTarget(self, action: #selector(clickBtn), for: .touchUpInside)
                }
            }
            
            flex.addItem(UIButton(type: .custom)).size(CGSize(width: 120, height: 30)).marginTop(10).define { flex in
                if let btn = flex.view as? UIButton {
                    btn.setTitle("更新2", for: .normal)
                    btn.setTitleColor(.white, for: .normal)
                    btn.backgroundColor = .blue
                    btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
                    btn.addTarget(self, action: #selector(clickBtn2), for: .touchUpInside)
                }
            }
        }
        view = v
    }
    
    @objc func clickBtn(){
        
        var style = DrStyle()
        style.round = DrRoundStyle(topLeft: 0, topRight: 20, bottomLeft: 20, bottomRight: 0)
        style.border = DrBorderStyle(width: 2, color: .red)
        style.shadow = DrShadowStyle(offset: CGSize(width: 0, height: 2), blurRadius: 5, color: .red, opacity: 0.5)
        
        self.rectView.dr_flex.style(style)
        
        view.dr_flex.layout()
    }
    
    @objc func clickBtn2(){
        
        var style = DrStyle()
        style.round = DrRoundStyle(radius: 20)
        style.border = DrBorderStyle(width: 2, color: .red)
        style.shadow = DrShadowStyle(offset: CGSize(width: 0, height: 2), blurRadius: 5, color: .black, opacity: 0.5)
        self.rectView.dr_buildStyle(style: style)
    }

}
