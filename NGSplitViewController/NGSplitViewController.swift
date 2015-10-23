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

    @IBOutlet public var masterViewController: UIViewController? {
        willSet {
            removeChild(masterViewController)
        }
        didSet {
            addChild(masterViewController, containerView: masterContainer)
        }
    }
    
    @IBOutlet public var detailViewController: UIViewController? {
        willSet {
            removeChild(detailViewController)
        }
        didSet {
            addChild(detailViewController, containerView: detailContainer)
        }
    }
    
    public var splitRatio: CGFloat = 0.333 {
        didSet {
            view.setNeedsLayout()
        }
    }
    
    public var delegate: NGSplitViewControllerDelegate?

    private var masterContainer: UIView?
    private var detailContainer: UIView?
    private var overlayHideButton: UIButton?
    
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
            guard let container = masterContainer, let master = masterViewController else {
                return
            }
            switch masterPresentationStyle {
            
            case .Hidden:
                delegate?.splitViewController?(self, willHideMasterViewController: master)
                masterContainer?.removeFromSuperview()
                overlayHideButton?.removeFromSuperview()

            case .Showing:
                delegate?.splitViewController?(self, willShowMasterViewController: master)
                if container.superview !== view {
                    view.addSubview(container)
                }
                overlayHideButton?.removeFromSuperview()

            case .Overlay:
                if container.superview !== view {
                    view.addSubview(container)
                }
            }
            
            view.setNeedsLayout()
        }
    }
    
    private var detailPresentationStyle: DetailPresentationStyle = .Hidden {
        didSet {
            guard let container = detailContainer, detail = detailViewController else {
                return
            }
            switch detailPresentationStyle {
                
            case .Hidden:
                delegate?.splitViewController?(self, willHideDetailViewController: detail)
                container.removeFromSuperview()

            case .Showing:
                delegate?.splitViewController?(self, willShowDetailViewController: detail)
                if container.superview !== view {
                    view.addSubview(container)
                }
            }
            
            view.setNeedsLayout()
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        masterContainer = UIView(frame: CGRectZero)
        detailContainer = UIView(frame: CGRectZero)
        masterContainer!.translatesAutoresizingMaskIntoConstraints = false
        detailContainer!.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(masterContainer!)
        view.addSubview(detailContainer!)
        updateFrames()
        
        addChild(masterViewController, containerView: masterContainer)
        addChild(detailViewController, containerView: detailContainer)
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

    private func addChild(childViewController: UIViewController?, containerView: UIView?) {
        guard let child = childViewController, let container = containerView else {
            return
        }
        
        addChildViewController(child)
        child.view.translatesAutoresizingMaskIntoConstraints = true
        child.view.frame = container.bounds
        container.addSubview(child.view)
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
            masterContainer?.frame = frames.master
        }
        if detailPresentationStyle != .Hidden {
            detailContainer?.frame = frames.detail
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
        guard masterPresentationStyle == .Hidden, let detailContainer = detailContainer else {
            return
        }
        
        let button = UIButton(type: .Custom)
        button.translatesAutoresizingMaskIntoConstraints = true
        button.frame = detailContainer.bounds
        button.addTarget(self, action: Selector("overlayHideButtonTapped"), forControlEvents: .TouchUpInside)
        detailContainer.addSubview(button)

        overlayHideButton = button
        masterPresentationStyle = .Overlay
        
        if traitCollection.horizontalSizeClass == .Compact && view.bounds.size.width <= 320 {
            detailPresentationStyle = .Hidden
        }
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

