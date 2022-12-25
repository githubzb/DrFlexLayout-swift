//
//  DrFlexLayout.swift
//  DrFlexLayout
//
//  Created by dr.box on 2021/10/18.
//

import UIKit

public typealias DrLayoutCallbackAction = (UIView?) -> Void

public final class DrFlex {
    
    // MARK: - Properties
    
    /**
     Flex items's UIView.
    */
    public private(set) weak var view: UIView?
    private let yoga: YGLayout
    
    /**
     Item natural size, considering only properties of the view itself. Independent of the item frame.
     This could equivalent to calling view.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude));
     */
    public var intrinsicSize: CGSize {
        self.view?.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        return yoga.intrinsicSize
    }
    
    init(view: UIView) {
        self.view = view
        self.yoga = view.yoga
        
        // Enable flexbox and overwrite Yoga default values.
        yoga.isEnabled = true
    }
    
    // MARK: - layout callback
    
    /**
     This method used to receive a callback after the current UIView Flex layout has finished.
     You can add gradients and other operations to the current UIView in the callback.
     */
    public func layoutFinished(_ finished: @escaping DrLayoutCallbackAction) {
        self.view?.addLayoutFinish(finished)
    }
    
    /**
     This method used to receive a callback after the current UIView Flex layout has finished.
     You can add gradients and other operations to the current UIView in the callback.
     */
    public func layoutFinished(_ finished: @escaping DrLayoutCallbackAction, forKey key: String) {
        self.view?.addLayoutFinish(finished, forKey: key)
    }
    
    // MARK: - Flex item addition 、remove and definition
    
    /**
     This method adds a flex item (UIView) to a flex container. Internally the methods adds the UIView has subviews and enables flexbox.
    
     - Returns: The added view flex interface
     */
    @discardableResult
    public func addItem() -> DrFlex {
        let view = UIView()
        return addItem(view)
    }
    
    /**
     This method is similar to `addItem(: UIView)` except that it also creates the flex item's UIView. Internally the method creates an
     UIView, adds it has subviews and enables flexbox. This is useful to add a flex item/container easily when you don't need to refer to it later.
    
     - Parameter view: view to add to the flex container
     - Returns: The added view flex interface
     */
    @discardableResult
    public func addItem(_ view: UIView) -> DrFlex {
        if let host = self.view {
            if view.superview == nil {
                host.addSubview(view)
            }
            return view.dr_flex
        } else {
            preconditionFailure("Trying to modify deallocated host view")
        }
    }
    
    /**
     This method removes the current view from the parent view and removes the layout nodes along with it.
     If only the view is removed, but the layout node relationship is not removed, this can cause problems:
     Child already has a owner, it must be removed first.
     
     - Returns: self.view
     */
    @discardableResult
    public func removeFromSuperview() -> UIView {
        if let host = self.view {
            if let isYoga = host.superview?.isYogaEnabled, isYoga {
                host.superview?.yoga.remove(child: host.yoga)
            }
            host.removeFromSuperview()
            return host
        }else {
            preconditionFailure("Trying to modify deallocated host view")
        }
    }

    /**
     This method is used to structure your code so that it matches the flexbox structure. The method has a closure parameter with a
     single parameter called `flex`. This parameter is in fact, the view's flex interface, it can be used to adds other flex items
     and containers.
    
     - Parameter closure:
     - Returns: Flex interface
    */
    @discardableResult
    public func define(_ closure: (_ flex: DrFlex) -> Void) -> DrFlex {
        closure(self)
        return self
    }
    
    // MARK: - Layout / intrinsicSize / sizeThatFits
    
    /**
     The method layout the flex container's children with synchronous
    
     - Parameter mode: specify the layout mod (LayoutMode).
    */
    public func layout(mode: LayoutMode = .fitContainer) {
        if case .fitContainer = mode {
            yoga.applyLayout(preservingOrigin: true)
        } else {
            yoga.applyLayout(preservingOrigin: true, dimensionFlexibility: mode == .adjustWidth ? YGDimensionFlexibility.flexibleWidth : YGDimensionFlexibility.flexibleHeight)
        }
    }
    
    /**
     The method layout the flex container's children with asynchronous
    
     - Parameter mode: specify the layout mod (LayoutMode).
    */
    public func layoutByAsync(mode: LayoutMode = .fitContainer) {
        if case .fitContainer = mode {
            yoga.async_applyLayout(preservingOrigin: true)
        } else {
            yoga.async_applyLayout(preservingOrigin: true, dimensionFlexibility: mode == .adjustWidth ? YGDimensionFlexibility.flexibleWidth : YGDimensionFlexibility.flexibleHeight)
        }
    }
    
    /**
     This property controls dynamically if a flexbox's UIView is included or not in the flexbox layouting. When a
     flexbox's UIView is excluded, FlexLayout won't layout the view and its children views.
    */
    public var isIncludedInLayout: Bool {
        get {
            return yoga.isIncludedInLayout
        }
        set {
            yoga.isIncludedInLayout = newValue
        }
    }
    
    /**
     This method controls dynamically if a flexbox's UIView is included or not in the flexbox layouting. When a
     flexbox's UIView is excluded, FlexLayout won't layout the view and its children views.
    
     - Parameter included: true to layout the view
     - Returns:
     */
    @discardableResult
    public func isIncludedInLayout(_ included: Bool) -> DrFlex {
        self.isIncludedInLayout = included
        return self
    }

    /**
     The framework is so highly optimized, that flex item are layouted only when a flex property is changed and when flex container
     size change. In the event that you want to force FlexLayout to do a layout of a flex item, you can mark it as dirty
     using `markDirty()`.
     
     Dirty flag propagates to the root of the flexbox tree ensuring that when any item is invalidated its whole subtree will be re-calculated
    
     - Returns: Flex interface
    */
    @discardableResult
    public func markDirty() -> DrFlex {
        yoga.markDirty()
        return self
    }
    
    /**
     Returns the item size when layouted in the specified frame size
    
     - Parameter size: frame size
     - Returns: item size
    */
    public func sizeThatFits(size: CGSize) -> CGSize {
        return yoga.calculateLayout(with: size)
    }
    
    
    // MARK: - Direction, wrap, flow
    
    /**
     The `direction` property establishes the main-axis, thus defining the direction flex items are placed in the flex container.
    
     The `direction` property specifies how flex items are laid out in the flex container, by setting the direction of the flex
     container’s main axis. They can be laid out in two main directions,  like columns vertically or like rows horizontally.
    
     Note that row and row-reverse are affected by the layout direction (see `layoutDirection` property) of the flex container.
     If its text direction is LTR (left to right), row represents the horizontal axis oriented from left to right, and row-reverse
     from right to left; if the direction is rtl, it's the opposite.
    
     - Parameter value: Default value is .column
    */
    @discardableResult
    public func direction(_ value: Direction) -> DrFlex {
        yoga.flexDirection = value.yogaValue
        return self
    }
    
    /**
     The `wrap` property controls whether the flex container is single-lined or multi-lined, and the direction of the cross-axis, which determines the direction in which the new lines are stacked in.
    
     - Parameter value: Default value is .noWrap
    */
    @discardableResult
    public func wrap(_ value: Wrap) -> DrFlex {
        yoga.flexWrap = value.yogaValue
        return self
    }
    
    /**
     Direction defaults to Inherit on all nodes except the root which defaults to LTR. It is up to you to detect the
     user’s preferred direction (most platforms have a standard way of doing this) and setting this direction on the
     root of your layout tree.
    
     - Parameter value: new LayoutDirection
     - Returns:
    */
    @discardableResult
    public func layoutDirection(_ value: LayoutDirection) -> DrFlex {
        // WORK IN PROGRESS :-)
        /*switch value {
        case .auto:
            let userInterfaceLayoutDirection: UIUserInterfaceLayoutDirection
            if #available(iOS 9.0, *) {
                userInterfaceLayoutDirection = UIView.userInterfaceLayoutDirection(for: view.semanticContentAttribute)
            } else {
                userInterfaceLayoutDirection = UIApplication.shared.userInterfaceLayoutDirection
            }
            yoga.direction = userInterfaceLayoutDirection == .leftToRight ? YGDirection.LTR : YGDirection.RTL
        default:*/
        yoga.direction = value.yogaValue
        //}
        return self
    }
    
    // MARK: justity, alignment, position
    
    /**
     The `justifyContent` property defines the alignment along the main-axis of the current line of the flex container.
     It helps distribute extra free space leftover when either all the flex items on a line have reached their maximum
     size. For example, if children are flowing vertically, `justifyContent` controls how they align vertically.
    
     - Parameter value: Default value is .start
    */
    @discardableResult
    public func justifyContent(_ value: JustifyContent) -> DrFlex {
        yoga.justifyContent = value.yogaValue
        return self
    }
    
    /**
     The `alignItems` property defines how flex items are laid out along the cross axis on the current line.
     Similar to `justifyContent` but for the cross-axis (perpendicular to the main-axis). For example, if
     children are flowing vertically, `alignItems` controls how they align horizontally.
     
     - Parameter value: Default value is .stretch
     */
    @discardableResult
    public func alignItems(_ value: AlignItems) -> DrFlex {
        yoga.alignItems = value.yogaValue
        return self
    }
    
    /**
     The `alignSelf` property controls how a child aligns in the cross direction, overriding the `alignItems`
     of the parent. For example, if children are flowing vertically, `alignSelf` will control how the flex item
     will align horizontally.
    
     - Parameter value: Default value is .auto
    */
    @discardableResult
    public func alignSelf(_ value: AlignSelf) -> DrFlex {
        yoga.alignSelf = value.yogaValue
        return self
    }
    
    /**
     The align-content property aligns a flex container’s lines within the flex container when there is extra space
     in the cross-axis, similar to how justifyContent aligns individual items within the main-axis.
     
     - Parameter value: Default value is .start
     */
    @discardableResult
    public func alignContent(_ value: AlignContent) -> DrFlex {
        yoga.alignContent = value.yogaValue
        return self
    }
    
    // MARK: - grow / shrink / basis / flex
    
    /**
     The `grow` property defines the ability for a flex item to grow if necessary. It accepts a unitless value
     that serves as a proportion. It dictates what amount of the available space inside the flex container the
     item should take up.
    
     - Parameter value: Default value is 0
    */
    @discardableResult
    public func grow(_ value: CGFloat) -> DrFlex {
        yoga.flexGrow = value
       return self
    }
    
    /**
     It specifies the "flex shrink factor", which determines how much the flex item will shrink relative to the
     rest of the flex items in the flex container when there isn't enough space on the main-axis.
    
     When omitted, it is set to 0 and the flex shrink factor is multiplied by the flex `basis` when distributing
     negative space.
    
     A shrink value of 0 keeps the view's size in the main-axis direction. Note that this may cause the view to
     overflow its flex container.
    
     - Parameter value: Default value is 0
    */
    @discardableResult
    public func shrink(_ value: CGFloat) -> DrFlex {
        yoga.flexShrink = value
        return self
    }

    /**
     This property takes the same values as the width and height properties, and specifies the initial size of the
     flex item, before free space is distributed according to the grow and shrink factors.
    
     Specifying `nil` set the basis as `auto`, which means the length is equal to the length of the item. If the
     item has no length specified, the length will be according to its content.
    
     - Parameter value: Default value is 0
    */
    @discardableResult
    public func basis(_ value: CGFloat?) -> DrFlex {
        yoga.flexBasis = valueOrAuto(value)
        return self
    }

    /**
     This property takes the same values as the width and height properties, and specifies the initial size of the
     flex item, before free space is distributed according to the grow and shrink factors.
    
     Specifying `nil` set the basis as `auto`, which means the length is equal to the length of the item. If the
     item has no length specified, the length will be according to its content.
    */
    @discardableResult
    public func basis(_ percent: DrPercent) -> DrFlex {
        yoga.flexBasis = YGValue(value: Float(percent.value), unit: .percent)
        return self
    }
    
    /**
     This is the shorthand for flex-grow, flex-shrink and flex-basis combined.
     The default is 0, but if you set it with a single number value, it’s like 1.
     */
    @discardableResult
    public func flex(_ value: CGFloat) -> DrFlex {
        yoga.flex = value
        return self
    }
    
    // MARK: - Width / height
    
    /**
     The value specifies the view's width in pixels. The value must be non-negative.
    */
    @discardableResult
    public func width(_ value: CGFloat?) -> DrFlex {
        yoga.width = valueOrAuto(value)
        return self
    }
    
    /**
     The value specifies the view's width in percentage of its container width. The value must be non-negative.
     Example: view.dr_flex.width(20%)
     */
    @discardableResult
    public func width(_ percent: DrPercent) -> DrFlex {
        yoga.width = YGValue(value: Float(percent.value), unit: .percent)
        return self
    }
    
    /**
     The value specifies the view's height in pixels. The value must be non-negative.
     */
    @discardableResult
    public func height(_ value: CGFloat?) -> DrFlex {
        yoga.height = valueOrAuto(value)
        return self
    }
    
    /**
     The value specifies the view's height in percentage of its container height. The value must be non-negative.
     Example: view.dr_flex.height(40%)
     */
    @discardableResult
    public func height(_ percent: DrPercent) -> DrFlex {
        yoga.height = YGValue(value: Float(percent.value), unit: .percent)
        return self
    }
    
    /**
     The value specifies view's width and the height in pixels. Values must be non-negative.
     */
    @discardableResult
    public func size(_ size: CGSize?) -> DrFlex {
        return self.size(width: size?.width, height: size?.height)
    }
    
    /**
     The value specifies the width and the height of the view in pixels, creating a square view. Values must be non-negative.
     */
    @discardableResult
    public func size(_ sideLength: CGFloat) -> DrFlex {
        yoga.width = YGValue(sideLength)
        yoga.height = YGValue(sideLength)
        return self
    }
    
    /**
     The value specifies the view's width and height in pixels. The value must be non-negative.
     */
    @discardableResult
    public func size(width: CGFloat?, height: CGFloat?) -> DrFlex {
        yoga.width = valueOrAuto(width)
        yoga.height = valueOrAuto(height)
        return self
    }
    
    /**
     The value specifies the view's width and height in percentage of its container width and height. The value must be non-negative.
     Example: view.dr_flex.size(widthPercent: 50%, heightPercent: 50%)
     */
    @discardableResult
    public func size(widthPercent: DrPercent, heightPercent: DrPercent) -> DrFlex {
        yoga.width = YGValue(value: Float(widthPercent.value), unit: .percent)
        yoga.height = YGValue(value: Float(heightPercent.value), unit: .percent)
        return self
    }

    /**
     The value specifies the view's minimum width in pixels. The value must be non-negative.
     */
    @discardableResult
    public func minWidth(_ value: CGFloat?) -> DrFlex {
        yoga.minWidth = valueOrUndefined(value)
        return self
    }
    
    /**
     The value specifies the view's minimum width in percentage of its container width. The value must be non-negative.
     */
    @discardableResult
    public func minWidth(_ percent: DrPercent) -> DrFlex {
        yoga.minWidth = YGValue(value: Float(percent.value), unit: .percent)
        return self
    }

    /**
     The value specifies the view's maximum width in pixels. The value must be non-negative.
     */
    @discardableResult
    public func maxWidth(_ value: CGFloat?) -> DrFlex {
        yoga.maxWidth = valueOrUndefined(value)
        return self
    }
    
    /**
     The value specifies the view's maximum width in percentage of its container width. The value must be non-negative.
     */
    @discardableResult
    public func maxWidth(_ percent: DrPercent) -> DrFlex {
        yoga.maxWidth = YGValue(value: Float(percent.value), unit: .percent)
        return self
    }
    
    /**
     The value specifies the view's minimum height in pixels. The value must be non-negative.
     */
    @discardableResult
    public func minHeight(_ value: CGFloat?) -> DrFlex {
        yoga.minHeight = valueOrUndefined(value)
        return self
    }
    
    /**
     The value specifies the view's minimum height in percentage of its container height. The value must be non-negative.
     */
    @discardableResult
    public func minHeight(_ percent: DrPercent) -> DrFlex {
        yoga.minHeight = YGValue(value: Float(percent.value), unit: .percent)
        return self
    }

    /**
     The value specifies the view's maximum height in pixels. The value must be non-negative.
     */
    @discardableResult
    public func maxHeight(_ value: CGFloat?) -> DrFlex {
        yoga.maxHeight = valueOrUndefined(value)
        
        return self
    }
    
    /**
     The value specifies the view's maximum height in percentage of its container height. The value must be non-negative.
     */
    @discardableResult
    public func maxHeight(_ percent: DrPercent) -> DrFlex {
        yoga.maxHeight = YGValue(value: Float(percent.value), unit: .percent)
        return self
    }
    
    /**
     AspectRatio is a property introduced by Yoga that don't exist in CSS. AspectRatio solves the problem of knowing
     one dimension of an element and an aspect ratio, this is very common when it comes to images, videos, and other
     media types. AspectRatio accepts any floating point value > 0, the default is undefined.
    
     - Parameter value:
     - Returns:
    */
    @discardableResult
    public func aspectRatio(_ value: CGFloat?) -> DrFlex {
        yoga.aspectRatio = value != nil ? value! : CGFloat(YGValueUndefined.value)
        return self
    }
    
    /**
     AspectRatio is a property introduced by Yoga that don't exist in CSS. AspectRatio solves the problem of knowing
     one dimension of an element and an aspect ratio, this is very common when it comes to images, videos, and other
     media types. AspectRatio accepts any floating point value > 0, the default is undefined.
    
     - Parameter value:
     - Returns:
    */
    @discardableResult
    public func aspectRatio(of imageView: UIImageView) -> DrFlex {
        if let imageSize = imageView.image?.size {
            yoga.aspectRatio = imageSize.width / imageSize.height
        }
        return self
    }
    
    // MARK: - Absolute positionning
    
    /**
     The position property tells Flexbox how you want your item to be positioned within its parent.
     
     - Parameter value: Default value is .relative
     */
    @discardableResult
    public func position(_ value: Position) -> DrFlex {
        yoga.position = value.yogaValue
        return self
    }
    
    /**
     Set the left edge distance from the container left edge in pixels.
     This method is valid only when the item position is absolute (`view.dr_flex.position(.absolute)`)
     */
    @discardableResult
    public func left(_ value: CGFloat) -> DrFlex {
        yoga.left = YGValue(value)
        return self
    }

    /**
     Set the left edge distance from the container left edge in percentage of its container width.
     This method is valid only when the item position is absolute (`view.dr_flex.position(.absolute)`)
     */
    @discardableResult
    public func left(_ percent: DrPercent) -> DrFlex {
        yoga.left = YGValue(value: Float(percent.value), unit: .percent)
        return self
    }
    
    /**
     Set the top edge distance from the container top edge in pixels.
     This method is valid only when the item position is absolute (`view.dr_flex.position(.absolute)`)
     */
    @discardableResult
    public func top(_ value: CGFloat) -> DrFlex {
        yoga.top = YGValue(value)
        return self
    }

    /**
     Set the top edge distance from the container top edge in percentage of its container height.
     This method is valid only when the item position is absolute (`view.dr_flex.position(.absolute)`)
     */
    @discardableResult
    public func top(_ percent: DrPercent) -> DrFlex {
        yoga.top = YGValue(value: Float(percent.value), unit: .percent)
        return self
    }
    
    /**
     Set the right edge distance from the container right edge in pixels.
     This method is valid only when the item position is absolute (`view.dr_flex.position(.absolute)`)
     */
    @discardableResult
    public func right(_ value: CGFloat) -> DrFlex {
        yoga.right = YGValue(value)
        return self
    }

    /**
     Set the right edge distance from the container right edge in percentage of its container width.
     This method is valid only when the item position is absolute (`view.dr_flex.position(.absolute)`)
     */
    @discardableResult
    public func right(_ percent: DrPercent) -> DrFlex {
        yoga.right = YGValue(value: Float(percent.value), unit: .percent)
        return self
    }

    /**
     Set the bottom edge distance from the container bottom edge in pixels.
     This method is valid only when the item position is absolute (`view.dr_flex.position(.absolute)`)
     */
    @discardableResult
    public func bottom(_ value: CGFloat) -> DrFlex {
        yoga.bottom = YGValue(value)
        return self
    }

    /**
     Set the bottom edge distance from the container bottom edge in percentage of its container height.
     This method is valid only when the item position is absolute (`view.dr_flex.position(.absolute)`)
     */
    @discardableResult
    public func bottom(_ percent: DrPercent) -> DrFlex {
        yoga.bottom = YGValue(value: Float(percent.value), unit: .percent)
        return self
    }
    
    /**
     Set the start edge (LTR=left, RTL=right) distance from the container start edge in pixels.
     This method is valid only when the item position is absolute (`view.dr_flex.position(.absolute)`)
     */
    @discardableResult
    public func start(_ value: CGFloat) -> DrFlex {
        yoga.start = YGValue(value)
        return self
    }

    /**
     Set the start edge (LTR=left, RTL=right) distance from the container start edge in
     percentage of its container width.
     This method is valid only when the item position is absolute (`view.dr_flex.position(.absolute)`)
     */
    @discardableResult
    public func start(_ percent: DrPercent) -> DrFlex {
        yoga.start = YGValue(value: Float(percent.value), unit: .percent)
        return self
    }
    
    /**
     Set the end edge (LTR=right, RTL=left) distance from the container end edge in pixels.
     This method is valid only when the item position is absolute (`view.dr_flex.position(.absolute)`)
     */
    @discardableResult
    public func end(_ value: CGFloat) -> DrFlex {
        yoga.end = YGValue(value)
        return self
    }

    /**
     Set the end edge (LTR=right, RTL=left) distance from the container end edge in
     percentage of its container width.
     This method is valid only when the item position is absolute (`view.dr_flex.position(.absolute)`)
     */
    @discardableResult
    public func end(_ percent: DrPercent) -> DrFlex {
        yoga.end = YGValue(value: Float(percent.value), unit: .percent)
        return self
    }
    
    /**
      Set the left and right edges distance from the container edges in pixels.
      This method is valid only when the item position is absolute (`view.dr_flex.position(.absolute)`)
      */
    @discardableResult
    public func horizontally(_ value: CGFloat) -> DrFlex {
        yoga.left = YGValue(value)
        yoga.right = YGValue(value)
        return self
     }

     /**
      Set the left and right edges distance from the container edges in percentage of its container width.
      This method is valid only when the item position is absolute (`view.dr_flex.position(.absolute)`)
      */
    @discardableResult
    public func horizontally(_ percent: DrPercent) -> DrFlex {
        yoga.left = YGValue(value: Float(percent.value), unit: .percent)
        yoga.right = YGValue(value: Float(percent.value), unit: .percent)
        return self
    }
    
    /**
     Set the top and bottom edges distance from the container edges in pixels.
     This method is valid only when the item position is absolute (`view.dr_flex.position(.absolute)`)
     */
    @discardableResult
    public func vertically(_ value: CGFloat) -> DrFlex {
        yoga.top = YGValue(value)
        yoga.bottom = YGValue(value)
        return self
    }
    
    /**
     Set the top and bottom edges distance from the container edges in percentage of its container height.
     This method is valid only when the item position is absolute (`view.dr_flex.position(.absolute)`)
     */
    @discardableResult
    public func vertically(_ percent: DrPercent) -> DrFlex {
        yoga.top = YGValue(value: Float(percent.value), unit: .percent)
        yoga.bottom = YGValue(value: Float(percent.value), unit: .percent)
        return self
    }
    
    /**
     Set all edges distance from the container edges in pixels.
     This method is valid only when the item position is absolute (`view.dr_flex.position(.absolute)`)
     */
    @discardableResult
    public func all(_ value: CGFloat) -> DrFlex {
        yoga.top = YGValue(value)
        yoga.left = YGValue(value)
        yoga.bottom = YGValue(value)
        yoga.right = YGValue(value)
        return self
    }
    
    /**
     Set all edges distance from the container edges in percentage of its container size.
     This method is valid only when the item position is absolute (`view.dr_flex.position(.absolute)`)
     */
    @discardableResult
    public func all(_ percent: DrPercent) -> DrFlex {
        yoga.top = YGValue(value: Float(percent.value), unit: .percent)
        yoga.left = YGValue(value: Float(percent.value), unit: .percent)
        yoga.bottom = YGValue(value: Float(percent.value), unit: .percent)
        yoga.right = YGValue(value: Float(percent.value), unit: .percent)
        return self
    }
    
    
    // MARK: - Margins
    
    /**
     Set the top margin. Top margin specify the offset the top edge of the item should have from it’s closest sibling (item) or parent (container).
     */
    @discardableResult
    public func marginTop(_ value: CGFloat) -> DrFlex {
        yoga.marginTop = YGValue(value)
        return self
    }
    
    @discardableResult
    public func marginTop(_ percent: DrPercent) -> DrFlex {
        yoga.marginTop = YGValue(value: Float(percent.value), unit: .percent)
        return self
    }
    
    /**
     Set the left margin. Left margin specify the offset the left edge of the item should have from it’s closest sibling (item) or parent (container).
     */
    @discardableResult
    public func marginLeft(_ value: CGFloat) -> DrFlex {
        yoga.marginLeft = YGValue(value)
        return self
    }
    
    @discardableResult
    public func marginLeft(_ percent: DrPercent) -> DrFlex {
        yoga.marginLeft = YGValue(value: Float(percent.value), unit: .percent)
        return self
    }

    /**
     Set the bottom margin. Bottom margin specify the offset the bottom edge of the item should have from it’s closest sibling (item) or parent (container).
     */
    @discardableResult
    public func marginBottom(_ value: CGFloat) -> DrFlex {
        yoga.marginBottom = YGValue(value)
        return self
    }
    
    @discardableResult
    public func marginBottom(_ percent: DrPercent) -> DrFlex {
        yoga.marginBottom = YGValue(value: Float(percent.value), unit: .percent)
        return self
    }
    
    /**
     Set the right margin. Right margin specify the offset the right edge of the item should have from it’s closest sibling (item) or parent (container).
     */
    @discardableResult
    public func marginRight(_ value: CGFloat) -> DrFlex {
        yoga.marginRight = YGValue(value)
        return self
    }
    
    @discardableResult
    public func marginRight(_ percent: DrPercent) -> DrFlex {
        yoga.marginRight = YGValue(value: Float(percent.value), unit: .percent)
        return self
    }

    /**
     Set the start margin.
     
     Depends on the item `LayoutDirection`:
     * In LTR direction, start margin specify the offset the **left** edge of the item should have from it’s closest sibling (item) or parent (container).
     * IN RTL direction, start margin specify the offset the **right** edge of the item should have from it’s closest sibling (item) or parent (container).
     */
    @discardableResult
    public func marginStart(_ value: CGFloat) -> DrFlex {
        yoga.marginStart = YGValue(value)
        return self
    }
    
    @discardableResult
    public func marginStart(_ percent: DrPercent) -> DrFlex {
        yoga.marginStart = YGValue(value: Float(percent.value), unit: .percent)
        return self
    }
    
    /**
     Set the end margin.
     
     Depends on the item `LayoutDirection`:
     * In LTR direction, end margin specify the offset the **right** edge of the item should have from it’s closest sibling (item) or parent (container).
     * IN RTL direction, end margin specify the offset the **left** edge of the item should have from it’s closest sibling (item) or parent (container).
     */
    @discardableResult
    public func marginEnd(_ value: CGFloat) -> DrFlex {
        yoga.marginEnd = YGValue(value)
        return self
    }
    
    @discardableResult
    public func marginEnd(_ percent: DrPercent) -> DrFlex {
        yoga.marginEnd = YGValue(value: Float(percent.value), unit: .percent)
        return self
    }
    
    /**
     Set the left, right, start and end margins to the specified value.
     */
    @discardableResult
    public func marginHorizontal(_ value: CGFloat) -> DrFlex {
        yoga.marginHorizontal = YGValue(value)
        return self
    }
    
    @discardableResult
    public func marginHorizontal(_ percent: DrPercent) -> DrFlex {
        yoga.marginHorizontal = YGValue(value: Float(percent.value), unit: .percent)
        return self
    }
    
    /**
     Set the top and bottom margins to the specified value.
     */
    @discardableResult
    public func marginVertical(_ value: CGFloat) -> DrFlex {
        yoga.marginVertical = YGValue(value)
        return self
    }
    
    @discardableResult
    public func marginVertical(_ percent: DrPercent) -> DrFlex {
        yoga.marginVertical = YGValue(value: Float(percent.value), unit: .percent)
        return self
    }
    
    /**
     Set all margins using UIEdgeInsets.
     This method is particularly useful to set all margins using iOS 11 `UIView.safeAreaInsets`.
     */
    @discardableResult
    public func margin(_ insets: UIEdgeInsets) -> DrFlex {
        yoga.marginTop = YGValue(insets.top)
        yoga.marginLeft = YGValue(insets.left)
        yoga.marginBottom = YGValue(insets.bottom)
        yoga.marginRight = YGValue(insets.right)
        return self
    }
    
    /**
     Set margins using NSDirectionalEdgeInsets.
     This method is particularly to set all margins using iOS 11 `UIView.directionalLayoutMargins`.
     
     Available only on iOS 11 and higher.
     */
    @available(tvOS 11.0, iOS 11.0, *)
    @discardableResult
    func margin(_ directionalInsets: NSDirectionalEdgeInsets) -> DrFlex {
        yoga.marginTop = YGValue(directionalInsets.top)
        yoga.marginStart = YGValue(directionalInsets.leading)
        yoga.marginBottom = YGValue(directionalInsets.bottom)
        yoga.marginEnd = YGValue(directionalInsets.trailing)
        return self
    }

    /**
     Set all margins to the specified value.
     */
    @discardableResult
    public func margin(_ value: CGFloat) -> DrFlex {
        yoga.margin = YGValue(value)
        return self
    }
    
    @discardableResult
    public func margin(_ percent: DrPercent) -> DrFlex {
        yoga.margin = YGValue(value: Float(percent.value), unit: .percent)
        return self
    }
    
    /**
     Set the individually vertical margins (top, bottom) and horizontal margins (left, right, start, end).
     */
    @discardableResult func margin(_ vertical: CGFloat, _ horizontal: CGFloat) -> DrFlex {
        yoga.marginVertical = YGValue(vertical)
        yoga.marginHorizontal = YGValue(horizontal)
        return self
    }
    
    @discardableResult func margin(_ vertical: DrPercent, _ horizontal: DrPercent) -> DrFlex {
        yoga.marginVertical = YGValue(value: Float(vertical.value), unit: .percent)
        yoga.marginHorizontal = YGValue(value: Float(horizontal.value), unit: .percent)
        return self
    }
    
    /**
     Set the individually top, horizontal margins and bottom margin.
     */
    @discardableResult func margin(_ top: CGFloat, _ horizontal: CGFloat, _ bottom: CGFloat) -> DrFlex {
        yoga.marginTop = YGValue(top)
        yoga.marginHorizontal = YGValue(horizontal)
        yoga.marginBottom = YGValue(bottom)
        return self
    }
    
    @discardableResult func margin(_ top: DrPercent, _ horizontal: DrPercent, _ bottom: DrPercent) -> DrFlex {
        yoga.marginTop = YGValue(value: Float(top.value), unit: .percent)
        yoga.marginHorizontal = YGValue(value: Float(horizontal.value), unit: .percent)
        yoga.marginBottom = YGValue(value: Float(bottom.value), unit: .percent)
        return self
    }

    /**
     Set the individually top, left, bottom and right margins.
     */
    @discardableResult
    public func margin(_ top: CGFloat, _ left: CGFloat, _ bottom: CGFloat, _ right: CGFloat) -> DrFlex {
        yoga.marginTop = YGValue(top)
        yoga.marginLeft = YGValue(left)
        yoga.marginBottom = YGValue(bottom)
        yoga.marginRight = YGValue(right)
        return self
    }
    
    @discardableResult
    public func margin(_ top: DrPercent, _ left: DrPercent, _ bottom: DrPercent, _ right: DrPercent) -> DrFlex {
        yoga.marginTop = YGValue(value: Float(top.value), unit: .percent)
        yoga.marginLeft = YGValue(value: Float(left.value), unit: .percent)
        yoga.marginBottom = YGValue(value: Float(bottom.value), unit: .percent)
        yoga.marginRight = YGValue(value: Float(right.value), unit: .percent)
        return self
    }
    
    // MARK: - Padding
    
    /**
     Set the top padding. Top padding specify the **offset children should have** from the container's top edge.
     */
    @discardableResult
    public func paddingTop(_ value: CGFloat) -> DrFlex {
        yoga.paddingTop = YGValue(value)
        return self
    }

    /**
     Set the left padding. Left padding specify the **offset children should have** from the container's left edge.
     */
    @discardableResult
    public func paddingLeft(_ value: CGFloat) -> DrFlex {
        yoga.paddingLeft = YGValue(value)
        return self
    }

    /**
     Set the bottom padding. Bottom padding specify the **offset children should have** from the container's bottom edge.
     */
    @discardableResult
    public func paddingBottom(_ value: CGFloat) -> DrFlex {
        yoga.paddingBottom = YGValue(value)
        return self
    }

    /**
     Set the top padding. Top padding specify the **offset children should have** from the container's top edge.
     */
    @discardableResult
    public func paddingRight(_ value: CGFloat) -> DrFlex {
        yoga.paddingRight = YGValue(value)
        return self
    }

    /**
     Set the start padding.
     
     Depends on the item `LayoutDirection`:
     * In LTR direction, start padding specify the **offset children should have** from the container's left edge.
     * IN RTL direction, start padding specify the **offset children should have** from the container's right edge.
     */
    @discardableResult
    public func paddingStart(_ value: CGFloat) -> DrFlex {
        yoga.paddingStart = YGValue(value)
        return self
    }

    /**
     Set the end padding.
     
     Depends on the item `LayoutDirection`:
     * In LTR direction, end padding specify the **offset children should have** from the container's right edge.
     * IN RTL direction, end padding specify the **offset children should have** from the container's left edge.
     */
    @discardableResult
    public func paddingEnd(_ value: CGFloat) -> DrFlex {
        yoga.paddingEnd = YGValue(value)
        return self
    }

    /**
     Set the left, right, start and end paddings to the specified value.
     */
    @discardableResult
    public func paddingHorizontal(_ value: CGFloat) -> DrFlex {
        yoga.paddingHorizontal = YGValue(value)
        return self
    }

    /**
     Set the top and bottom paddings to the specified value.
     */
    @discardableResult
    public func paddingVertical(_ value: CGFloat) -> DrFlex {
        yoga.paddingVertical = YGValue(value)
        return self
    }
    
    /**
     Set paddings using UIEdgeInsets.
     This method is particularly useful to set all paddings using iOS 11 `UIView.safeAreaInsets`.
     */
    @discardableResult
    public func padding(_ insets: UIEdgeInsets) -> DrFlex {
        yoga.paddingTop = YGValue(insets.top)
        yoga.paddingLeft = YGValue(insets.left)
        yoga.paddingBottom = YGValue(insets.bottom)
        yoga.paddingRight = YGValue(insets.right)
        return self
    }
    
    /**
     Set paddings using NSDirectionalEdgeInsets.
     This method is particularly to set all paddings using iOS 11 `UIView.directionalLayoutMargins`.
     
     Available only on iOS 11 and higher.
     */
    @available(tvOS 11.0, iOS 11.0, *)
    @discardableResult
    func padding(_ directionalInsets: NSDirectionalEdgeInsets) -> DrFlex {
        yoga.paddingTop = YGValue(directionalInsets.top)
        yoga.paddingStart = YGValue(directionalInsets.leading)
        yoga.paddingBottom = YGValue(directionalInsets.bottom)
        yoga.paddingEnd = YGValue(directionalInsets.trailing)
        return self
    }

    /**
     Set all paddings to the specified value.
     */
    @discardableResult
    public func padding(_ value: CGFloat) -> DrFlex {
        yoga.padding = YGValue(value)
        return self
    }

    /**
     Set the individually vertical paddings (top, bottom) and horizontal paddings (left, right, start, end).
     */
    @discardableResult func padding(_ vertical: CGFloat, _ horizontal: CGFloat) -> DrFlex {
        yoga.paddingVertical = YGValue(vertical)
        yoga.paddingHorizontal = YGValue(horizontal)
        return self
    }
    
    /**
     Set the individually top, horizontal paddings and bottom padding.
     */
    @discardableResult func padding(_ top: CGFloat, _ horizontal: CGFloat, _ bottom: CGFloat) -> DrFlex {
        yoga.paddingTop = YGValue(top)
        yoga.paddingHorizontal = YGValue(horizontal)
        yoga.paddingBottom = YGValue(bottom)
        return self
    }
    
    /**
     Set the individually top, left, bottom and right paddings.
     */
    @discardableResult
    public func padding(_ top: CGFloat, _ left: CGFloat, _ bottom: CGFloat, _ right: CGFloat) -> DrFlex {
        yoga.paddingTop = YGValue(top)
        yoga.paddingLeft = YGValue(left)
        yoga.paddingBottom = YGValue(bottom)
        yoga.paddingRight = YGValue(right)
        return self
    }
    
    // MARK: - Border
    
    /**
     Set the left border width.
     */
    @discardableResult
    public func borderLeftWidth(_ value: CGFloat) -> DrFlex {
        yoga.borderLeftWidth = value
        return self
    }
    
    /**
     Set the top border width.
     */
    @discardableResult
    public func borderTopWidth(_ value: CGFloat) -> DrFlex {
        yoga.borderTopWidth = value
        return self
    }
    
    /**
     Set the right border width.
     */
    @discardableResult
    public func borderRightWidth(_ value: CGFloat) -> DrFlex {
        yoga.borderRightWidth = value
        return self
    }
    
    /**
     Set the bottom border width.
     */
    @discardableResult
    public func borderBottomWidth(_ value: CGFloat) -> DrFlex {
        yoga.borderBottomWidth = value
        return self
    }
    
    /**
     Set the start border width.
     */
    @discardableResult
    public func borderStartWidth(_ value: CGFloat) -> DrFlex {
        yoga.borderStartWidth = value
        return self
    }
    
    /**
     Set the end border width.
     */
    @discardableResult
    public func borderEndWidth(_ value: CGFloat) -> DrFlex {
        yoga.borderEndWidth = value
        return self
    }
    
    /**
     Set the all border width.
     */
    @discardableResult
    public func borderWidth(_ value: CGFloat) -> DrFlex {
        yoga.borderWidth = value
        return self
    }
    
    // MARK: - UIView Visual properties
    
    /**
     Set the view background color.
    
     - Parameter color: new color
     - Returns: flex interface
    */
    @discardableResult
    public func backgroundColor(_ color: UIColor) -> DrFlex {
        if let host = self.view {
            host.backgroundColor = color
            return self
        } else {
            preconditionFailure("Trying to modify deallocated host view")
        }
    }
    
    /**
     Set the view style, include round, border, shadow, gradient.
    
     - Parameter style: DrStyle
     - Returns: flex interface
    */
    @discardableResult
    public func style(_ style: DrStyle) -> DrFlex {
        if let host = self.view {
            host.dr_style = style
            if let border = style.border{
                borderWidth(border.width)
            }
            layoutFinished({ $0?.dr_buildStyle() }, forKey: "_dr_flex_style")
        }else{
            preconditionFailure("Trying to modify deallocated host view")
        }
        return self
    }
    
    /**
     Set the rounded corners of the view.
    
     - Parameter topLeft: topLeftRadius
     - Parameter topRight: topRightRadius
     - Parameter bottomLeft: bottomLeftRadius
     - Parameter bottomRight: bottomRightRadius
     - Returns: flex interface
    */
    @discardableResult
    public func cornerRadius(topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat) -> DrFlex {
        if let host = self.view {
            var style = host.dr_style
            if style == nil {
                style = DrStyle()
            }
            style?.round = DrRoundStyle(topLeft: topLeft,
                                        topRight: topRight,
                                        bottomLeft: bottomLeft,
                                        bottomRight: bottomRight)
            host.dr_style = style
            layoutFinished({ $0?.dr_buildStyle() }, forKey: "_dr_flex_style")
        }else{
            preconditionFailure("Trying to modify deallocated host view")
        }
        return self
    }
    
    /**
     Set the rounded corners of the view.
    
     - Parameter radius: cornerRadius
     - Returns: flex interface
    */
    @discardableResult
    public func cornerRadius(radius: CGFloat) -> DrFlex {
        if let host = self.view {
            var style = host.dr_style
            if style == nil {
                style = DrStyle()
            }
            style?.round = DrRoundStyle(radius: radius)
            host.dr_style = style
            layoutFinished({ $0?.dr_buildStyle() }, forKey: "_dr_flex_style")
        }else {
            preconditionFailure("Trying to modify deallocated host view")
        }
        return self
    }
    
    /**
     Set the border of the view.
    
     - Parameter width: Width of border
     - Parameter color: Color of border
     - Returns: flex interface
    */
    @discardableResult
    public func border(width: CGFloat, color: UIColor) -> DrFlex {
        if let host = self.view {
            var style = host.dr_style
            if style == nil {
                style = DrStyle()
            }
            borderWidth(width)
            style?.border = DrBorderStyle(width: width, color: color)
            host.dr_style = style
            layoutFinished({ $0?.dr_buildStyle() }, forKey: "_dr_flex_style")
        }else{
            preconditionFailure("Trying to modify deallocated host view")
        }
        return self
    }
    
    /**
     Set the shadow of the view.
    
     - Parameter offset: 阴影的偏移量
     - Parameter blurRadius: 阴影的模糊半径
     - Parameter spreadRadius: 阴影的扩展半径
     - Parameter color: 阴影颜色
     - Parameter opacity: 阴影的透明度[0, 1]
     - Returns: flex interface
    */
    @discardableResult
    public func shadow(offset: CGSize, blurRadius: CGFloat, spreadRadius: CGFloat? = nil, color: UIColor, opacity: CGFloat = 1) -> DrFlex {
        if let host = self.view {
            var style = host.dr_style
            if style == nil {
                style = DrStyle()
            }
            style?.shadow = DrShadowStyle(offset: offset,
                                          blurRadius: blurRadius,
                                          spreadRadius: spreadRadius,
                                          color: color,
                                          opacity: opacity)
            host.dr_style = style
            layoutFinished({ $0?.dr_buildStyle() }, forKey: "_dr_flex_style")
        }else {
            preconditionFailure("Trying to modify deallocated host view")
        }
        return self
    }
    
    /**
     Set the gradient background for the view.
    
     - Parameter offset: 阴影的偏移量
     - Parameter blurRadius: 阴影的模糊半径
     - Parameter spreadRadius: 阴影的扩展半径
     - Parameter color: 阴影颜色
     - Parameter opacity: 阴影的透明度[0, 1]
     - Returns: flex interface
    */
    @discardableResult
    public func gradient(style gradientStyle: DrGradientStyle) -> DrFlex {
        if let host = self.view {
            var style = host.dr_style
            if style == nil {
                style = DrStyle()
            }
            style?.gradient = gradientStyle
            host.dr_style = style
            layoutFinished({ $0?.dr_buildStyle() }, forKey: "_dr_flex_style")
        }else {
            preconditionFailure("Trying to modify deallocated host view")
        }
        return self
    }
    
    
    // MARK: - Display
    
    /**
     Set the view display or not
     */
    @discardableResult
    public func display(_ value: Display) -> DrFlex {
        yoga.display = value.yogaValue
        view?.isHidden = value == .none
        return self
    }
    
    /**
     Set the view display or not
     */
    @discardableResult
    public func display(_ value: Bool = true) -> DrFlex {
        yoga.display = value ? .flex : .none
        view?.isHidden = !value
        return self
    }
    
    /**
     Set the view hidden or display
     */
    public var isHidden: Bool {
        set {
            yoga.display = newValue ? .none : .flex
            view?.isHidden = newValue
        }
        get {
            yoga.display == .none
        }
    }
    
    
    // MARK: - ENUMS
    
    /**
     */
    public enum Direction {
        /// Default value. The flexible items are displayed vertically, as a column.
        case column
        /// Same as column, but in reverse order
        case columnReverse
        /// The flexible items are displayed horizontally, as a row.
        case row
        /// Same as row, but in reverse order
        case rowReverse
    }

    /**
     */
    public enum JustifyContent {
        /// Default value. Items are positioned at the beginning of the container.
        case start
        /// Items are positioned at the center of the container
        case center
        /// Items are positioned at the end of the container
        case end
        /// Items are positioned with space between the lines
        case spaceBetween
        /// Items are positioned with space before, between, and after the lines
        case spaceAround
        /// Items are positioned with space distributed evenly, items have equal space around them.
        case spaceEvenly
    }

    /**
     */
    public enum AlignContent {
        /// Default value. Lines stretch to take up the remaining space
        case stretch
        /// Lines are packed toward the start of the flex container
        case start
        /// Lines are packed toward the center of the flex container
        case center
        /// Lines are packed toward the end of the flex container
        case end
        /// Lines are evenly distributed in the flex container
        case spaceBetween
        /// Lines are evenly distributed in the flex container, with half-size spaces on either end    Play it »
        case spaceAround
    }

    /**
     */
    public enum AlignItems {
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
    }

    /**
     */
    public enum AlignSelf {
        /// Default. The element inherits its parent container's align-items property, or "stretch" if it has no parent container
        case auto
        /// The element is positioned to fit the container
        case stretch
        /// The element is positioned at the beginning of the container
        case start
        /// The element is positioned at the center of the container
        case center
        /// The element is positioned at the end of the container
        case end
        /// The element is positioned at the baseline of the container
        case baseline
    }

    /**
     */
    public enum Wrap {
        /// Default value. Specifies that the flexible items will not wrap
        case noWrap
        /// Specifies that the flexible items will wrap if necessary
        case wrap
        /// Specifies that the flexible items will wrap, if necessary, in reverse order
        case wrapReverse
    }

    /**
     */
    public enum Position {
        /// Default value.
        case relative
        /// Positioned absolutely in regards to its container. The item is positionned using properties top, bottom, left, right, start, end.
        case absolute
    }

    /**
     */
    public enum LayoutDirection {
        /// Default value.
        case inherit
        /// Left to right layout direction
        case ltr
        /// Right to right layout direction
        case rtl
        //case auto       // Detected automatically
    }

    /**
     Defines how the `layout(mode:)` method layout its flex items.
     */
    public enum LayoutMode {
        /// This is the default mode when no parameter is specified. Children are layouted **inside** the container's size (width and height).
        case fitContainer
        /// In this mode, children are layouted **using only the container's width**. The container's height will be adjusted to fit the flexbox's children
        case adjustHeight
        /// In this mode, children are layouted **using only the container's height**. The container's width will be adjusted to fit the flexbox's children
        case adjustWidth
    }

    /**
     */
    public enum Display {
        /// Default value
        case flex
        /// With this value, the item will be hidden and not be calculated
        case none
    }
    
}
