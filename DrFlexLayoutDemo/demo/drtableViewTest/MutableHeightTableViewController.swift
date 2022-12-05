//
//  MutableHeightTableViewController.swift
//  DrFlexLayoutDemo
//
//  Created by admin on 2022/12/5.
//

import UIKit
import DrFlexLayout

class MutableHeightTableViewController: UIViewController {
    
    let tableView: DrTableView = {
        let table = DrTableView(style: .plain)
        table.separatorStyle = .singleLine
        table.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        table.backgroundColor = .hexColor("#F5F5F5")
        return table
    }()
    
    let list: [News] = [
        News(title: "特斯拉拒不向中国妥协，丰田却称中国最重要，又添黑马表诚意", content: "作为漂亮国品牌，特斯拉和苹果一样，从一开始就是定位高端，所以售价颇贵，但即便如此，其销量也一直很高。面对中国用户，特斯拉格外有底气，无论消费者怎么投诉，它也不做改变，甚至放言“决不向中国妥协”。"),
        News(title: "少年，还记得星辰大海的梦想吗？空间站上已经种出水稻了", content: "以前我给大家讲过，野生香蕉是不能吃的，人类培育的上一个可食用香蕉品质已经灭绝了，现在正在吃的这种香蕉也有可能灭绝。香蕉如此，人又何尝不是。人类虽然划分种群和肤色，但基因高度相近，在国际旅行越来越频繁的当今，一种突发性的严重疾病对全人类的威胁越来越大。"),
        News(title: "微信还有这骚操作！跟好友聊天“加密”，隐私内容仅双方能看懂", content: "今天跟大伙们分享手机上好玩的功能，还有很多人都不知道，其实微信聊天是可以“加密”的~。事情是这样子的，前段时间朋友跟小编讲了一个段子,希望自己的女朋友多锻炼，有的男孩子想到了一个点子，测试结果很有效。"),
        News(title: "腾讯、网易旗下多款游戏公告12月6日暂停服务一天", content: "12月5日，腾讯、网易等游戏企业相继发布游戏暂时停服公告。腾讯旗下《地下城与勇士》《英雄联盟》《英雄联盟手游》《王者荣耀》《天涯明月刀手游》等游戏发布12月6日停机停服公告，自12月6日00:00起停服1天。"),
        News(title: "太阳究竟用了什么“燃料”？为什么燃烧了几十亿年，依旧如此热烈", content: "太阳是绕着银河系的中心进行公转，在几十亿年间太阳始终如此温暖和热烈，究竟使用了什么“燃料”？为什么太阳燃烧了几十亿年的时间，这些燃料依然用不完用不尽呢？"),
        News(title: "研究发现运动可抗癌，2种运动效果更佳，却有不少人没做对", content: "对于运动抗癌这一说法，相信很多人都是有所了解，尤其是对健康比较关注的人，对一些新的研究，或者说对抗癌成功的案例会比较关注，也就会听说有些人抗癌成功，会与运动有一定的关系。")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        
        let dataSource = DrTableViewItemSource<News>(isMutableHeight: true) { item, indexPath in
            DrViewBuilder("cell") { reuseView in
                let v: NewsCellView
                if let _v = reuseView as? NewsCellView {
                    v = _v
                }else {
                    v = NewsCellView()
                }
                v.model = item
                return v
            }
        }
        
        dataSource.bindSource(self) { target in
            target.list
        }
        
        tableView.dataSource = dataSource
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.frame = view.bounds
    }
    
}


extension MutableHeightTableViewController {
    
    struct News {
        let title: String
        let content: String
    }
    
    class NewsCellView: UIView {
        
        private let titleLabel: UILabel = {
            let lb = UILabel()
            lb.textColor = .hexColor("#2A2A2A")
            lb.font = .systemFont(ofSize: 17, weight: .semibold)
            lb.textAlignment = .left
            lb.numberOfLines = 2
            return lb
        }()
        
        private let contentLabel: UILabel = {
            let lb = UILabel()
            lb.textColor = .hexColor("#2A2A2A")
            lb.font = .systemFont(ofSize: 14, weight: .regular)
            lb.textAlignment = .left
            lb.numberOfLines = 0
            return lb
        }()
        
        var model: News? {
            didSet {
                if titleLabel.text != model?.title {
                    titleLabel.text = model?.title
                    titleLabel.dr_flex.markDirty()
                }
                if contentLabel.text != model?.content {
                    contentLabel.text = model?.content
                    contentLabel.dr_flex.markDirty()
                }
            }
        }
        
        init() {
            super.init(frame: .zero)
            layoutUI()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func layoutUI() {
            dr_flex.padding(20).define { flex in
                flex.addItem(titleLabel)
                flex.addItem(contentLabel).marginTop(8)
            }
        }
    }
}
