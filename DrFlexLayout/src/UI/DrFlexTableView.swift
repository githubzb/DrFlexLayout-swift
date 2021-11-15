//
//  DrFlexTableView.swift
//  DrFlexLayout
//
//  Created by dr.box on 2021/11/15.
//

import UIKit

fileprivate let kDrFlexCellIdentifier = "DrFlexTableView.flexCell"
fileprivate let kDrFlexHeaderFooterIdentifier = "DrFlexTableView.flexHeaderFooter"

public class DrFlexTableView: UIView {
    
    private let table: UITableView
    /// 内部的UITableView（注意：请不要直接改变其相关的代理方法，否则内部将无法正确工作）
    public var innerTable: UITableView { table }
    
    public init(style: UITableView.Style) {
        table = UITableView(frame: .zero, style: style)
        table.backgroundColor = .white
        table.estimatedRowHeight = 0
        table.estimatedSectionHeaderHeight = 0
        table.estimatedSectionFooterHeight = 0
        table.separatorStyle = .none
        table.register(UITableViewCell.self, forCellReuseIdentifier: kDrFlexCellIdentifier)
        table.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: kDrFlexHeaderFooterIdentifier)
        if #available(iOS 15.0, *) {
            table.sectionHeaderTopPadding = 0
        }
        table.tableFooterView = UIView()
        super.init(frame: .zero)
        addSubview(table)
        table.delegate = self
        table.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        table.frame = bounds
        layoutTableHeaderView()
        layoutTableFooterView()
    }
    
    // MARK: - Tools
    
    /// 重新计算tableHeaderView布局
    public func layoutTableHeaderView() {
        if let header = table.tableHeaderView, header.isYogaEnabled {
            header.dr_resetWidth(bounds.width)
            header.dr_flex.layout(mode: .adjustHeight)
            table.beginUpdates()
            table.tableHeaderView = header
            table.endUpdates()
        }
    }
    
    /// 重新计算tableFooterView布局
    public func layoutTableFooterView() {
        if let footer = table.tableFooterView, footer.isYogaEnabled {
            footer.dr_resetWidth(bounds.width)
            footer.dr_flex.layout(mode: .adjustHeight)
            table.beginUpdates()
            table.tableFooterView = footer
            table.endUpdates()
        }
    }
    
    // MARK: - TableView Paramters
    
    public var sectionHeaderTopPadding: CGFloat {
        set {
            if #available(iOS 15.0, *) {
                table.sectionHeaderTopPadding = newValue
            }
        }
        get {
            if #available(iOS 15.0, *) {
                return table.sectionHeaderTopPadding
            }else{
                return 0
            }
        }
    }
    
    public var contentInset: UIEdgeInsets {
        set {
            table.contentInset = newValue
        }
        get {
            table.contentInset
        }
    }
    
    public var contentOffset: CGPoint {
        set {
            table.contentOffset = newValue
        }
        get {
            table.contentOffset
        }
    }
    
    public var bouncesZoom: Bool {
        set {
            table.bouncesZoom = newValue
        }
        get {
            table.bouncesZoom
        }
    }
    
    public var bounces: Bool {
        set {
            table.bounces = newValue
        }
        get {
            table.bounces
        }
    }
    
    public var showsVerticalScrollIndicator: Bool {
        set {
            table.showsVerticalScrollIndicator = newValue
        }
        get {
            table.showsVerticalScrollIndicator
        }
    }
    
    public var showsHorizontalScrollIndicator: Bool {
        set {
            table.showsHorizontalScrollIndicator = newValue
        }
        get {
            table.showsHorizontalScrollIndicator
        }
    }
    
    public var separatorStyle: UITableViewCell.SeparatorStyle{
        set {
            table.separatorStyle = newValue
        }
        get {
            table.separatorStyle
        }
    }
    
    public var separatorColor: UIColor? {
        set {
            table.separatorColor = newValue
        }
        get {
            table.separatorColor
        }
    }
    
    public var separatorInset: UIEdgeInsets {
        set {
            table.separatorInset = newValue
        }
        get {
            table.separatorInset
        }
    }
    
    public var separatorEffect: UIVisualEffect? {
        set {
            table.separatorEffect = newValue
        }
        get {
            table.separatorEffect
        }
    }
    
    @available(iOS 11.0, *)
    public var separatorInsetReference: UITableView.SeparatorInsetReference {
        set {
            table.separatorInsetReference = newValue
        }
        get {
            table.separatorInsetReference
        }
    }
    
    public var tableHeaderView: UIView? {
        set {
            if let view = newValue, view.isYogaEnabled {
                if bounds.size != .zero {
                    view.dr_resetWidth(bounds.width)
                    view.dr_flex.layout(mode: .adjustHeight)
                }
                table.tableHeaderView = view
            }else {
                table.tableHeaderView = newValue
            }
        }
        get {
            table.tableHeaderView
        }
    }
    
    public var tableFooterView: UIView? {
        set {
            if let view = newValue, view.isYogaEnabled {
                if bounds.size != .zero {
                    view.dr_resetWidth(bounds.width)
                    view.dr_flex.layout(mode: .adjustHeight)
                }
                table.tableFooterView = view
            }else {
                table.tableFooterView = newValue
            }
        }
        get {
            table.tableFooterView
        }
    }
}


fileprivate extension UIView {
    
    func dr_resetWidth(_ width: CGFloat) {
        var frame = frame
        frame.origin = .zero
        frame.size.width = width
        self.frame = frame
    }
    
}


extension DrFlexTableView: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        30
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kDrFlexCellIdentifier, for: indexPath)
        cell.contentView.backgroundColor = indexPath.row % 2 == 0 ? .orange : .green
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
}
