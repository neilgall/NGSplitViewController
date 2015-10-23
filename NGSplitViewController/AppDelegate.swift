//
//  AppDelegate.swift
//  NGSplitViewController
//
//  Created by Neil Gall on 23/10/2015.
//  Copyright © 2015 Neil Gall. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, NGSplitViewControllerDelegate {

    var window: UIWindow?
    var splitViewController: NGSplitViewController?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let split = NGSplitViewController()
        split.delegate = self
        split.masterViewController = storyboard.instantiateViewControllerWithIdentifier("masterNavigationController")
        split.detailViewController = storyboard.instantiateViewControllerWithIdentifier("detailNavigationController")
        
        window = UIWindow(frame:UIScreen.mainScreen().bounds)
        window!.rootViewController = split
        window!.makeKeyAndVisible()
        
        splitViewController = split
        return true
    }

    func splitViewController(splitViewController: NGSplitViewController, willHideMasterViewController viewController: UIViewController) {
        guard let detail = (splitViewController.detailViewController as? UINavigationController)?.topViewController else {
            return
        }
        detail.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Show", style: .Plain, target: self, action: Selector("showMaster"))
    }
    
    func splitViewController(splitViewController: NGSplitViewController, willShowMasterViewController viewController: UIViewController) {
        guard let detail = (splitViewController.detailViewController as? UINavigationController)?.topViewController else {
            return
        }
        detail.navigationItem.leftBarButtonItem = nil
    }
    
    func showMaster() {
        splitViewController?.revealMasterViewController()
    }
    
}

