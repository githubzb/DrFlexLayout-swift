//
//  RemoveViewController.swift
//  DrFlexLayoutDemo
//
//  Created by dr.box on 2022/3/31.
//

import UIKit
import DrFlexLayout

class RemoveViewController: UIViewController {
    
    let parentView = ParentView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btn = UIButton(type: .custom)
        btn.setTitle("刷新", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .blue
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        btn.frame = CGRect(x: 15, y: 100, width: 100, height: 40)
        btn.layer.cornerRadius = 20
        btn.addTarget(self, action: #selector(clickBtn), for: .touchUpInside)
        view.addSubview(btn)
        
        view.addSubview(parentView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.parentView.frame = CGRect(x: 0, y: 130, width: view.frame.width, height: view.frame.height - 130)
    }
    
    @objc private func clickBtn() {
        if let name = ["aaaaaaaaaaa", "bbbb", "ccccccccccccccccccccccc", "dddd"].randomElement() {
            let i = Int.random(in: 0..<100)
            self.parentView.update(name: name, count: i)
        }
    }

}

class ParentView: UIView {
    
    let name: UILabel = {
        let lb = UILabel()
        lb.textColor = .orange
        lb.backgroundColor = .green
        lb.font = .systemFont(ofSize: 14, weight: .regular)
        return lb
    }()
    
    let headerIcon: UIView = {
        let v = UIView()
        v.backgroundColor = .green
        return v
    }()
    
    let bgView: UIView = {
        let v = UIView()
        v.backgroundColor = .orange
        return v
    }()
    
    func update(name: String, count: Int) {
        
        subviews.forEach({$0.removeFromSuperview()})
        
        self.name.text = name
        self.name.dr_flex.markDirty()
        
        // self.name 父视图变化，可能为：self.bgView，也可能是：self
        // 此时如果只是简单的将视图移除关系，而其布局节点关系并没解除，则会导致如下错误，从而crash：
        // Child already has a owner, it must be removed first.
        
        dr_flex.justifyContent(.center).alignItems(.center).define { flex in
            if count % 2 == 0 {
                flex.addItem(self.bgView).width(100%).height(300).define { flex in
                    flex.addItem(self.headerIcon.dr_flex.removeFromSuperview()).size(40).cornerRadius(radius: 20)
                    flex.addItem(self.name.dr_flex.removeFromSuperview()).marginTop(10)
                }
            }else {
                flex.addItem(self.headerIcon.dr_flex.removeFromSuperview()).size(40).cornerRadius(radius: 20)
                flex.addItem(self.name.dr_flex.removeFromSuperview()).marginTop(10)
            }
        }
        
        dr_flex.layout()
    }
}
