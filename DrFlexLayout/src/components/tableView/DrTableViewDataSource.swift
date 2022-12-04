//
//  DrTableViewDataSource.swift
//  DrFlexLayout
//
//  Created by dr.box on 2022/12/4.
//

import UIKit

public struct DrViewBuilder {
    public let reuseId: String
    public let builder: (_ reuseView: UIView?) -> UIView
    
    public init(_ reuseId: String, builder: @escaping (_ reuseView: UIView?) -> UIView) {
        self.reuseId = reuseId
        self.builder = builder
    }
}

public protocol DrTableViewDataSource {
    
    var numberOfSections: Int { get }
    func numberOfRowsInSection(section: Int) -> Int
    func view(indexPath: IndexPath) -> DrViewBuilder
    func height(indexPath: IndexPath, in tableView: UITableView) -> CGFloat
    func cleanCache()
}

public class DrTableViewGroupSource<Item> {
    
    public typealias CellBuilder = (_ item: Item, _ indexPath: IndexPath) -> DrViewBuilder
    
    private var sourceBinder: (() -> [[Item]]?)?
    private var source: [[Item]]? { sourceBinder?() }
    
    private let cellBuilder: CellBuilder
    private var heightCaches: [String: CGFloat] = [:]
    
    public init(_ cellBuilder: @escaping CellBuilder) {
        self.cellBuilder = cellBuilder
    }
    
    public func bindSource<T: AnyObject>(_ target: T, binding: @escaping (_ target: T) -> [[Item]]) {
        weak var weakTarget = target
        sourceBinder = {
            guard let target = weakTarget else {
                return nil
            }
            return binding(target)
        }
    }
}

extension DrTableViewGroupSource: DrTableViewDataSource {
    
    public var numberOfSections: Int {
        source?.count ?? 1
    }
    
    public func numberOfRowsInSection(section: Int) -> Int {
        source![section].count
    }
    
    public func item(row: Int, section: Int) -> Item {
        source![section][row]
    }
    
    public func view(indexPath: IndexPath) -> DrViewBuilder {
        let item = item(row: indexPath.row, section: indexPath.section)
        return cellBuilder(item, indexPath)
    }
    
    public func height(indexPath: IndexPath, in tableView: UITableView) -> CGFloat {
        let viewBuilder = view(indexPath: indexPath)
        guard let height = heightCaches[viewBuilder.reuseId] else {
            let view = viewBuilder.builder(nil)
            view.dr_resetWidth(tableView.frame.width)
            if view.isYogaEnabled {
                view.dr_flex.layout(mode: .adjustHeight)
            }
            heightCaches[viewBuilder.reuseId] = view.frame.height
            return view.frame.height
        }
        return height
    }
    
    public func cleanCache() {
        heightCaches.removeAll()
    }
}


public class DrTableViewItemSource<Item> {
    
    public typealias CellBuilder = (_ item: Item, _ indexPath: IndexPath) -> DrViewBuilder
    
    private var sourceBinder: (() -> [Item]?)?
    private var source: [Item]? { sourceBinder?() }
    
    private let cellBuilder: CellBuilder
    private var heightCaches: [String: CGFloat] = [:]
    
    public init(_ cellBuilder: @escaping CellBuilder) {
        self.cellBuilder = cellBuilder
    }
    
    public func bindSource<T: AnyObject>(_ target: T, binding: @escaping (_ target: T) -> [Item]) {
        weak var weakTarget = target
        sourceBinder = {
            guard let target = weakTarget else {
                return nil
            }
            return binding(target)
        }
    }
}

extension DrTableViewItemSource: DrTableViewDataSource {
    
    public var numberOfSections: Int {
        1
    }
    
    public func numberOfRowsInSection(section: Int) -> Int {
        source?.count ?? 0
    }
    
    public func item(row: Int, section: Int) -> Item {
        source![row]
    }
    
    public func view(indexPath: IndexPath) -> DrViewBuilder {
        let item = item(row: indexPath.row, section: indexPath.section)
        return cellBuilder(item, indexPath)
    }
    
    public func height(indexPath: IndexPath, in tableView: UITableView) -> CGFloat {
        let viewBuilder = view(indexPath: indexPath)
        guard let height = heightCaches[viewBuilder.reuseId] else {
            let view = viewBuilder.builder(nil)
            view.dr_resetWidth(tableView.frame.width)
            if view.isYogaEnabled {
                view.dr_flex.layout(mode: .adjustHeight)
            }
            heightCaches[viewBuilder.reuseId] = view.frame.height
            return view.frame.height
        }
        return height
    }
    
    public func cleanCache() {
        heightCaches.removeAll()
    }
}
