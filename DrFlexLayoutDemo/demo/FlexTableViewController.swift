//
//  FlexTableViewController.swift
//  DrFlexLayoutDemo
//
//  Created by dr.box on 2021/11/15.
//

import UIKit
import DrFlexLayout

struct NewsItem: Equatable {
    let imgColor: UIColor
    let title: String
    let subTitle: String
}

class NewsItemCell: UIView {
    
    private let iconView = UIView()
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .white
        lb.font = .systemFont(ofSize: 14, weight: .regular)
        lb.numberOfLines = 2
        return lb
    }()
    private let subTitleLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .lightGray
        lb.font = .systemFont(ofSize: 12, weight: .regular)
        lb.numberOfLines = 0
        return lb
    }()
    
    var model: NewsItem {
        didSet {
            if oldValue != model {
                self.iconView.backgroundColor = model.imgColor
                self.titleLabel.text = model.title
                self.subTitleLabel.text = model.subTitle
                self.titleLabel.dr_flex.markDirty()
                self.subTitleLabel.dr_flex.markDirty()
            }
        }
    }
    
    init(model: NewsItem) {
        self.model = model
        super.init(frame: .zero)
        backgroundColor = .hexColor("#F3F3F3")
        
        self.iconView.backgroundColor = model.imgColor
        self.titleLabel.text = model.title
        self.subTitleLabel.text = model.subTitle
        
        dr_flex.padding(UIEdgeInsets(top: 10, left: 15, bottom: 0, right: 15))
            .addItem()
            .direction(.row)
            .backgroundColor(.blue)
            .cornerRadius(radius: 8)
            .padding(10)
            .define { flex in
                // 左侧
                flex.addItem().height(100%).define { flex in
                    flex.addItem(self.iconView).size(50).cornerRadius(radius: 8)
                }
                // 右侧
                flex.addItem().paddingLeft(8).flex(1).define { flex in
                    flex.addItem(self.titleLabel)
                    flex.addItem(self.subTitleLabel).marginTop(8)
                }
            }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class FlexTableViewController: UIViewController {
    
    let table = DrFlexTableView(style: .plain)
    
    var list: [[NewsItem]] = []
    
    let v = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(table)
        
        let header = UIView()
        header.backgroundColor = .blue
        header.dr_flex.addItem(self.v).height(100).marginHorizontal(20).marginVertical(20).backgroundColor(.yellow)
        table.tableHeaderView = header

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.table.tableHeaderView?.backgroundColor = .red
            self.v.backgroundColor = .blue
            self.v.dr_flex.height(200)
            let v = UIView()
            v.backgroundColor = .green
            self.table.tableHeaderView?.dr_flex.addItem(v).height(20).marginHorizontal(20).marginVertical(20)
            self.table.layoutTableHeaderView()
        }
        
        
        // 初始化数据列表
        self.list = [
            [
                NewsItem(imgColor: .orange, title: "①今日新闻，内容标题", subTitle: "美国又朝着解体成为两个国家，迈出了坚实的一步"),
                NewsItem(imgColor: .brown, title: "①今日新闻，内容标题", subTitle: "美国又朝着解体成为两个国家，迈出了坚实的一步"),
                NewsItem(imgColor: .yellow, title: "①今日新闻，内容标题", subTitle: "美国又朝着解体成为两个国家，迈出了坚实的一步"),
                NewsItem(imgColor: .yellow, title: "①今日新闻，内容标题", subTitle: "美国又朝着解体成为两个国家，迈出了坚实的一步"),
                NewsItem(imgColor: .white, title: "①今日新闻，内容标题", subTitle: "美国又朝着解体成为两个国家，迈出了坚实的一步"),
            ],
            [
                NewsItem(imgColor: .orange, title: "②今日新闻，内容标题", subTitle: "美国又朝着解体成为两个国家，迈出了坚实的一步"),
                NewsItem(imgColor: .orange, title: "②今日新闻，内容标题", subTitle: "美国又朝着解体成为两个国家，迈出了坚实的一步"),
                NewsItem(imgColor: .orange, title: "②今日新闻，内容标题", subTitle: "美国又朝着解体成为两个国家，迈出了坚实的一步"),
                NewsItem(imgColor: .orange, title: "②今日新闻，内容标题", subTitle: "美国又朝着解体成为两个国家，迈出了坚实的一步"),
                NewsItem(imgColor: .orange, title: "②今日新闻，内容标题", subTitle: "美国又朝着解体成为两个国家，迈出了坚实的一步"),
            ],
        ]
        
        // 通过绑定数据源的方式加载列表
        table.numberOfSections(self) { target in
            target.list.count
        }
        table.numberOfRowsInSection(self) { target, section in
            target.list[section].count
        }
        table.cellInit(self) { target, indexPath in
            print("------构建cell")
            return NewsItemCell(model: target.list[indexPath.section][indexPath.row])
        }
        
        table.cellClick(self) { target, indexPath in
            let model = target.list[indexPath.section][indexPath.row]
            target.clickCell(model: model)
        }
        
        let btn1 = UIBarButtonItem(title: "刷新",
                                   style: .plain,
                                   target: self,
                                   action: #selector(refresh))
        let btn2 = UIBarButtonItem(title: "刷新2",
                                   style: .plain,
                                   target: self,
                                   action: #selector(refresh2))
        let btn3 = UIBarButtonItem(title: "刷新3",
                                   style: .plain,
                                   target: self,
                                   action: #selector(refresh3))
        let btn4 = UIBarButtonItem(title: "刷新4",
                                   style: .plain,
                                   target: self,
                                   action: #selector(refresh4))
        self.navigationItem.rightBarButtonItems = [btn1, btn2, btn3, btn4]
    }
    
    @objc func refresh(){
        
        self.list = [
            [
                NewsItem(imgColor: .orange, title: "①\"台独\"末日越来越近！民进党惹上事了，国台办号召岛内同胞行动", subTitle: "关键时刻，普京力挺中国！眼看着美国、英国想抵制北京冬奥会，俄罗斯坐不住了，就在昨天，俄罗斯总统新闻秘书佩斯科夫接受采访时表示，普京已受邀参加北京冬奥会开幕。"),
                NewsItem(imgColor: .orange, title: "①今日新闻，内容标题", subTitle: "美国又朝着解体成为两个国家，迈出了坚实的一步"),
                NewsItem(imgColor: .white, title: "①\"台独\"末日越来越近！民进党惹上事了，国台办号召岛内同胞行动", subTitle: "关键时刻，普京力挺中国！眼看着美国、英国想抵制北京冬奥会，俄罗斯坐不住了，就在昨天，俄罗斯总统新闻秘书佩斯科夫接受采访时表示，普京已受邀参加北京冬奥会开幕。"),
                NewsItem(imgColor: .orange, title: "①今日新闻，内容标题", subTitle: "美国又朝着解体成为两个国家，迈出了坚实的一步"),
                NewsItem(imgColor: .yellow, title: "①今日新闻，内容标题", subTitle: "美国又朝着解体成为两个国家，迈出了坚实的一步"),
            ],
            [
                NewsItem(imgColor: .yellow, title: "②\"台独\"末日越来越近！民进党惹上事了，国台办号召岛内同胞行动", subTitle: "关键时刻，普京力挺中国！眼看着美国、英国想抵制北京冬奥会，俄罗斯坐不住了，就在昨天，俄罗斯总统新闻秘书佩斯科夫接受采访时表示，普京已受邀参加北京冬奥会开幕。"),
                NewsItem(imgColor: .yellow, title: "②今日新闻，内容标题", subTitle: "美国又朝着解体成为两个国家，迈出了坚实的一步"),
                NewsItem(imgColor: .white, title: "②今日新闻，内容标题", subTitle: "美国又朝着解体成为两个国家，迈出了坚实的一步"),
                NewsItem(imgColor: .white, title: "②今日新闻，内容标题", subTitle: "美国又朝着解体成为两个国家，迈出了坚实的一步"),
                NewsItem(imgColor: .white, title: "②\"台独\"末日越来越近！民进党惹上事了，国台办号召岛内同胞行动", subTitle: "关键时刻，普京力挺中国！眼看着美国、英国想抵制北京冬奥会，俄罗斯坐不住了，就在昨天，俄罗斯总统新闻秘书佩斯科夫接受采访时表示，普京已受邀参加北京冬奥会开幕。"),
            ]
        ]
        
        for (section, group) in self.list.enumerated() {
            for (index, m) in group.enumerated() {
                if let cell: NewsItemCell = table.cell(atRow: index, atSection: section) {
                    cell.model = m
                }
            }
        }
        // 刷新所有cell视图的布局（不重新构建cell）
        table.refresh(needLayout: true)
    }
    
    @objc func refresh2() {
        self.list = [
            [
                NewsItem(imgColor: .orange, title: "①\"台独\"末日越来越近！民进党惹上事了，国台办号召岛内同胞行动", subTitle: "关键时刻，普京力挺中国！眼看着美国、英国想抵制北京冬奥会，俄罗斯坐不住了，就在昨天，俄罗斯总统新闻秘书佩斯科夫接受采访时表示，普京已受邀参加北京冬奥会开幕。"),
                NewsItem(imgColor: .orange, title: "①今日新闻，内容标题", subTitle: "美国又朝着解体成为两个国家，迈出了坚实的一步"),
                NewsItem(imgColor: .white, title: "①\"台独\"末日越来越近！民进党惹上事了，国台办号召岛内同胞行动", subTitle: "关键时刻，普京力挺中国！眼看着美国、英国想抵制北京冬奥会，俄罗斯坐不住了，就在昨天，俄罗斯总统新闻秘书佩斯科夫接受采访时表示，普京已受邀参加北京冬奥会开幕。"),
                NewsItem(imgColor: .orange, title: "①今日新闻，内容标题", subTitle: "美国又朝着解体成为两个国家，迈出了坚实的一步"),
                NewsItem(imgColor: .yellow, title: "①今日新闻，内容标题", subTitle: "美国又朝着解体成为两个国家，迈出了坚实的一步"),
            ],
            [
                NewsItem(imgColor: .yellow, title: "②第二个分组重新构建了", subTitle: "关键时刻，普京力挺中国！眼看着美国、英国想抵制北京冬奥会，俄罗斯坐不住了，就在昨天，俄罗斯总统新闻秘书佩斯科夫接受采访时表示，普京已受邀参加北京冬奥会开幕。"),
                NewsItem(imgColor: .yellow, title: "②第二个分组重新构建了", subTitle: "美国又朝着解体成为两个国家，迈出了坚实的一步"),
                NewsItem(imgColor: .white, title: "②第二个分组重新构建了", subTitle: "美国又朝着解体成为两个国家，迈出了坚实的一步"),
                NewsItem(imgColor: .white, title: "②第二个分组重新构建了", subTitle: "美国又朝着解体成为两个国家，迈出了坚实的一步"),
                NewsItem(imgColor: .white, title: "②第二个分组重新构建了", subTitle: "关键时刻，普京力挺中国！眼看着美国、英国想抵制北京冬奥会，俄罗斯坐不住了，就在昨天，俄罗斯总统新闻秘书佩斯科夫接受采访时表示，普京已受邀参加北京冬奥会开幕。"),
            ]
        ]
        // 对第二个分组的cell视图重新构建
        table.reloadSections(IndexSet([1]))
    }
    
    @objc func refresh3() {
        self.list = [
            [
                NewsItem(imgColor: .orange, title: "①这里重新构建了，你看到了吗？", subTitle: "关键时刻，普京力挺中国！眼看着美国、英国想抵制北京冬奥会，俄罗斯坐不住了，就在昨天，俄罗斯总统新闻秘书佩斯科夫接受采访时表示，普京已受邀参加北京冬奥会开幕。"),
                NewsItem(imgColor: .orange, title: "①今日新闻，内容标题", subTitle: "美国又朝着解体成为两个国家，迈出了坚实的一步"),
                NewsItem(imgColor: .white, title: "①\"台独\"末日越来越近！民进党惹上事了，国台办号召岛内同胞行动", subTitle: "关键时刻，普京力挺中国！眼看着美国、英国想抵制北京冬奥会，俄罗斯坐不住了，就在昨天，俄罗斯总统新闻秘书佩斯科夫接受采访时表示，普京已受邀参加北京冬奥会开幕。"),
                NewsItem(imgColor: .orange, title: "①今日新闻，内容标题", subTitle: "美国又朝着解体成为两个国家，迈出了坚实的一步"),
                NewsItem(imgColor: .yellow, title: "①今日新闻，内容标题", subTitle: "美国又朝着解体成为两个国家，迈出了坚实的一步"),
            ],
            [
                NewsItem(imgColor: .yellow, title: "②这里重新构建了，你看到了吗？", subTitle: "关键时刻，普京力挺中国！眼看着美国、英国想抵制北京冬奥会，俄罗斯坐不住了，就在昨天，俄罗斯总统新闻秘书佩斯科夫接受采访时表示，普京已受邀参加北京冬奥会开幕。"),
                NewsItem(imgColor: .yellow, title: "②第二个分组重新构建了", subTitle: "美国又朝着解体成为两个国家，迈出了坚实的一步"),
                NewsItem(imgColor: .white, title: "②第二个分组重新构建了", subTitle: "美国又朝着解体成为两个国家，迈出了坚实的一步"),
                NewsItem(imgColor: .white, title: "②第二个分组重新构建了", subTitle: "美国又朝着解体成为两个国家，迈出了坚实的一步"),
                NewsItem(imgColor: .white, title: "②第二个分组重新构建了", subTitle: "关键时刻，普京力挺中国！眼看着美国、英国想抵制北京冬奥会，俄罗斯坐不住了，就在昨天，俄罗斯总统新闻秘书佩斯科夫接受采访时表示，普京已受邀参加北京冬奥会开幕。"),
            ]
        ]
        // 指定cell视图重新构建
        table.reloadRows(at: [IndexPath(row: 0, section: 0), IndexPath(row: 0, section: 1)], with: .left)
    }
    
    @objc func refresh4() {
        // 指定cell视图刷新，重新计算布局
        if let cell: NewsItemCell = table.cell(atRow: 0, atSection: 0) {
            let model = NewsItem(imgColor: .orange,
                                 title: "①你指定了我刷新，重新计算布局，看我变化了没！",
                                 subTitle: "关键时刻，普京力挺中国！眼看着美国、英国想抵制北京冬奥会，俄罗斯坐不住了，就在昨天，俄罗斯总统新闻秘书佩斯科夫接受采访时表示，普京已受邀参加北京冬奥会开幕。关键时刻，普京力挺中国！眼看着美国、英国想抵制北京冬奥会，俄罗斯坐不住了，就在昨天，俄罗斯总统新闻秘书佩斯科夫接受采访时表示，普京已受邀参加北京冬奥会开幕。")
            cell.model = model
        }
        table.refreshRows(at: [IndexPath(row: 0, section: 0)], with: .fade, needLayout: true)
    }
    
    
    func clickCell(model: NewsItem) {
        print("------点击：\(model.title)")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        table.frame = view.bounds
    }
    
    deinit {
        print("----deinit")
    }
}
