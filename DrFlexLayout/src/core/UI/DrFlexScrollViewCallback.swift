//
//  DrFlexScrollViewCallback.swift
//  DrFlexLayout
//
//  Created by DHY on 2021/11/19.
//

import Foundation

public class DrFlexScrollViewCallback {
    
    private(set) var didScroll: ((UIScrollView)->Void)?
    /// 列表滚动回调
    public func didScroll<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ scrollView: UIScrollView)->Void) {
        weak var weakTarget = target
        self.didScroll = { (scrollView) in
            if let target = weakTarget{
                binding(target, scrollView)
            }
        }
    }
    
    private(set) var scrollViewDidZoom: ((UIScrollView)->Void)?
    public func scrollViewDidZoom<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ scrollView: UIScrollView)->Void) {
        weak var weakTarget = target
        self.scrollViewDidZoom = { (scrollView) in
            if let target = weakTarget {
                binding(target, scrollView)
            }
        }
    }
    
    private(set) var scrollViewWillBeginDragging: ((UIScrollView)->Void)?
    public func scrollViewWillBeginDragging<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ scrollView: UIScrollView)->Void) {
        weak var weakTarget = target
        self.scrollViewWillBeginDragging = { (scrollView) in
            if let target = weakTarget {
                binding(target, scrollView)
            }
        }
    }
    
    private(set) var scrollViewWillEndDragging: ((UIScrollView, CGPoint, UnsafeMutablePointer<CGPoint>)->Void)?
    public func scrollViewWillEndDragging<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ scrollView: UIScrollView, _ velocity: CGPoint, _ targetContentOffset: UnsafeMutablePointer<CGPoint>)->Void) {
        weak var weakTarget = target
        self.scrollViewWillEndDragging = { (scrollView, velocity, targetContentOffset) in
            if let target = weakTarget {
                binding(target, scrollView, velocity, targetContentOffset)
            }
        }
    }
    
    private(set) var scrollViewDidEndDragging: ((UIScrollView, Bool)->Void)?
    public func scrollViewDidEndDragging<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ scrollView: UIScrollView, _ decelerate: Bool)->Void) {
        weak var weakTarget = target
        self.scrollViewDidEndDragging = { (scrollView, decelerate) in
            if let target = weakTarget {
                binding(target, scrollView, decelerate)
            }
        }
    }
    
    private(set) var scrollViewWillBeginDecelerating: ((UIScrollView)->Void)?
    public func scrollViewWillBeginDecelerating<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ scrollView: UIScrollView)->Void) {
        weak var weakTarget = target
        self.scrollViewWillBeginDecelerating = { (scrollView) in
            if let target = weakTarget {
                binding(target, scrollView)
            }
        }
    }
    
    private(set) var scrollViewDidEndDecelerating: ((UIScrollView)->Void)?
    public func scrollViewDidEndDecelerating<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ scrollView: UIScrollView)->Void) {
        weak var weakTarget = target
        self.scrollViewDidEndDecelerating = { (scrollView) in
            if let target = weakTarget {
                binding(target, scrollView)
            }
        }
    }
    
    private(set) var scrollViewDidEndScrollingAnimation: ((UIScrollView)->Void)?
    public func scrollViewDidEndScrollingAnimation<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ scrollView: UIScrollView)->Void) {
        weak var weakTarget = target
        self.scrollViewDidEndScrollingAnimation = { (scrollView) in
            if let target = weakTarget {
                binding(target, scrollView)
            }
        }
    }
    
    private(set) var viewForZooming: ((UIScrollView)->UIView?)?
    public func viewForZooming<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ scrollView: UIScrollView)->UIView?) {
        weak var weakTarget = target
        self.viewForZooming = { (scrollView) in
            if let target = weakTarget {
                return binding(target, scrollView)
            }
            return nil
        }
    }
    
    private(set) var scrollViewWillBeginZooming: ((UIScrollView, UIView?)->Void)?
    public func scrollViewWillBeginZooming<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ scrollView: UIScrollView, _ view: UIView?)->Void) {
        weak var weakTarget = target
        self.scrollViewWillBeginZooming = { (scrollView, view) in
            if let target = weakTarget {
                binding(target, scrollView, view)
            }
        }
    }
    
    private(set) var scrollViewDidEndZooming: ((UIScrollView, UIView?, CGFloat)->Void)?
    public func scrollViewDidEndZooming<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ scrollView: UIScrollView, _ view: UIView?, _ scale: CGFloat)->Void) {
        weak var weakTarget = target
        self.scrollViewDidEndZooming = { (scrollView, view, scale) in
            if let target = weakTarget {
                binding(target, scrollView, view, scale)
            }
        }
    }
    
    private(set) var scrollViewShouldScrollToTop: ((UIScrollView)->Bool)?
    public func scrollViewShouldScrollToTop<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ scrollView: UIScrollView)->Bool) {
        weak var weakTarget = target
        self.scrollViewShouldScrollToTop = { (scrollView) in
            if let target = weakTarget {
                return binding(target, scrollView)
            }
            return true
        }
    }
    
    private(set) var scrollViewDidScrollToTop: ((UIScrollView)->Void)?
    public func scrollViewDidScrollToTop<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ scrollView: UIScrollView)->Void) {
        weak var weakTarget = target
        self.scrollViewDidScrollToTop = { (scrollView) in
            if let target = weakTarget {
                binding(target, scrollView)
            }
        }
    }
    
    private(set) var didChangeAdjustedContentInset: ((UIScrollView)->Void)?
    public func didChangeAdjustedContentInset<T: AnyObject>(_ target: T, binding: @escaping (_ target: T, _ scrollView: UIScrollView)->Void) {
        weak var weakTarget = target
        self.didChangeAdjustedContentInset = { (scrollView) in
            if let target = weakTarget {
                binding(target, scrollView)
            }
        }
    }
    
}
