//
//  BubbleViewController.swift
//  DrFlexLayoutDemo
//
//  Created by dr.box on 2022/4/10.
//

import UIKit
import DrFlexLayout

class BubbleViewController: UIViewController {
    
    let bubbleView = BubbleLabel(text: "这里是气泡内容，你想这在里展示写什么？或是提示一些什么？由你决定。")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.dr_flex.justifyContent(.center).alignItems(.center).define { flex in
            
            flex.addItem(bubbleView).maxWidth(150).cornerRadius(radius: 10)
            
            flex.addItem().direction(.row).marginTop(20).justifyContent(.spaceEvenly).define { flex in
                flex.addItem(UIButton(type: .custom)).size(CGSize(width: 80, height: 40))
                    .cornerRadius(radius: 20)
                    .marginTop(20)
                    .define { flex in
                        let btn = flex.view as! UIButton
                        btn.setTitle("上", for: .normal)
                        btn.setTitleColor(.white, for: .normal)
                        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
                        btn.backgroundColor = .red
                        btn.addTarget(self, action: #selector(clickTopBtn), for: .touchUpInside)
                    }
                
                flex.addItem(UIButton(type: .custom)).size(CGSize(width: 80, height: 40))
                    .cornerRadius(radius: 20)
                    .marginTop(20)
                    .define { flex in
                        let btn = flex.view as! UIButton
                        btn.setTitle("右", for: .normal)
                        btn.setTitleColor(.white, for: .normal)
                        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
                        btn.backgroundColor = .red
                        btn.addTarget(self, action: #selector(clickRightBtn), for: .touchUpInside)
                    }
                
                flex.addItem(UIButton(type: .custom)).size(CGSize(width: 80, height: 40))
                    .cornerRadius(radius: 20)
                    .marginTop(20)
                    .define { flex in
                        let btn = flex.view as! UIButton
                        btn.setTitle("下", for: .normal)
                        btn.setTitleColor(.white, for: .normal)
                        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
                        btn.backgroundColor = .red
                        btn.addTarget(self, action: #selector(clickBottomBtn), for: .touchUpInside)
                    }
                
                flex.addItem(UIButton(type: .custom)).size(CGSize(width: 80, height: 40))
                    .cornerRadius(radius: 20)
                    .marginTop(20)
                    .define { flex in
                        let btn = flex.view as! UIButton
                        btn.setTitle("左", for: .normal)
                        btn.setTitleColor(.white, for: .normal)
                        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
                        btn.backgroundColor = .red
                        btn.addTarget(self, action: #selector(clickLeftBtn), for: .touchUpInside)
                    }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.dr_flex.layout()
    }
    
    
    @objc func clickTopBtn() {
        bubbleView.arrowDirection = .top
        bubbleView.arrowPosition = 0.8
        view.dr_flex.layout()
    }
    
    @objc func clickRightBtn() {
        bubbleView.arrowDirection = .right
        bubbleView.arrowPosition = 0.8
        view.dr_flex.layout()
    }
    
    @objc func clickBottomBtn() {
        bubbleView.arrowDirection = .bottom
        bubbleView.arrowPosition = 0.2
        view.dr_flex.layout()
    }
    
    @objc func clickLeftBtn() {
        bubbleView.arrowDirection = .left
        bubbleView.arrowPosition = 0.2
        view.dr_flex.layout()
    }
    
}


// 气泡1
class BubbleLabel: BubbleView {
    
    let label: UILabel = {
        let lb = UILabel()
        lb.textColor = .white
        lb.font = .systemFont(ofSize: 14, weight: .regular)
        lb.numberOfLines = 0
        return lb
    }()
    
    override var arrowDirection: ArrowDirection {
        didSet {
            layoutUI()
        }
    }
    
    override var arrowSize: CGSize {
        didSet {
            layoutUI()
        }
    }
    
    init(text: String) {
        super.init(frame: .zero)
        self.label.text = text
        self.backgroundColor = .red
        layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layoutUI() {
        dr_flex.alignItems(.center).padding(8).define { flex in
            switch arrowDirection {
            case .right:
                flex.addItem(label).margin(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: arrowSize.height))
                
            case .bottom:
                flex.addItem(label).margin(UIEdgeInsets(top: 0, left: 0, bottom: arrowSize.height, right: 0))
                
            case .left:
                flex.addItem(label).margin(UIEdgeInsets(top: 0, left: arrowSize.height, bottom: 0, right: 0))
                
            case .top:
                flex.addItem(label).margin(UIEdgeInsets(top: arrowSize.height, left: 0, bottom: 0, right: 0))
            }
        }
    }
}
