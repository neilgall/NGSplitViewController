//
//  NGSplitViewControllerUITests.swift
//  NGSplitViewControllerUITests
//
//  Created by Neil Gall on 25/10/2015.
//  Copyright © 2015 Neil Gall. All rights reserved.
//

import XCTest

class NGSplitViewControllerUITests: XCTestCase {
    
    private var window: UIWindow!
    private var wrapper: WrapperViewController!
    private var master: TestViewController!
    private var detail: TestViewController!
    private var split: NGSplitViewController!
    private let delegate = TestDelegate()
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false

        split = NGSplitViewController(nibName: nil, bundle: nil)
        split.delegate = delegate
        split.view.backgroundColor = UIColor.redColor()
        
        master = TestViewController(name: "master", color: UIColor.blueColor())
        detail = TestViewController(name: "detail", color: UIColor.greenColor())
        split.masterViewController = master
        split.detailViewController = detail

        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        wrapper = WrapperViewController(nibName: nil, bundle: nil)
        wrapper.view.frame = window.bounds
        wrapper.view.backgroundColor = UIColor.yellowColor()
        wrapper.containedViewController = split
        window.rootViewController = wrapper
        window.makeKeyAndVisible()
    }
    
    override func tearDown() {
        window = nil
        split = nil
        super.tearDown()
    }
    
    private func waitFor(predicate: Void->Bool) {
        expectationForPredicate(NSPredicate(block: { _, _ in predicate() }), evaluatedWithObject: self, handler: nil)
        waitForExpectationsWithTimeout(2.0, handler: nil)
    }
    
    func testSideBySideLayoutWithRegularHorizontalSizeClass() {
        wrapper.wrappedTraitCollections = [
            UITraitCollection(horizontalSizeClass: .Regular),
            UITraitCollection(verticalSizeClass: .Regular)
        ]
        
        waitFor {
            self.master.appearanceState == .Appeared && self.detail.appearanceState == .Appeared
        }
        
        XCTAssertEqual(delegate.masterViewControllersShown, Set(arrayLiteral: master))
        XCTAssertEqual(delegate.detailViewControllersShown, Set(arrayLiteral: detail))
        XCTAssertTrue(delegate.masterViewControllersHidden.isEmpty)
        XCTAssertTrue(delegate.detailViewControllersHidden.isEmpty)
    }

    func testDetailOnlyLayoutWithCompactHorizontalSizeClass() {
        wrapper.wrappedTraitCollections = [
            UITraitCollection(horizontalSizeClass: .Compact),
            UITraitCollection(verticalSizeClass: .Regular)
        ]
        
        waitFor {
            self.master.appearanceState == .Disappeared && self.detail.appearanceState == .Appeared
        }
        
        XCTAssertEqual(delegate.masterViewControllersHidden, Set(arrayLiteral: master))
        XCTAssertEqual(delegate.detailViewControllersShown, Set(arrayLiteral: detail))
        XCTAssertTrue(delegate.detailViewControllersHidden.isEmpty)
    }
    
}

class WrapperViewController: UIViewController {
    var containedViewController: UIViewController? {
        didSet {
            if let contained = containedViewController {
                contained.willMoveToParentViewController(self)
                contained.view.translatesAutoresizingMaskIntoConstraints = false
                contained.view.frame = self.view.bounds
                view.addSubview(contained.view)
                addChildViewController(contained)
                contained.didMoveToParentViewController(self)
            }
        }
    }
    
    var wrappedTraitCollections: [UITraitCollection] = [] {
        didSet {
            if let contained = containedViewController {
                setOverrideTraitCollection(UITraitCollection(traitsFromCollections: wrappedTraitCollections), forChildViewController: contained)
            }
        }
    }
}

class TestViewController: UIViewController {
    enum AppearanceState {
        case Appearing
        case Appeared
        case Disappearing
        case Disappeared
    }
    
    let name: String
    var appearanceState: AppearanceState = .Disappeared
    
    init(name: String, color: UIColor) {
        self.name = name
        super.init(nibName:nil, bundle: nil)
        self.view.backgroundColor = color
    }
    
    override var description: String {
        return "\(super.description):\(name)"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        appearanceState = .Appearing
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        appearanceState = .Appeared
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        appearanceState = .Disappearing
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        appearanceState = .Disappeared
    }
}

class TestDelegate: NSObject, NGSplitViewControllerDelegate {
    var traitCollections = [UITraitCollection]()
    var detailViewControllersHidden = Set<UIViewController>()
    var detailViewControllersShown = Set<UIViewController>()
    var masterViewControllersHidden = Set<UIViewController>()
    var masterViewControllersShown = Set<UIViewController>()
    
    func splitViewControllerTraitCollectionChanged(splitViewController: NGSplitViewController) {
        traitCollections.append(splitViewController.traitCollection)
    }
    
    func splitViewController(splitViewController: NGSplitViewController, didHideDetailViewController viewController: UIViewController) {
        detailViewControllersHidden.insert(viewController)
    }
    
    func splitViewController(splitViewController: NGSplitViewController, didHideMasterViewController viewController: UIViewController) {
        masterViewControllersHidden.insert(viewController)
    }
    
    func splitViewController(splitViewController: NGSplitViewController, didShowDetailViewController viewController: UIViewController) {
        detailViewControllersShown.insert(viewController)
    }
    
    func splitViewController(splitViewController: NGSplitViewController, didShowMasterViewController viewController: UIViewController) {
        masterViewControllersShown.insert(viewController)
    }
}
