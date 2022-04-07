//
//  RxTableViewModel.swift
//  DrFlexLayoutDemo
//
//  Created by dr.box on 2022/4/4.
//

import Foundation
import ReactorKit
import RxSwift
import DrFlexLayout

class RxTableViewModel: Reactor {
    
    typealias Section = SourceSection<Item>
    
    var initialState = State()
    var loadMoreHotsFinished = false
    var loadMoreRecommendFinished = false
    
    enum Action {
        case reloadData
        case loadMore(type: RxNewsType, section: Int)
    }
    
    enum Mutation {
        case reloadAll([Section])
        case append(items: [Item], section: Int, type: RxNewsType)
    }
    
    struct State {
        var source = DrFlexLayout.Source<Item>()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .reloadData:
            return fetchData()
            
        case let .loadMore(type, section):
            return fetchMore(type: type, section: section)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var _state = state
        switch mutation {
        case let .reloadAll(sections):
            _state.source = Source(sections: sections)
            
        case let .append(items, section, type):
            switch type {
            case .hots:
                if self.loadMoreHotsFinished {
                    _state.source.performBatchUpdates { source in
                        let idx = source.itemCount(section: section) - 1
                        source.insert(models: items, section: section, insertIndex: idx)
                        source.replace(model: Item.loadMore(hasMoreData: false, type: type),
                                              row: source.itemCount(section: section) - 1,
                                              section: section)
                        return .insertRows(section: section,
                                           insertIndex: idx,
                                           rowCount: items.count,
                                           refreshAfter: true)
                    }
                }else {
                    let idx = _state.source.itemCount(section: section) - 1
                    _state.source.insert(models: items, section: section, insertIndex: idx)
                }
                
            case .recommend:
                if self.loadMoreRecommendFinished {
                    _state.source.performBatchUpdates { source in
                        let idx = source.itemCount(section: section) - 1
                        source.insert(models: items, section: section, insertIndex: idx)
                        source.replace(model: Item.loadMore(hasMoreData: false, type: type),
                                              row: source.itemCount(section: section) - 1,
                                              section: section)
                        return .insertRows(section: section,
                                           insertIndex: idx,
                                           rowCount: items.count,
                                           refreshAfter: true)
                    }
                }else {
                    let idx = _state.source.itemCount(section: section) - 1
                    _state.source.insert(models: items, section: section, insertIndex: idx)
                }
            }
        }
        return _state
    }
}


extension RxTableViewModel {
    
    func fetchData() -> Observable<Mutation> {
        
        var hotItems: [Item] = []
        let hItem1 = RxNewsItem(title: "越低调，越出乎意料，细看72岁张艺谋的资产，才知什么叫人生赢家",
                                subTitle: "今年4月2日，是导演张艺谋72岁生日，比起往年倒是低调不少，以往的家庭庆生大合照没看到了。",
                                icon: URL(string: "https://p6.toutiaoimg.com/tos-cn-i-qvj2lq49k0/b20d4dcced804c4d83b94ce11ba68602~tplv-tt-cs0:640:360.jpg?from=feed&_iz=31826"),
                                type: .hots)
        let hItem2 = RxNewsItem(title: "中国长城到底有没有用？长城与欧洲的发展有没有联系？",
                                subTitle: "不到长城非好汉。古语不是没有道理，我们常常登山，却没有一座山可以说不到此而非好汉，也没有任何古建筑可以与好汉相提并论。",
                                icon: URL(string: "https://p3.toutiaoimg.com/tos-cn-i-qvj2lq49k0/2a3bb7618f0d44248b80d9be3c4796cc~tplv-tt-cs0:640:360.jpg?from=feed&_iz=31826"),
                                type: .hots)
        let hItem3 = RxNewsItem(title: "山东医保缴费年限改革，全省要统一，什么情况？",
                                subTitle: "山东的医保缴费年限开始改革了。相信不少省市地区都会紧跟其后，咱们还没有退休的朋友们可得注意医保缴费的年限变化了。在2022年的4月1号起，山东就已经开始执行了医保缴费年限男性30年，女性25年的统一管理。",
                                icon: URL(string: "https://p6.toutiaoimg.com/tos-cn-i-qvj2lq49k0/977b3b879a3042ed9d1115b2b5fc3559~tplv-tt-cs0:640:360.jpg?from=feed&_iz=31826"),
                                type: .hots)
        hotItems.append(.news(hItem1))
        hotItems.append(.news(hItem2))
        hotItems.append(.news(hItem3))
        hotItems.append(.loadMore(hasMoreData: true, type: .hots))
        let hots = Section(items: hotItems, header: RxNewsType.hots)
        
        
        var recItems: [Item] = []
        let recItem1 = RxNewsItem(title: "广东60岁农民，2022年能领取多少养老金？网友：真让人羡慕",
                                  subTitle: "好消息！农民也能领取养老金了！不少农民朋友不用交任何费用，每个月都能领取一步不错的养老金，这到底是怎么回事？",
                                  icon: URL(string: "https://p3.toutiaoimg.com/tos-cn-i-qvj2lq49k0/75c1052b1f24417fbbf9ddcff9cf7fd5~tplv-tt-cs0:640:360.jpg?from=feed&_iz=31826"),
                                  type: .recommend)
        let recItem2 = RxNewsItem(title: "因一包酸菜，导致康师傅、统一流失数亿市值，严钦武什么来头？",
                                  subTitle: "2022年3月15日晚上20点，一年一度的3·15晚会在中央电视台财经频道缓缓拉开了帷幕。",
                                  icon: URL(string: "https://p9.toutiaoimg.com/tos-cn-i-qvj2lq49k0/11883f9b2fe140729cca1e9d10a6a77d~tplv-tt-cs0:640:360.jpg?from=feed&_iz=31826"),
                                  type: .recommend)
        let recItem3 = RxNewsItem(title: "海报被撤，直播被叫停，戏份被删，吴磊走到今天到底是谁的错？",
                                  subTitle: "2018年《沙海》播出时，观众便发现角色的不对劲。",
                                  icon: URL(string: "https://p3.toutiaoimg.com/tos-cn-i-qvj2lq49k0/4453d1eaca3c4dd4ba3ea034b564709a~tplv-tt-cs0:640:360.jpg?from=feed&_iz=31826"),
                                  type: .recommend)
        recItems.append(.news(recItem1))
        recItems.append(.news(recItem2))
        recItems.append(.news(recItem3))
        recItems.append(.loadMore(hasMoreData: true, type: .recommend))
        let recommend = Section(items: recItems, header: RxNewsType.recommend)
        
        return .just(.reloadAll([hots, recommend]))
    }
    
    
    func fetchMore(type: RxNewsType, section: Int) -> Observable<Mutation> {
        switch type {
        case .hots:
            self.loadMoreHotsFinished = true
            let item1 = RxNewsItem(title: "特朗普再次炮轰拜登：美国正处于灾难状态，你却啥都不知道",
                                      subTitle: "论不按套路出牌，还得看美国前总统特朗普，关键时刻，大统领又开始表演了。",
                                      icon: URL(string: "https://p3.toutiaoimg.com/tos-cn-i-qvj2lq49k0/dcf566e9ee4b42e989a7f31b9d753b13~tplv-tt-cs0:640:360.jpg?from=feed&_iz=31826"),
                                      type: .hots)
            let item2 = RxNewsItem(title: "东航空难事件尚未有结果，波音飞机再出事故",
                                      subTitle: "美国达美航空的一架波音飞机在9100多米的高空飞行时，挡风玻璃突然破裂，当时机上有198名乘客。",
                                      icon: URL(string: "https://p3.toutiaoimg.com/tos-cn-i-qvj2lq49k0/5debe2871ec049e48db4c02d87f47b48~tplv-tt-cs0:640:360.jpg?from=feed&_iz=31826"),
                                      type: .hots)
            let item3 = RxNewsItem(title: "李显龙访美点醒拜登？亚洲并非美“后院”，中国不会心慈手软",
                                      subTitle: "新加坡总理访美，强调中美合作利于世界繁荣发展，若美国秉持“冷战思维”，将世界遭殃！",
                                      icon: URL(string: "https://p3.toutiaoimg.com/tos-cn-i-qvj2lq49k0/99a358949acd4683a4037abfd9dd6ead~tplv-tt-cs0:640:360.jpg?from=feed&_iz=31826"),
                                      type: .hots)
            return .just(.append(items: [.news(item1), .news(item2), .news(item3)], section: section, type: .hots))
            
        case .recommend:
            self.loadMoreRecommendFinished = true
            let item1 = RxNewsItem(title: "李显龙访美点醒拜登？亚洲并非美“后院”，中国不会心慈手软",
                                      subTitle: "新加坡总理访美，强调中美合作利于世界繁荣发展，若美国秉持“冷战思维”，将世界遭殃！",
                                      icon: URL(string: "https://p3.toutiaoimg.com/tos-cn-i-qvj2lq49k0/99a358949acd4683a4037abfd9dd6ead~tplv-tt-cs0:640:360.jpg?from=feed&_iz=31826"),
                                      type: .recommend)
            let item2 = RxNewsItem(title: "“新型啃老”正在流行，63岁大妈哭诉：陪伴式孝顺是我晚年的噩梦",
                                      subTitle: "“你养我小，我养你老”，父母和子女之间就应该这样，父母选择把孩子生下来，那就要好好培养他们的义务，而等到父母到了晚年，身体慢慢走下坡路之后，子女也应该好好照顾父母，让父母能够过好晚年生活。",
                                      icon: URL(string: "https://p3.toutiaoimg.com/tos-cn-i-qvj2lq49k0/a53ded7a5d1f4e759253c35e4a8b2943~tplv-tt-cs0:640:360.jpg?from=feed&_iz=31826"),
                                      type: .recommend)
            let item3 = RxNewsItem(title: "吃了动物血后大便发黑，是肺在排毒，还是身体有问题？医生告诉你",
                                      subTitle: "“我今早发现自己拉的粑粑是黑色的！我不会得癌症了吧？”“大惊小怪的！你最近是不是吃了动物血？”",
                                      icon: URL(string: "https://p9.toutiaoimg.com/tos-cn-i-qvj2lq49k0/a1a78541fbeb44e7aa49562e6db9adf2~tplv-tt-cs0:640:360.jpg?from=feed&_iz=31826"),
                                      type: .recommend)
            return .just(.append(items: [.news(item1), .news(item2), .news(item3)], section: section, type: .recommend))
        }
    }
}


enum Item {
    case news(RxNewsItem)
    case loadMore(hasMoreData: Bool, type: RxNewsType)
}

struct RxNewsItem {
    var title: String
    var subTitle: String
    var icon: URL?
    var type: RxNewsType
}

enum RxNewsType: CustomStringConvertible {
    
    // 热门
    case hots
    // 推荐
    case recommend
    
    var description: String {
        switch self {
        case .hots:
            return "热门"
        case .recommend:
            return "推荐"
        }
    }
}
