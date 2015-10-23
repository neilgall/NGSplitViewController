//
//  NGSplitViewController.swift
//  NGSplitViewController
//
//  Created by Neil Gall on 23/10/2015.
//  Copyright © 2015 Neil Gall. All rights reserved.
//

import UIKit

@objc public protocol NGSplitViewControllerDelegate {
    optional func splitViewController(splitViewController: NGSplitViewController, willHideMasterViewController viewController: UIViewController)
    optional func splitViewController(splitViewController: NGSplitViewController, willShowMasterViewController viewController: UIViewController)
    optional func splitViewController(splitViewController: NGSplitViewController, willHideDetailViewController viewController: UIViewController)
    optional func splitViewController(splitViewController: NGSplitViewController, willShowDetailViewController viewController: UIViewController)
}

public class NGSplitViewController: UIViewController {

    public var animateOverlayDuration: NSTimeInterval = 0.3
    
    public var delegate: NGSplitViewControllerDelegate?

    public var masterViewController: UIViewController? {
        willSet {
            removeChild(masterViewController)
        }
        didSet {
            addChild(masterViewController, withFrame: containerFrames.master)
        }
    }
    
    public var detailViewController: UIViewController? {
        willSet {
            removeChild(detailViewController)
        }
        didSet {
            addChild(detailViewController, withFrame: containerFrames.detail)
        }
    }
    
    public var splitRatio: CGFloat = 0.333 {
        didSet {
            view.setNeedsLayout()
        }
    }
    
    private var overlayHideButton: UIButton? {
        willSet(newValue) {
            if newValue == nil {
                overlayHideButton?.removeFromSuperview()
            }
        }
    }
    
    private enum MasterPresentationStyle {
        case Hidden
        case Showing
        case Overlay
    }
    
    private enum DetailPresentationStyle {
        case Hidden
        case Showing
    }
    
    private var masterPresentationStyle: MasterPresentationStyle = .Hidden {
        didSet {
            guard let master = masterViewController else {
                return
            }
            switch masterPresentationStyle {
            
            case .Hidden:
                delegate?.splitViewController?(self, willHideMasterViewController: master)
                if overlayHideButton == nil {
                    master.view.removeFromSuperview()
                } else {
                    animateOutMasterViewControllerOverlay()
                    overlayHideButton = nil
                }

            case .Showing:
                delegate?.splitViewController?(self, willShowMasterViewController: master)
                if master.view.superview !== view {
                    view.addSubview(master.view)
                }
                overlayHideButton = nil

            case .Overlay:
                if master.view.superview !== view {
                    view.addSubview(master.view)
                    animateInMasterViewControllerOverlay()
                }
            }
            
            view.setNeedsLayout()
        }
    }
    
    private var detailPresentationStyle: DetailPresentationStyle = .Hidden {
        didSet {
            guard let detail = detailViewController else {
                return
            }
            switch detailPresentationStyle {
                
            case .Hidden:
                delegate?.splitViewController?(self, willHideDetailViewController: detail)
                detail.view.removeFromSuperview()

            case .Showing:
                delegate?.splitViewController?(self, willShowDetailViewController: detail)
                if detail.view.superview !== view {
                    view.addSubview(detail.view)
                }
            }
            
            view.setNeedsLayout()
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        let frames = containerFrames
        addChild(masterViewController, withFrame: frames.master)
        addChild(detailViewController, withFrame: frames.detail)
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updatePresentationStyle()
        updateFrames()
        updateChildTraitCollections()
    }
    
    public override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        updatePresentationStyle()
        updateChildTraitCollections()
        view.setNeedsLayout()
    }
    
    public override func viewWillLayoutSubviews() {
        updateFrames()
    }
    
    private var containerFrames: (master: CGRect, detail: CGRect) {
        var masterFrame: CGRect = CGRectZero
        var detailFrame: CGRect = CGRectZero

        if masterPresentationStyle == .Showing && detailPresentationStyle == .Showing {
            let frames = view.bounds.divide(splitRatio)
            masterFrame = frames.left
            detailFrame = frames.right
        } else {
            switch masterPresentationStyle {
            case .Hidden:
                break
            case .Showing:
                masterFrame = view.bounds
            case .Overlay:
                masterFrame = CGRectMake(0, 0, 320, view.bounds.size.height)
            }
            
            switch detailPresentationStyle {
            case .Hidden:
                break
            case .Showing:
                detailFrame = view.bounds
            }
        }
        
        return (master: masterFrame.integral, detail: detailFrame.integral)
    }

    private func addChild(childViewController: UIViewController?, withFrame frame: CGRect) {
        guard let child = childViewController else {
            return
        }
        
        addChildViewController(child)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        child.view.frame = frame
        view.addSubview(child.view)
        child.didMoveToParentViewController(self)
        view.setNeedsLayout()
    }

    private func removeChild(childViewController: UIViewController?) {
        guard let child = childViewController else {
            return
        }
        
        child.view.removeFromSuperview()
        child.removeFromParentViewController()
    }
    
    private func updatePresentationStyle() {
        if traitCollection.horizontalSizeClass == .Regular {
            masterPresentationStyle = .Showing
            detailPresentationStyle = .Showing
        } else {
            masterPresentationStyle = .Hidden
            detailPresentationStyle = .Showing
        }
    }
   
    private func updateFrames() {
        let frames = containerFrames
        if masterPresentationStyle != .Hidden {
            masterViewController?.view.frame = frames.master
        }
        if detailPresentationStyle != .Hidden {
            detailViewController?.view.frame = frames.detail
        }
    }
    
    private func updateChildTraitCollections() {
        let compact = UITraitCollection(horizontalSizeClass: .Compact)
        
        if let master = masterViewController {
            let masterTraitCollection = UITraitCollection(traitsFromCollections: [traitCollection, compact])
            setOverrideTraitCollection(masterTraitCollection, forChildViewController: master)
        }
        
        if let detail = detailViewController {
            let detailTraitCollection = UITraitCollection(traitsFromCollections: [traitCollection, compact])
            setOverrideTraitCollection(detailTraitCollection, forChildViewController: detail)
        }
    }
    
    public func overlayMasterViewController() {
        guard masterPresentationStyle == .Hidden else {
            return
        }
        
        let button = UIButton(type: .Custom)
        button.translatesAutoresizingMaskIntoConstraints = true
        button.frame = detailViewController?.view.frame ?? CGRectZero
        button.addTarget(self, action: Selector("overlayHideButtonTapped"), forControlEvents: .TouchUpInside)
        view.addSubview(button)

        overlayHideButton = button
        masterPresentationStyle = .Overlay
        
        if traitCollection.horizontalSizeClass == .Compact && view.bounds.size.width <= 320 {
            detailPresentationStyle = .Hidden
        }
    }
    
    private func animateInMasterViewControllerOverlay() {
        guard let master = masterViewController else {
            return
        }
        master.view.transform = CGAffineTransformMakeTranslation(-containerFrames.master.size.width, 0)
        UIView.animateWithDuration(animateOverlayDuration,
            delay: 0,
            options: .CurveEaseOut,
            animations: { master.view.transform = CGAffineTransformIdentity },
            completion: nil)
    }
    
    private func animateOutMasterViewControllerOverlay() {
        guard let master = masterViewController else {
            return
        }
        UIView.animateWithDuration(animateOverlayDuration,
            delay: 0,
            options: .CurveEaseIn,
            animations: { master.view.transform = CGAffineTransformMakeTranslation(-master.view.bounds.size.width, 0) },
            completion: { _ in master.view.removeFromSuperview() })
    }
    
    func overlayHideButtonTapped() {
        guard masterPresentationStyle == .Overlay else {
            return
        }
        masterPresentationStyle = .Hidden
    }
    
    public func dismissOverlaidMasterViewController() {
        guard masterPresentationStyle == .Overlay else {
            return
        }
        masterPresentationStyle = .Hidden
    }
}

extension CGRect {
    func divide(split: CGFloat) -> (left: CGRect, right: CGRect) {
        var left: CGRect = CGRectZero
        var right: CGRect = CGRectZero
        CGRectDivide(self, &left, &right, size.width*split, .MinXEdge)
        return (left: left, right: right)
    }
    
    var integral: CGRect {
        return CGRectMake(round(origin.x), round(origin.y), round(size.width), round(size.height))
    }
}

