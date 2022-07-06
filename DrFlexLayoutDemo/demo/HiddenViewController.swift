//
//  HiddenViewController.swift
//  DrFlexLayoutDemo
//
//  Created by dr.box on 2022/7/6.
//

import UIKit
import DrFlexLayout
import RxSwift
import RxCocoa

class HiddenViewController: UIViewController {

    override func loadView() {
        let v = UIView()
        v.dr_flex.justifyContent(.center).alignItems(.center).define { flex in
            flex.addItem()
                .direction(.row)
                .paddingVertical(30)
                .paddingHorizontal(30)
                .alignItems(.center)
                .width(100%)
                .backgroundColor(.white)
                .define { flex in
                    flex.addItem(firstView).size(50).marginRight(20)
                        .cornerRadius(radius: 10)
                        .justifyContent(.center)
                        .alignItems(.center)
                        .backgroundColor(.orange)
                        .define { flex in
                            flex.addItem(UILabel()).define { flex in
                                let lb = flex.view as! UILabel
                                lb.text = "A"
                                lb.font = .systemFont(ofSize: 20, weight: .bold)
                                lb.textColor = .white
                            }
                        }
                    
                    flex.addItem(secondView).size(50).marginRight(20)
                        .cornerRadius(radius: 10)
                        .justifyContent(.center)
                        .alignItems(.center)
                        .backgroundColor(.orange)
                        .define { flex in
                            flex.addItem(UILabel()).define { flex in
                                let lb = flex.view as! UILabel
                                lb.text = "B"
                                lb.font = .systemFont(ofSize: 20, weight: .bold)
                                lb.textColor = .white
                            }
                        }
                    
                    flex.addItem(thirdView).size(50).marginRight(20)
                        .cornerRadius(radius: 10)
                        .justifyContent(.center)
                        .alignItems(.center)
                        .backgroundColor(.orange)
                        .define { flex in
                            flex.addItem(UILabel()).define { flex in
                                let lb = flex.view as! UILabel
                                lb.text = "C"
                                lb.font = .systemFont(ofSize: 20, weight: .bold)
                                lb.textColor = .white
                            }
                        }
                }
            
            flex.addItem()
                .direction(.row)
                .paddingVertical(30)
                .paddingHorizontal(30)
                .alignItems(.center)
                .width(100%)
                .marginTop(20)
                .backgroundColor(.white)
                .define { flex in
                    flex.addItem(label1)
                    flex.addItem(label2).marginLeft(10)
                    flex.addItem(label3).marginLeft(10)
                }
            
            flex.addItem()
                .direction(.row)
                .alignItems(.center)
                .justifyContent(.spaceBetween)
                .paddingHorizontal(30)
                .width(100%)
                .marginTop(50)
                .define { flex in
                    flex.addItem(btn1).size(40)
                    flex.addItem(btn2).size(40)
                    flex.addItem(btn3).size(40)
                }
        }
        view = v
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.dr_flex.layout()
    }
    
    
    private var refreshView: Binder<Void> {
        Binder(self) { (vc, _) in
            vc.view.setNeedsLayout()
        }
    }
    
    private var firstViewHidden: Binder<Bool> {
        Binder(self) { (vc, isHidden) in
            vc.firstView.dr_flex.display(!isHidden)
//            vc.firstView.dr_flex.display(isHidden ? .none : .flex)
            vc.label1.dr_flex.isHidden = isHidden // size = zero
//            vc.label1.isHidden = isHidden // size != zero
//            vc.label1.dr_flex.display(isHidden ? .none : .flex)
        }
    }
    
    private var secondViewHidden: Binder<Bool> {
        Binder(self) { (vc, isHidden) in
            vc.secondView.dr_flex.display(!isHidden)
//            vc.secondView.dr_flex.display(isHidden ? .none : .flex)
            vc.label2.dr_flex.isHidden = isHidden // size = zero
//            vc.label2.isHidden = isHidden // size != zero
//            vc.label2.dr_flex.display(isHidden ? .none : .flex)
        }
    }
    
    private var thirdViewHidden: Binder<Bool> {
        Binder(self) { (vc, isHidden) in
            vc.thirdView.dr_flex.display(!isHidden)
//            vc.thirdView.dr_flex.display(isHidden ? .none : .flex)
            vc.label3.dr_flex.isHidden = isHidden // size = zero
//            vc.label3.isHidden = isHidden // size != zero
//            vc.label3.dr_flex.display(isHidden ? .none : .flex)
        }
    }

    private let firstView = UIView()
    private let secondView = UIView()
    private let thirdView = UIView()
    
    private let label1: UILabel = {
        let lb = UILabel()
        lb.text = "第一个文本"
        lb.font = .systemFont(ofSize: 15, weight: .bold)
        lb.textColor = .orange
        return lb
    }()
    
    private let label2: UILabel = {
        let lb = UILabel()
        lb.text = "第二个文本"
        lb.font = .systemFont(ofSize: 15, weight: .bold)
        lb.textColor = .blue
        return lb
    }()
    
    private let label3: UILabel = {
        let lb = UILabel()
        lb.text = "第三个文本"
        lb.font = .systemFont(ofSize: 15, weight: .bold)
        lb.textColor = .green
        return lb
    }()
    
    private lazy var btn1: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("隐藏", for: .normal)
        btn.setTitle("显示", for: .selected)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        btn.backgroundColor = .blue
        btn.layer.cornerRadius = 8
        let obs = btn.rx.tap.map({[unowned btn] _ in !btn.isSelected}).share(replay: 1, scope: .forever)
        obs.bind(to: btn.rx.isSelected).disposed(by: disposeBag)
        obs.bind(to: firstViewHidden).disposed(by: disposeBag)
//        obs.bind(to: firstView.dr_flex.rx.isHidden).disposed(by: disposeBag)
        obs.map({_ in ()}).bind(to: refreshView).disposed(by: disposeBag)
        return btn
    }()
    
    private lazy var btn2: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("隐藏", for: .normal)
        btn.setTitle("显示", for: .selected)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        btn.backgroundColor = .blue
        btn.layer.cornerRadius = 8
        let obs = btn.rx.tap.map({[unowned btn] _ in !btn.isSelected}).share(replay: 1, scope: .forever)
        obs.bind(to: btn.rx.isSelected).disposed(by: disposeBag)
        obs.bind(to: secondViewHidden).disposed(by: disposeBag)
//        obs.bind(to: secondView.dr_flex.rx.isHidden).disposed(by: disposeBag)
        obs.map({_ in ()}).bind(to: refreshView).disposed(by: disposeBag)
        return btn
    }()
    
    private lazy var btn3: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("隐藏", for: .normal)
        btn.setTitle("显示", for: .selected)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        btn.backgroundColor = .blue
        btn.layer.cornerRadius = 8
        let obs = btn.rx.tap.map({[unowned btn] _ in !btn.isSelected}).share(replay: 1, scope: .forever)
        obs.bind(to: btn.rx.isSelected).disposed(by: disposeBag)
        obs.bind(to: thirdViewHidden).disposed(by: disposeBag)
        obs.map({_ in ()}).bind(to: refreshView).disposed(by: disposeBag)
        return btn
    }()
    
    var disposeBag = DisposeBag()
}
