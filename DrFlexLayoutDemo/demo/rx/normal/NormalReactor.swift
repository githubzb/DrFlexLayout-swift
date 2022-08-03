//
//  NormalReactor.swift
//  DrFlexLayoutDemo
//
//  Created by dr.box on 2022/8/3.
//

import Foundation
import ReactorKit
import DrFlexLayout
import RxSwift

class NormalReactor: Reactor {
    
    enum Action {
        case reloadData
    }
    
    enum Mutation {
        case reload([NormalCellViewModel])
    }
    
    struct State {
        var items = DrSource<NormalCellViewModel>()
    }
    
    var initialState = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .reloadData:
            return reloadData()
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var _state = state
        switch mutation {
        case let .reload(list):
            _state.items.replace(models: list)
        }
        return _state
    }
}


extension NormalReactor {
    
    func reloadData() -> Observable<Mutation> {
        var list = [NormalCellViewModel]()
        for i in 0...10 {
            let x = Int.random(in: 10..<50)
            list.append(NormalCellViewModel(title: "标题：\(i * x)", subTitle: String(repeating: "子标题", count: x)))
        }
        return .just(.reload(list))
    }
}
