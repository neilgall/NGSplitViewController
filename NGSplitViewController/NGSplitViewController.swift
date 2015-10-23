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

    public var masterViewController: UIViewController? {
        willSet {
            removeChild(masterViewController)
        }
        didSet {
            addChild(masterViewController, containerView: masterContainer)
        }
    }
    
    public var detailViewController: UIViewController? {
        willSet {
            removeChild(detailViewController)
        }
        didSet {
            addChild(detailViewController, containerView: detailContainer)
        }
    }
    
    public var splitRatio: CGFloat = 0.333 {
        didSet {
            view.layoutSubviews()
        }
    }
    
    public var delegate: NGSplitViewControllerDelegate?

    private var masterContainer: UIView?
    private var detailContainer: UIView?
    private var overlayHideButton: UIButton?
    
    private enum PresentationStyle {
        case Hidden
        case Showing
        case Overlay
    }
    
    private var masterPresentationStyle: PresentationStyle = .Hidden {
        didSet {
            guard let container = masterContainer, let master = masterViewController else {
                return
            }
            switch masterPresentationStyle {
            
            case .Hidden:
                masterContainer?.removeFromSuperview()
                delegate?.splitViewController?(self, willHideMasterViewController: master)

            case .Showing:
                if container.superview !== view {
                    view.addSubview(container)
                }
                delegate?.splitViewController?(self, willShowMasterViewController: master)

            case .Overlay:
                if container.superview !== view {
                    view.addSubview(container)
                }
            }
        }
    }
    
    private var detailPresentationStyle: PresentationStyle = .Hidden {
        didSet {
            guard let container = detailContainer, detail = detailViewController else {
                return
            }
            switch detailPresentationStyle {
                
            case .Hidden:
                container.removeFromSuperview()
                delegate?.splitViewController?(self, willHideDetailViewController: detail)

            case .Showing:
                if container.superview !== view {
                    view.addSubview(container)
                }
                delegate?.splitViewController?(self, willShowDetailViewController: detail)
            
            case .Overlay:
                abort()
            }
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
    }
    
    public override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        updatePresentationStyle()
        view.layoutSubviews()
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
                masterFrame = view.bounds.divide(splitRatio).left
            }
            
            switch detailPresentationStyle {
            case .Hidden:
                break
            case .Showing:
                detailFrame = view.bounds
            case .Overlay:
                abort()
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
        view.layoutSubviews()
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
    
    public func revealMasterViewController() {
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

        view.layoutSubviews()
    }
    
    func overlayHideButtonTapped() {
        guard masterPresentationStyle == .Overlay else {
            return
        }
        
        overlayHideButton?.removeFromSuperview()
        masterPresentationStyle = .Hidden

        view.layoutSubviews()
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

