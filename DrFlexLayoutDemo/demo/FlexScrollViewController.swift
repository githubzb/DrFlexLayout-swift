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
        view = DrFlexScrollView(direction: .vertical, itemAlign: .stretch)
        view.backgroundColor = .hexColor("#F3F3F3")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "刷新", style: .plain, target: self, action: #selector(refresh))
        
        for i in 1...10 {
            let item = ScrollItemView(item: ScrollItem(title: "热门游戏(\(i))", list: [GameItem(title: "植物大战", price: "10元"),
                                                                                  GameItem(title: "欢乐豆", price: "8元"),
                                                                                  GameItem(title: "雷霆战机", price: "10元"),
                                                                                  GameItem(title: "贪吃蛇", price: "5元")]))
            scrollView.addContentSubview(item).dr_flex.marginHorizontal(15).marginBottom(20).cornerRadius(radius: 10).shadow(offset: CGSize(width: 1, height: 1),
                                                                                                                             blurRadius: 6,
                                                                                                                             color: .black,
                                                                                                                             opacity: 0.1)
        }
    }
    
    @objc func refresh() {
        
        scrollView.contentSubviews.forEach({$0.removeFromSuperview()})
        for i in 1...5 {
            let item = ScrollItemView(item: ScrollItem(title: "推荐游戏(\(i))", list: [GameItem(title: "游戏名称", price: "3元"),
                                                                                  GameItem(title: "游戏名称", price: "5元"),
                                                                                  GameItem(title: "游戏名称", price: "2元"),
                                                                                  GameItem(title: "游戏名称", price: "1元")]))
            scrollView.addContentSubview(item).dr_flex.marginHorizontal(15).marginBottom(20).cornerRadius(radius: 10).shadow(offset: CGSize(width: 1, height: 1),
                                                                                                                             blurRadius: 6,
                                                                                                                             color: .black,
                                                                                                                             opacity: 0.1)
        }
        scrollView.setNeedsLayout()
    }
    
}


struct ScrollItem {
    let title: String
    let list: [GameItem]
}

struct GameItem {
    let title: String
    let price: String
}

class ScrollItemView: UIView {
    
    init(item: ScrollItem) {
        super.init(frame: .zero)
        backgroundColor = .white
        
        dr_flex.padding(15).define { flex in
            // 顶部
            flex.addItem().direction(.row).alignItems(.center).define { flex in
                flex.addItem(UILabel()).flex(1).define { flex in
                    let lb = flex.view as? UILabel
                    lb?.text = item.title
                    lb?.textColor = .black
                    lb?.font = .systemFont(ofSize: 16, weight: .semibold)
                }
                flex.addItem().size(CGSize(width: 80, height: 34)).direction(.row).alignItems(.center).justifyContent(.end).define { flex in
                    flex.addItem(UILabel()).define { flex in
                        let lb = flex.view as? UILabel
                        lb?.text = "更多"
                        lb?.textColor = .hexColor("#9E9D9D")
                        lb?.font = .systemFont(ofSize: 12, weight: .regular)
                    }
                    flex.addItem(UIImageView(image: UIImage(named: "arrow"))).size(CGSize(width: 7, height: 11)).marginLeft(8)
                }
            }
            // 内容
            flex.addItem().marginTop(18).direction(.row).justifyContent(.spaceAround).define { flex in
                for game in item.list {
                    flex.addItem().alignItems(.center).define { flex in
                        flex.addItem().size(58).cornerRadius(radius: 8).backgroundColor(.orange)
                        flex.addItem(UILabel()).marginTop(4).define { flex in
                            let lb = flex.view as? UILabel
                            lb?.text = game.title
                            lb?.textColor = .hexColor("#9E9D9D")
                            lb?.font = .systemFont(ofSize: 12, weight: .regular)
                        }
                        flex.addItem(UILabel()).marginTop(2).define { flex in
                            let lb = flex.view as? UILabel
                            lb?.text = game.price
                            lb?.textColor = .hexColor("#FD2C1C")
                            lb?.font = .systemFont(ofSize: 10, weight: .regular)
                        }
                    }
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
