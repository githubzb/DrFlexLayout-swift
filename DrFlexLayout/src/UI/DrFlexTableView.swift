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

/**
 帮助：当style为grouped或insetGrouped时，列表顶部会多出一部分间隔，此时我们可以设置一个tableHeaderView，
 并将其高度设置为大于0，且小于1的值即可。
 */
public class DrFlexTableView: UIView {
    
    private let table: UITableView
    /// 内部的UITableView（注意：请不要直接改变其相关的代理方法，否则内部将无法正确工作）
    public var innerTable: UITableView { table }
    
    /// 存储每组cell视图
    private lazy var cellViewMap: [Int: DrFlexCellList] = [:]
    private lazy var headerViewList: [UIView?] = []
    private lazy var footerViewList: [UIView?] = []
    
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
    public func numberOfSections<T: AnyObject>(_ target: T, binding: @escaping (_ target: T)->Int) {
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
    
    fileprivate var cellInit: ((IndexPath)->UIView?)?
    /// 初始化cell
    public func cellInit<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ indexPath: IndexPath)->UIView?) {
        weak var weakTarget = target
        self.cellInit = { (indexPath) in
            if let target = weakTarget {
                return binding(target, indexPath)
            }
            return nil
        }
    }
    
    fileprivate var headerInit: ((Int)->UIView?)?
    /// 初始化每组的headerView
    public func headerInit<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ section: Int) -> UIView?) {
        weak var weakTarget = target
        self.headerInit = { (section) in
            if let target = weakTarget {
                return binding(target, section)
            }
            return nil
        }
    }
    
    fileprivate var footerInit: ((Int)->UIView?)?
    /// 初始化每组的footerView
    public func footerInit<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ section: Int) -> UIView?) {
        weak var weakTarget = target
        self.footerInit = { (section) in
            if let target = weakTarget {
                return binding(target, section)
            }
            return nil
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
    
    fileprivate var didScroll: ((CGPoint)->Void)?
    /// 列表滚动回调
    public func didScroll<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ contentOffset: CGPoint)->Void) {
        weak var weakTarget = target
        self.didScroll = { (contentOffset) in
            if let target = weakTarget{
                binding(target, contentOffset)
            }
        }
    }
    
    // MARK: - Tools
    
    /// 重新构建cell视图
    public func reload() {
        cellViewMap.removeAll()
        headerViewList.removeAll()
        footerViewList.removeAll()
        table.reloadData()
    }
    
    /// 刷新列表视图（不会重新构建cell）
    public func refresh() {
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
        guard let cell = list[row] as? T else { return nil }
        return cell
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
    fileprivate func appendCell(cell: UIView?, atIndexPath indexPath: IndexPath) {
        let cellView: Any = cell == nil ? NSNull() : cell!
        if let list = cellViewMap[indexPath.section] {
            if indexPath.row < list.count {
                list.replaceObject(at: indexPath.row, with: cellView)
            }else{
                list.add(cellView)
            }
        }else{
            let list = NSMutableArray()
            list.add(cellView)
            cellViewMap[indexPath.section] = list
        }
    }
    /// 存储headerView
    fileprivate func appendHeaderView(header: UIView?, section: Int) {
        if section < headerViewList.count {
            headerViewList[section] = header
        }else {
            headerViewList.append(header)
        }
    }
    /// 存储footerView
    fileprivate func appendFooterView(footer: UIView?, section: Int) {
        if section < footerViewList.count {
            footerViewList[section] = footer
        }else {
            footerViewList.append(footer)
        }
    }
    
    // MARK: - TableView Paramters
    
    public override var backgroundColor: UIColor?{
        set {
            self.table.backgroundColor = newValue
        }
        get {
            self.table.backgroundColor
        }
    }
    
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

fileprivate let kDrCellTag = 30303

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
        cell.selectionStyle = .none
        cell.contentView.backgroundColor = tableView.backgroundColor
        cell.contentView.viewWithTag(kDrCellTag)?.removeFromSuperview()
        if let view = flexTable?.cell(at: indexPath) {
            view.removeFromSuperview()
            view.tag = kDrCellTag
            cell.contentView.addSubview(view)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        nil
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        nil
    }
    
}

// MARK: - TableView Delegate

fileprivate let kDrHeaderFooterTag = 40404

fileprivate class DrFlexTableDelegate: NSObject, UITableViewDelegate {
    
    weak var flexTable: DrFlexTableView?
    
    init(flexTable: DrFlexTableView) {
        self.flexTable = flexTable
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        flexTable?.cellClick?(indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let cell = flexTable?.cell(at: indexPath) {
            return cell.frame.height
        }
        guard let cell = flexTable?.cellInit?(indexPath) else {
            return 0
        }
        if cell.isYogaEnabled {
            cell.dr_resetWidth(tableView.frame.width)
            cell.dr_flex.layout(mode: .adjustHeight)
        }
        flexTable?.appendCell(cell: cell, atIndexPath: indexPath)
        return cell.frame.height
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let header = flexTable?.headerView(atSection: section) {
            return header.frame.height
        }
        guard let header = flexTable?.headerInit?(section) else {
            switch tableView.style {
            case .grouped, .insetGrouped:
                return CGFloat.leastNonzeroMagnitude
            default:
                return 0
            }
        }
        if header.isYogaEnabled {
            header.dr_resetWidth(tableView.frame.width)
            header.dr_flex.layout(mode: .adjustHeight)
        }
        flexTable?.appendHeaderView(header: header, section: section)
        return header.frame.height
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let footer = flexTable?.footerView(atSection: section) {
            return footer.frame.height
        }
        guard let footer = flexTable?.footerInit?(section) else {
            switch tableView.style {
            case .grouped, .insetGrouped:
                return CGFloat.leastNonzeroMagnitude
            default:
                return 0
            }
        }
        if footer.isYogaEnabled {
            footer.dr_resetWidth(tableView.frame.width)
            footer.dr_flex.layout(mode: .adjustHeight)
        }
        flexTable?.appendFooterView(footer: footer, section: section)
        return footer.frame.height
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: kDrFlexHeaderFooterIdentifier)
        header?.contentView.viewWithTag(kDrHeaderFooterTag)?.removeFromSuperview()
        if let view = flexTable?.headerView(atSection: section) {
            view.removeFromSuperview()
            view.tag = kDrHeaderFooterTag
            header?.contentView.addSubview(view)
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: kDrFlexHeaderFooterIdentifier)
        footer?.contentView.viewWithTag(kDrHeaderFooterTag)?.removeFromSuperview()
        if let view = flexTable?.footerView(atSection: section) {
            view.removeFromSuperview()
            view.tag = kDrHeaderFooterTag
            footer?.contentView.addSubview(view)
        }
        return footer
    }
    
    // MARK: - ScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        flexTable?.didScroll?(scrollView.contentOffset)
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


public struct DRFlexTableGroup {
    public let headerView: UIView?
    public let footerView: UIView?
    public let cellList: [UIView]
    
    public init(header: UIView?, footer: UIView?, cellList: @autoclosure ()->[UIView]){
        headerView = header
        footerView = footer
        self.cellList = cellList()
    }
}
