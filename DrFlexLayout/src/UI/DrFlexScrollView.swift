//
//  DrFlexScrollView.swift
//  DrFlexLayout
//
//  Created by DHY on 2021/11/23.
//

import UIKit

/// 滚动方向
public enum DrFlexScrollDirection {
    /// 水平滚动
    case horizontal
    /// 垂直滚动
    case vertical
}

public enum DrFlexScrollItemAlign {
    /// Default. Items are stretched to fit the container
    case stretch
    /// Items are positioned at the beginning of the container
    case start
    /// Items are positioned at the center of the container
    case center
    /// Items are positioned at the end of the container
    case end
    /// Items are positioned at the baseline of the container
    case baseline
    
    var flexValue: DrFlex.AlignItems {
        switch self {
        case .start:
            return .start
        case .stretch:
            return .stretch
        case .center:
            return .center
        case .end:
            return .end
        case .baseline:
            return .baseline
        }
    }
}

public class DrFlexScrollView: UIView {
    
    public let scrollDirection: DrFlexScrollDirection
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var layoutSubviewsFinishCallback: (()->Void)?
    
    /// UIScrollView代理
    public let scrollDelegate = DrFlexScrollViewCallback()
    private var proxy: DrFlexScrollViewProxy?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(direction: DrFlexScrollDirection, itemAlign: DrFlexScrollItemAlign = .stretch) {
        scrollDirection = direction
        super.init(frame: .zero)
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        proxy = DrFlexScrollViewProxy(binder: scrollDelegate)
        scrollView.delegate = proxy
        switch direction {
        case .horizontal:
            contentView.dr_flex.direction(.row).wrap(.noWrap).alignItems(itemAlign.flexValue)
        case .vertical:
            contentView.dr_flex.direction(.column).wrap(.noWrap).alignItems(itemAlign.flexValue)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.scrollView.frame = bounds
        
        switch scrollDirection {
        case .horizontal:
            contentView.frame = CGRect(x: 0, y: 0, width: 0, height: bounds.height)
            contentView.dr_flex.layout(mode: .adjustWidth)
            let contentWidth = max(contentView.frame.width, bounds.width)
            self.scrollView.contentSize = CGSize(width: contentWidth, height: bounds.height)
        case .vertical:
            contentView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 0)
            contentView.dr_flex.layout(mode: .adjustHeight)
            let contentHeight = max(bounds.height, contentView.frame.height)
            self.scrollView.contentSize = CGSize(width: bounds.width, height: contentHeight)
        }
        layoutSubviewsFinishCallback?()
    }
    
    /// 获取容器的子视图
    public var contentSubviews: [UIView] { contentView.subviews }
    /**
     添加子视图到容器中
     
     - Returns: 添加的子视图
     */
    @discardableResult
    public func addContentSubview(_ view: UIView) -> UIView {
        contentView.addSubview(view)
        return view
    }
    /// 获取容器中指定tag的子视图
    public func contentViewWithTag(_ tag: Int) -> UIView? {
        contentView.viewWithTag(tag)
    }
    /// 绑定容器视图布局完成回调
    public func layoutFinish<T: AnyObject>(_ target: T, binding: @escaping (_ target: T)->Void) {
        weak var weakTarget = target
        self.layoutSubviewsFinishCallback = {
            if let target = weakTarget {
                binding(target)
            }
        }
    }
    
    public override var backgroundColor: UIColor?{
        didSet {
            self.scrollView.backgroundColor = self.backgroundColor
            self.contentView.backgroundColor = self.backgroundColor
        }
    }
    
}


// MARK: - UIScrollView 代理回调

fileprivate class DrFlexScrollViewProxy: NSObject, UIScrollViewDelegate {
    
    let binder: DrFlexScrollViewCallback
    
    init(binder: DrFlexScrollViewCallback) {
        self.binder = binder
        super.init()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        binder.didScroll?(scrollView)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        binder.scrollViewDidZoom?(scrollView)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        binder.scrollViewWillBeginDragging?(scrollView)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        binder.scrollViewWillEndDragging?(scrollView, velocity, targetContentOffset)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        binder.scrollViewDidEndDragging?(scrollView, decelerate)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        binder.scrollViewWillBeginDecelerating?(scrollView)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        binder.scrollViewDidEndDecelerating?(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        binder.scrollViewDidEndScrollingAnimation?(scrollView)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        binder.viewForZooming?(scrollView)
    }

    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        binder.scrollViewWillBeginZooming?(scrollView, view)
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        binder.scrollViewDidEndZooming?(scrollView, view, scale)
    }

    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        binder.scrollViewShouldScrollToTop?(scrollView) ?? true
    }

    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        binder.scrollViewDidScrollToTop?(scrollView)
    }
    
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        binder.didChangeAdjustedContentInset?(scrollView)
    }
    
}

// MARK: - UIScrollView 相关

extension DrFlexScrollView {
    
    /// default CGPointZero
    public var contentOffset: CGPoint {
        set {
            scrollView.contentOffset = newValue
        }
        get {
            scrollView.contentOffset
        }
    }

    /// default CGSizeZero
    public var contentSize: CGSize {
        set {
            scrollView.contentSize = newValue
        }
        get {
            scrollView.contentSize
        }
    }

    /// default UIEdgeInsetsZero. add additional scroll area around content
    public var contentInset: UIEdgeInsets {
        set {
            scrollView.contentInset = newValue
        }
        get {
            scrollView.contentInset
        }
    }

    
    /* When contentInsetAdjustmentBehavior allows, UIScrollView may incorporate
     its safeAreaInsets into the adjustedContentInset.
     */
    @available(iOS 11.0, *)
    public var adjustedContentInset: UIEdgeInsets { scrollView.adjustedContentInset }

    
    /* Configure the behavior of adjustedContentInset.
     Default is UIScrollViewContentInsetAdjustmentAutomatic.
     */
    @available(iOS 11.0, *)
    public var contentInsetAdjustmentBehavior: UIScrollView.ContentInsetAdjustmentBehavior {
        set {
            scrollView.contentInsetAdjustmentBehavior = newValue
        }
        get {
            scrollView.contentInsetAdjustmentBehavior
        }
    }

    
    /* Configures whether the scroll indicator insets are automatically adjusted by the system.
     Default is YES.
     */
    @available(iOS 13.0, *)
    public var automaticallyAdjustsScrollIndicatorInsets: Bool {
        set {
            scrollView.automaticallyAdjustsScrollIndicatorInsets = newValue
        }
        get {
            scrollView.automaticallyAdjustsScrollIndicatorInsets
        }
    }

    /// default NO. if YES, try to lock vertical or horizontal scrolling while dragging
    public var isDirectionalLockEnabled: Bool {
        set {
            scrollView.isDirectionalLockEnabled = newValue
        }
        get {
            scrollView.isDirectionalLockEnabled
        }
    }

    /// default YES. if YES, bounces past edge of content and back again
    public var bounces: Bool {
        set {
            scrollView.bounces = newValue
        }
        get {
            scrollView.bounces
        }
    }

    /// default NO. if YES and bounces is YES, even if content is smaller than bounds, allow drag vertically
    public var alwaysBounceVertical: Bool {
        set {
            scrollView.alwaysBounceVertical = newValue
        }
        get {
            scrollView.alwaysBounceVertical
        }
    }

    /// default NO. if YES and bounces is YES, even if content is smaller than bounds, allow drag horizontally
    public var alwaysBounceHorizontal: Bool {
        set {
            scrollView.alwaysBounceHorizontal = newValue
        }
        get {
            scrollView.alwaysBounceHorizontal
        }
    }

    /// default NO. if YES, stop on multiples of view bounds
    public var isPagingEnabled: Bool {
        set {
            scrollView.isPagingEnabled = newValue
        }
        get {
            scrollView.isPagingEnabled
        }
    }

    /// default YES. turn off any dragging temporarily
    public var isScrollEnabled: Bool {
        set {
            scrollView.isScrollEnabled = newValue
        }
        get {
            scrollView.isScrollEnabled
        }
    }

    /// default YES. show indicator while we are tracking. fades out after tracking
    public var showsVerticalScrollIndicator: Bool {
        set {
            scrollView.showsVerticalScrollIndicator = newValue
        }
        get {
            scrollView.showsVerticalScrollIndicator
        }
    }

    /// default YES. show indicator while we are tracking. fades out after tracking
    public var showsHorizontalScrollIndicator: Bool {
        set {
            scrollView.showsHorizontalScrollIndicator = newValue
        }
        get {
            scrollView.showsHorizontalScrollIndicator
        }
    }

    /// default is UIScrollViewIndicatorStyleDefault
    public var indicatorStyle: UIScrollView.IndicatorStyle {
        set {
            scrollView.indicatorStyle = newValue
        }
        get {
            scrollView.indicatorStyle
        }
    }

    
    /// default is UIEdgeInsetsZero.
    @available(iOS 11.1, *)
    public var verticalScrollIndicatorInsets: UIEdgeInsets {
        set {
            scrollView.verticalScrollIndicatorInsets = newValue
        }
        get {
            scrollView.verticalScrollIndicatorInsets
        }
    }

    /// default is UIEdgeInsetsZero.
    @available(iOS 11.1, *)
    public var horizontalScrollIndicatorInsets: UIEdgeInsets {
        set {
            scrollView.horizontalScrollIndicatorInsets = newValue
        }
        get {
            scrollView.horizontalScrollIndicatorInsets
        }
    }

    /// use the setter only, as a convenience for setting both verticalScrollIndicatorInsets and horizontalScrollIndicatorInsets to the same value. if those properties have been set to different values, the return value of this getter (deprecated) is undefined.
    public var scrollIndicatorInsets: UIEdgeInsets {
        set {
            scrollView.scrollIndicatorInsets = newValue
        }
        get {
            scrollView.scrollIndicatorInsets
        }
    }

    
    @available(iOS 3.0, *)
    public var decelerationRate: UIScrollView.DecelerationRate {
        set {
            scrollView.decelerationRate = newValue
        }
        get {
            scrollView.decelerationRate
        }
    }

    public var indexDisplayMode: UIScrollView.IndexDisplayMode {
        set {
            scrollView.indexDisplayMode = newValue
        }
        get {
            scrollView.indexDisplayMode
        }
    }

    /// animate at constant velocity to new offset
    public func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        scrollView.setContentOffset(contentOffset, animated: animated)
    }

    /// scroll so rect is just visible (nearest edges). nothing if rect completely visible
    public func scrollRectToVisible(_ rect: CGRect, animated: Bool) {
        scrollView.scrollRectToVisible(rect, animated: animated)
    }

    /// displays the scroll indicators for a short time. This should be done whenever you bring the scroll view to front.
    public func flashScrollIndicators() {
        scrollView.flashScrollIndicators()
    }

    
    /*
     Scrolling with no scroll bars is a bit complex. on touch down, we don't know if the user will want to scroll or track a subview like a control.
     on touch down, we start a timer and also look at any movement. if the time elapses without sufficient change in position, we start sending events to
     the hit view in the content subview. if the user then drags far enough, we switch back to dragging and cancel any tracking in the subview.
     the methods below are called by the scroll view and give subclasses override points to add in custom behavior.
     you can remove the delay in delivery of touchesBegan:withEvent: to subviews by setting delaysContentTouches to NO.
     */
    
    public var isTracking: Bool { scrollView.isTracking } // returns YES if user has touched. may not yet have started dragging

    /// returns YES if user has started scrolling. this may require some time and or distance to move to initiate dragging
    public var isDragging: Bool { scrollView.isDragging }

    /// returns YES if user isn't dragging (touch up) but scroll view is still moving
    public var isDecelerating: Bool { scrollView.isDecelerating }

    /// default is YES. if NO, we immediately call -touchesShouldBegin:withEvent:inContentView:. this has no effect on presses
    public var delaysContentTouches: Bool {
        set {
            scrollView.delaysContentTouches = newValue
        }
        get {
            scrollView.delaysContentTouches
        }
    }

    /// default is YES. if NO, then once we start tracking, we don't try to drag if the touch moves. this has no effect on presses
    public var canCancelContentTouches: Bool {
        set {
            scrollView.canCancelContentTouches = newValue
        }
        get {
            scrollView.canCancelContentTouches
        }
    }

    
    /*
     the following properties and methods are for zooming. as the user tracks with two fingers, we adjust the offset and the scale of the content. When the gesture ends, you should update the content
     as necessary. Note that the gesture can end and a finger could still be down. While the gesture is in progress, we do not send any tracking calls to the subview.
     the delegate must implement both viewForZoomingInScrollView: and scrollViewDidEndZooming:withView:atScale: in order for zooming to work and the max/min zoom scale must be different
     note that we are not scaling the actual scroll view but the 'content view' returned by the delegate. the delegate must return a subview, not the scroll view itself, from viewForZoomingInScrollview:
     */
    
    public var minimumZoomScale: CGFloat {
        set {
            scrollView.minimumZoomScale = newValue
        }
        get {
            scrollView.minimumZoomScale
        }
    }

    /// default is 1.0. must be > minimum zoom scale to enable zooming
    public var maximumZoomScale: CGFloat {
        set {
            scrollView.maximumZoomScale = newValue
        }
        get {
            scrollView.maximumZoomScale
        }
    }

    
    /// default is 1.0
    @available(iOS 3.0, *)
    public var zoomScale: CGFloat {
        set {
            scrollView.zoomScale = newValue
        }
        get {
            scrollView.zoomScale
        }
    }

    @available(iOS 3.0, *)
    public func setZoomScale(_ scale: CGFloat, animated: Bool) {
        scrollView.setZoomScale(scale, animated: animated)
    }

    @available(iOS 3.0, *)
    public func zoom(to rect: CGRect, animated: Bool) {
        scrollView.zoom(to: rect, animated: animated)
    }

    
    /// default is YES. if set, user can go past min/max zoom while gesturing and the zoom will animate to the min/max value at gesture end
    public var bouncesZoom: Bool {
        set {
            scrollView.bouncesZoom = newValue
        }
        get {
            scrollView.bouncesZoom
        }
    }

    
    /// returns YES if user in zoom gesture
    public var isZooming: Bool { scrollView.isZooming }

    /// returns YES if we are in the middle of zooming back to the min/max value
    public var isZoomBouncing: Bool { scrollView.isZoomBouncing }

    
    // When the user taps the status bar, the scroll view beneath the touch which is closest to the status bar will be scrolled to top, but only if its `scrollsToTop` property is YES, its delegate does not return NO from `-scrollViewShouldScrollToTop:`, and it is not already at the top.
    // On iPhone, we execute this gesture only if there's one on-screen scroll view with `scrollsToTop` == YES. If more than one is found, none will be scrolled.
    // default is YES.
    public var scrollsToTop: Bool {
        set {
            scrollView.scrollsToTop = newValue
        }
        get {
            scrollView.scrollsToTop
        }
    }

    
    // Use these accessors to configure the scroll view's built-in gesture recognizers.
    // Do not change the gestures' delegates or override the getters for these properties.
    
    // Change `panGestureRecognizer.allowedTouchTypes` to limit scrolling to a particular set of touch types.
    @available(iOS 5.0, *)
    public var panGestureRecognizer: UIPanGestureRecognizer { scrollView.panGestureRecognizer }

    // `pinchGestureRecognizer` will return nil when zooming is disabled.
    @available(iOS 5.0, *)
    public var pinchGestureRecognizer: UIPinchGestureRecognizer? { scrollView.pinchGestureRecognizer }

    // `directionalPressGestureRecognizer` is disabled by default, but can be enabled to perform scrolling in response to up / down / left / right arrow button presses directly, instead of scrolling indirectly in response to focus updates.
    public var directionalPressGestureRecognizer: UIGestureRecognizer { scrollView.directionalPressGestureRecognizer }

    
    /// default is UIScrollViewKeyboardDismissModeNone
    @available(iOS 7.0, *)
    public var keyboardDismissMode: UIScrollView.KeyboardDismissMode {
        set {
            scrollView.keyboardDismissMode = newValue
        }
        get {
            scrollView.keyboardDismissMode
        }
    }
    
    @available(iOS 10.0, *)
    public var refreshControl: UIRefreshControl? {
        set {
            scrollView.refreshControl = newValue
        }
        get {
            scrollView.refreshControl
        }
    }
}
