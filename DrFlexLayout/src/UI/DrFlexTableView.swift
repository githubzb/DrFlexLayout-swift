//
//  DrFlexTableView.swift
//  DrFlexLayout
//
//  Created by dr.box on 2021/11/15.
//

import UIKit

fileprivate let kDrFlexCellIdentifier = "DrFlexTableView.flexCell"
fileprivate let kDrFlexHeaderFooterIdentifier = "DrFlexTableView.flexHeaderFooter"

fileprivate typealias DrFlexCellList = NSMutableArray

public class DrFlexTableView: UIView {
    
    private let table: UITableView
    /// 内部的UITableView（注意：请不要直接改变其相关的代理方法，否则内部将无法正确工作）
    public var innerTable: UITableView { table }
    
    /// 存储每组cell视图
    private lazy var cellViewMap: [Int: DrFlexCellList] = [:]
    private lazy var headerViewList: [UIView] = []
    private lazy var footerViewList: [UIView] = []
    
    private var dataSource: DrFlexTableDataSource?
    private var delegate: DrFlexTableDelegate?
    
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
        self.dataSource = DrFlexTableDataSource(flexTable: self)
        self.delegate = DrFlexTableDelegate(flexTable: self)
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
    
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        table.dataSource = dataSource
        table.delegate = delegate
    }
    
    // MARK: - 回调函数
    
    /// 返回分组个数
    fileprivate var numberOfSections: (()->Int)?
    /// 绑定分组个数回调
    public func numberOfSections<T: AnyObject>(_ target: T, binding: @escaping (T)->Int) {
        weak var weakTarget = target
        self.numberOfSections = {
            if let target = weakTarget {
                return binding(target)
            }
            return 0
        }
    }
    /// 返回每组下的cell个数
    fileprivate var numberOfRowsInSection: ((Int)->Int)?
    /// 绑定每组下的cell个数回调
    public func numberOfRowsInSection<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ section: Int)->Int) {
        weak var weakTarget = target
        self.numberOfRowsInSection = { (section) in
            if let target = weakTarget {
                return binding(target, section)
            }
            return 0
        }
    }
    /// cell点击
    fileprivate var cellClick: ((IndexPath)->Void)?
    /// 绑定cell点击回调
    public func cellClick<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ indexPath: IndexPath)->Void) {
        weak var weakTarget = target
        self.cellClick = { (indexPath) in
            if let target = weakTarget {
                binding(target, indexPath)
            }
        }
    }
    
    // MARK: - Tools
    
    public func reload() {
        table.reloadData()
    }
    
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
    
    /**
     获取指定indexPath的cell视图
     
     - Parameter indexPath: IndexPath
     
     - Returns: cell视图
     */
    public func cell<T: UIView>(at indexPath: IndexPath) -> T? {
        cell(atRow: indexPath.row, atSection: indexPath.section)
    }
    
    /**
     获取指定组下的指定行的cell视图
     
     - Parameter row: 行下标
     - Parameter section: 组下标
     
     - Returns: cell视图
     */
    public func cell<T: UIView>(atRow row: Int, atSection section: Int) -> T? {
        guard let list = cellViewMap[section] else { return nil }
        guard list.count > row else { return nil }
        guard let cell = list[row] as? UIView else { return nil }
        return cell as? T
    }
    
    /**
     获取指定组的HeaderView
     
     - Parameter section: 组下标
     
     - Returns: HeaderView
     */
    public func headerView<T: UIView>(atSection section: Int) -> T? {
        if section < headerViewList.count, section >= 0 {
            return headerViewList[section] as? T
        }
        return nil
    }
    
    /**
     获取指定组的FooterView
     
     - Parameter section: 组下标
     
     - Returns: FooterView
     */
    public func footerView<T: UIView>(atSection section: Int) -> T? {
        if section < footerViewList.count, section >= 0 {
            return footerViewList[section] as? T
        }
        return nil
    }
    
    /// 存储cell视图
    fileprivate func appendCell(cell: UIView, atIndexPath indexPath: IndexPath) {
        if let list = cellViewMap[indexPath.section] {
            list.add(cell)
        }else{
            let list = NSMutableArray()
            list.add(cell)
            cellViewMap[indexPath.section] = list
        }
    }
    /// 存储headerView
    fileprivate func appendHeaderView(header: UIView) {
        headerViewList.append(header)
    }
    /// 存储footerView
    fileprivate func appendFooterView(footer: UIView) {
        footerViewList.append(footer)
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
            if let view = newValue, view.isYogaEnabled, bounds.size != .zero {
                view.dr_resetWidth(bounds.width)
                view.dr_flex.layout(mode: .adjustHeight)
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
            if let view = newValue, view.isYogaEnabled, bounds.size != .zero {
                view.dr_resetWidth(bounds.width)
                view.dr_flex.layout(mode: .adjustHeight)
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


// MARK: - TableView DataSource

fileprivate class DrFlexTableDataSource: NSObject, UITableViewDataSource {
    
    weak var flexTable: DrFlexTableView?
    
    init(flexTable: DrFlexTableView) {
        self.flexTable = flexTable
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        flexTable?.numberOfSections?() ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        flexTable?.numberOfRowsInSection?(section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kDrFlexCellIdentifier, for: indexPath)
        cell.contentView.backgroundColor = indexPath.row % 2 == 0 ? .green : .blue
        return cell
    }
    
}

// MARK: - TableView Delegate

fileprivate class DrFlexTableDelegate: NSObject, UITableViewDelegate {
    
    weak var flexTable: DrFlexTableView?
    
    init(flexTable: DrFlexTableView) {
        self.flexTable = flexTable
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        flexTable?.cellClick?(indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
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

