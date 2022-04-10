//
//  ViewController.swift
//  DrFlexLayoutDemo
//
//  Created by dr.box on 2021/10/11.
//

import UIKit
import DrFlexLayout

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Flex Layout"
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.dr_flex.layout()
    }
    
    override func loadView() {
        let v = UIView()
        v.backgroundColor = .white
        v.dr_flex.justifyContent(.center).alignItems(.center).define { flex in
            flex.addItem(UIButton(type: .custom)).width(150).height(34).define { flex in
                if let btn = flex.view as? UIButton {
                    btn.setTitle("基础使用篇", for: .normal)
                    btn.setTitleColor(.white, for: .normal)
                    btn.backgroundColor = .blue
                    btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
                    btn.addTarget(self, action: #selector(clickNormal(_:)), for: .touchUpInside)
                }
            }
            
            flex.addItem(UIButton(type: .custom)).width(150).height(34).marginTop(10).define { flex in
                if let btn = flex.view as? UIButton {
                    btn.setTitle("Style使用篇", for: .normal)
                    btn.setTitleColor(.white, for: .normal)
                    btn.backgroundColor = .blue
                    btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
                    btn.addTarget(self, action: #selector(clickStyle(_:)), for: .touchUpInside)
                }
            }

            flex.addItem(UIButton(type: .custom)).width(150).height(34).marginTop(10).define { flex in
                if let btn = flex.view as? UIButton {
                    btn.setTitle("TableView1", for: .normal)
                    btn.setTitleColor(.white, for: .normal)
                    btn.backgroundColor = .blue
                    btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
                    btn.addTarget(self, action: #selector(clickTableView(_:)), for: .touchUpInside)
                }
            }
            
            flex.addItem(UIButton(type: .custom)).width(150).height(34).marginTop(10).define { flex in
                if let btn = flex.view as? UIButton {
                    btn.setTitle("TableView2", for: .normal)
                    btn.setTitleColor(.white, for: .normal)
                    btn.backgroundColor = .blue
                    btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
                    btn.addTarget(self, action: #selector(clickTableView2(_:)), for: .touchUpInside)
                }
            }
            
            flex.addItem(UIButton(type: .custom)).width(150).height(34).marginTop(10).define { flex in
                if let btn = flex.view as? UIButton {
                    btn.setTitle("ScrollView", for: .normal)
                    btn.setTitleColor(.white, for: .normal)
                    btn.backgroundColor = .blue
                    btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
                    btn.addTarget(self, action: #selector(clickScrollView(_:)), for: .touchUpInside)
                }
            }
            
            flex.addItem(UIButton(type: .custom)).width(150).height(34).marginTop(10).define { flex in
                if let btn = flex.view as? UIButton {
                    btn.setTitle("RemoveView", for: .normal)
                    btn.setTitleColor(.white, for: .normal)
                    btn.backgroundColor = .blue
                    btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
                    btn.addTarget(self, action: #selector(clickRemoveView(_:)), for: .touchUpInside)
                }
            }
            
            flex.addItem(UIButton(type: .custom)).width(150).height(34).marginTop(10).define { flex in
                if let btn = flex.view as? UIButton {
                    btn.setTitle("RxTableView", for: .normal)
                    btn.setTitleColor(.white, for: .normal)
                    btn.backgroundColor = .blue
                    btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
                    btn.addTarget(self, action: #selector(clickRxTableView(_:)), for: .touchUpInside)
                }
            }
            
            flex.addItem(UIButton(type: .custom)).width(150).height(34).marginTop(10).define { flex in
                if let btn = flex.view as? UIButton {
                    btn.setTitle("BubbleView", for: .normal)
                    btn.setTitleColor(.white, for: .normal)
                    btn.backgroundColor = .blue
                    btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
                    btn.addTarget(self, action: #selector(clickBubbleView(_:)), for: .touchUpInside)
                }
            }
            
        }
        view = v
    }
    
    @objc private func clickNormal(_ btn: UIButton){
        let vc = NormalViewController()
        vc.title = btn.title(for: .normal)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func clickStyle(_ btn: UIButton){
        let vc = StyleViewController()
        vc.title = btn.title(for: .normal)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func clickTableView(_ btn: UIButton){
        let vc = FlexTableViewController()
        vc.title = btn.title(for: .normal)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func clickTableView2(_ btn: UIButton){
        let vc = FlexTableViewController2()
        vc.title = btn.title(for: .normal)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func clickScrollView(_ btn: UIButton){
        let vc = FlexScrollViewController()
        vc.title = btn.title(for: .normal)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func clickRemoveView(_ btn: UIButton) {
        let vc = RemoveViewController()
        vc.title = btn.title(for: .normal)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func clickRxTableView(_ btn: UIButton) {
        let vc = RXTableViewController()
        vc.title = btn.title(for: .normal)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func clickBubbleView(_ btn: UIButton) {
        let vc = BubbleViewController()
        vc.title = btn.title(for: .normal)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

