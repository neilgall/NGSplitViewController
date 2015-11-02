//
//  AppDelegate.swift
//  NGSplitViewController
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 Neil Gall
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, NGSplitViewControllerDelegate {

    var window: UIWindow?
    var splitViewController: NGSplitViewController?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let split = storyboard.instantiateInitialViewController() as! NGSplitViewController
        split.delegate = self
        split.masterViewController = storyboard.instantiateViewControllerWithIdentifier("masterNavigationController")
        split.detailViewController = storyboard.instantiateViewControllerWithIdentifier("detailNavigationController")
        
        ((split.masterViewController as! UINavigationController).topViewController as! MasterViewController).ngSplitViewController = split
        
        window = UIWindow(frame:UIScreen.mainScreen().bounds)
        window!.rootViewController = split
        window!.makeKeyAndVisible()
        
        splitViewController = split
        return true
    }
    
    func splitViewController(splitViewController: NGSplitViewController, didChangeMasterViewControllerVisibility viewController: UIViewController) {
        guard let detail = (splitViewController.detailViewController as? UINavigationController)?.topViewController else {
            return
        }
        if splitViewController.masterViewControllerIsVisible {
            detail.navigationItem.leftBarButtonItem = nil
        } else {
            detail.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Show", style: .Plain, target: self, action: Selector("showMaster"))
        }
    }
    
    func showMaster() {
        splitViewController?.overlayMasterViewController()
    }
    
}

