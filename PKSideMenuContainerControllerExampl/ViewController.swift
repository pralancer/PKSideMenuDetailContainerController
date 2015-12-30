//
//  ViewController.swift
//  PKSideMenuContainerControllerExampl
//

//  Copyright © 2015 Pralancer. All rights reserved.
//

import UIKit

class ViewController: UIViewController, PKMainMenuTableViewDelegate {

    @IBOutlet weak var durationSlider:UISlider!
    
    override func viewDidLoad() {
        P(self.title)
        super.viewDidLoad()
        if let sideMenuVC = self.parentViewController?.parentViewController as? PKSideMenuContainerController
        {
            if let menuTableVC = sideMenuVC.menuViewController as? PKMainMenuTableViewController
            {
                menuTableVC.menuViewProvider = self
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        P(self.title)
        super.viewDidAppear(animated)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        P(self.title)
        super.viewWillAppear(animated)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        P(self.title)
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: User Actions
    
    @IBAction func setAnimationType(sender:AnyObject?)
    {
        if let sideMenuVC = self.parentViewController?.parentViewController as? PKSideMenuContainerController
        {
            switch sender?.tag
            {
            case let tag where tag == 1:
                sideMenuVC.animationType = .FoldInward
            case let tag where tag ==  2:
                sideMenuVC.animationType = .Push
            case let tag where tag ==  3:
                sideMenuVC.animationType = .Instant
            case let tag where tag ==  4:
                sideMenuVC.animationType = .Reveal
            case let tag where tag == 5:
                sideMenuVC.animationType = .FoldOutward
            case let tag where tag == 6:
                sideMenuVC.animationType = .Compress
            default:
                break
            }
        }
    }
    
    /** Hide or show the shadown on the menu */
    @IBAction func toggleShadow(sender:AnyObject?)
    {
        if let sideMenuVC = self.parentViewController?.parentViewController as? PKSideMenuContainerController
        {
            sideMenuVC.hasShadowOnMenu = !sideMenuVC.hasShadowOnMenu
        }
    }
    
    @IBAction func userTappedMenu(sender:AnyObject?)
    {
        if let sideMenuVC = self.parentViewController?.parentViewController as? PKSideMenuContainerController
        {
            sideMenuVC.animationDuration = Double(durationSlider.value)
            sideMenuVC.toggle(sender)
        }
    }

}
extension ViewController
{
    func viewForMenuItem(item:PKMainMenuItem) -> UIView?
    {
        let view = UIView()
        view.backgroundColor = UIColor.redColor()
        return view
    }

/** Delegate callback when a menu item is selected. The selected menu item model is passed to the delegate function */
    func didSelectMenuItem(item:PKMainMenuItem)
    {
        userTappedMenu(nil)
    }
}

