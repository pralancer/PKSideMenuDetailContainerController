/*

//  BackgroundAudioPlayer.h

Copyright 2015 Pralancer. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

*/

import UIKit

class PKSideMenuContainerController: UIViewController {
    
    /** This enum is used to set the animation type for the menu */
    enum PKSideMenuAnimationType
    {
        /**  No animation, instantly reveals or hides the side menu */
        case Instant
        /** Menu on the left pushes the detail to reveal itself */
        case Push
        /** Folds from the right edge of the menu towards the left side */
        case FoldInward
        /** Folds from the left edge of the menu towards the right side */
        case FoldOutward
        /** Reveals the menu underneath the detail view */
        case Reveal
        /** Compresses the menu along the X-axis which is equivalent to rotating the view along the Y-axis */
        case Compress
    }
    
    weak var menuViewController:UIViewController! //a view controller that will be displayed as a menu
    weak var detailViewController:UIViewController! //a detail view controller that will be displayed as detail
    
    //outlets for the menu and detail container views when created from storyboard
    @IBOutlet weak var detailContainer:UIView!
    @IBOutlet weak var menuContainer:UIView!
    
    //CONSTANTS
    private static let kAnimationDuration = 0.2 //default animation duration
    private static let kShadingViewAlpha:CGFloat = 0.6
    private var shadingView:UIView = UIView(frame:CGRectMake(0, 0, 0, 0)) //to create the shadow effect when folding
    private var menuHidden:Bool = true //internal variable used to track the status of the menu
    private static let kZOrderShift:CGFloat = -1.0/1000.0
    
    //PUBLIC variables
    var animationType:PKSideMenuAnimationType = .Reveal { //animation type.
        didSet {
            if animationType == .Reveal {
                self.view.sendSubviewToBack(self.menuContainer)
            }
        }
    }
    var animationDuration = kAnimationDuration //animation duration
    
    //SHADOW between the menu and the detail view controller
    /** Set the shadowRadius for the shadow between the menu and the detail view */
    var shadowRadius:CGFloat = 6.0 {
        didSet {
            self.detailContainer.layer.shadowRadius = shadowRadius
        }
    }
    /** Set the shadowOpacity for the shadow between the menu and the detail view */
    var shadowOpacity:Float = 0.8 {
        didSet {
            self.detailContainer.layer.shadowOpacity = shadowOpacity
        }
    }
    /** Set the shadowColor for the shadow between the menu and the detail view */
    var shadowColor = UIColor.blackColor() {
        didSet {
            self.detailContainer.layer.shadowColor = shadowColor.CGColor
        }
    }
    /** Set whether a shadown has to be shown between the menu and the detail view */
    var hasShadowOnMenu : Bool = true {
        didSet {
            if hasShadowOnMenu
            {
                self.detailContainer.layer.shadowPath = UIBezierPath(rect: CGRectMake(0, 0, 15, self.detailContainer.layer.bounds.size.height)).CGPath
                self.detailContainer.layer.shadowOffset = CGSizeMake(-5, shadowRadius)
                self.detailContainer.layer.shadowOpacity = shadowOpacity
                self.detailContainer.layer.shadowRadius = shadowRadius
                self.detailContainer.layer.shadowColor = shadowColor.CGColor
            }
            else
            {
                self.detailContainer.layer.shadowPath = nil
                self.detailContainer.layer.shadowOpacity = 0.0
            }
        }
    }
    
    //MARK: Private
    
    private func createShadingView()
    {
        shadingView.bounds = self.menuContainer.frame
        shadingView.frame = CGRectMake(0, 0, CGRectGetWidth(shadingView.bounds), CGRectGetHeight(shadingView.bounds))
        self.menuContainer.addSubview(shadingView)
        self.menuContainer.bringSubviewToFront(shadingView)
        shadingView.backgroundColor = UIColor.blackColor()
        shadingView.alpha = 0.0
    }
    
    //MARK: Overrides
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        createShadingView()
        
        //default state is menu is hidden. So set the container's dimension accordingly to cover the entire view
        self.detailContainer.frame.origin.x = 0.0
        self.detailContainer.frame.size.width = self.view.frame.size.width

        //enable shadows
        hasShadowOnMenu = true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        guard let segueID = segue.identifier else {
            return
        }
        if segueID == "menuVCSegue"
        {
            menuViewController = segue.destinationViewController
        }
        if segueID == "detailVCSegue"
        {
            detailViewController = segue.destinationViewController
        }
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        //whenever the orientation change the menu gets hidden because of the system's way of managing
        //the orientation. So I set the internal state to hidden so that the toggle works properly after the orientation is changed
        setInitialState()
        
        //Set the shading view that is used to darken the menu to the size of the container view that holds the menu view
        self.shadingView.frame.size = self.menuContainer.frame.size
    }
    
    //MARK: Animations

    /** This function is there just to support dyanmic transition where in the @see[animationType] is changed on the fly */
    func setInitialState()
    {
        if animationType == .Push || animationType == .Instant
        {
            self.menuContainer.layer.transform = self.transformForFraction(1.0)
            if menuHidden
            {
                self.menuContainer.frame.origin.x = -self.menuContainer.bounds.size.width
                self.detailContainer.frame.origin.x = 0.0
                self.shadingView.alpha = PKSideMenuContainerController.kShadingViewAlpha
           }
            else
            {
                self.menuContainer.frame.origin.x = 0.0
                self.detailContainer.frame.origin.x = self.menuContainer.bounds.size.width
                self.shadingView.alpha = 0.0
           }
        }
        if animationType == .Reveal
        {
            self.menuContainer.layer.transform = self.transformForFraction(1.0)
            if menuHidden
            {
                self.menuContainer.frame.origin.x = 0.0
                self.detailContainer.frame.origin.x = 0.0
                self.shadingView.alpha = PKSideMenuContainerController.kShadingViewAlpha
            }
            else
            {
                self.menuContainer.frame.origin.x = 0.0
                self.detailContainer.frame.origin.x = self.menuContainer.bounds.size.width
                self.shadingView.alpha = 0.0
            }
        }
        if animationType == .FoldInward || animationType == .FoldOutward || animationType == .Compress
        {
            self.menuContainer.layer.transform = CATransform3DIdentity
            self.menuContainer.frame.origin.x = 0
            if menuHidden
            {
                self.menuContainer.layer.transform = self.transformForFraction(0.0)
                self.shadingView.alpha = PKSideMenuContainerController.kShadingViewAlpha
            }
            else
            {
                self.menuContainer.layer.transform = CATransform3DIdentity //self.transformForFraction(1.0)
                self.shadingView.alpha = 0.0 //alpha is changed to create the darkening effect when folding in
            }
        }
    }
    
    //MARK: -

    func instantOrPushAnimation()
    {
        if self.menuHidden
        {
            self.menuContainer.frame.origin = CGPointMake(self.menuContainer.frame.origin.x+self.menuContainer.bounds.width, self.menuContainer.frame.origin.y)
            self.detailContainer.frame.origin = CGPointMake(self.detailContainer.frame.origin.x+self.menuContainer.bounds.width, self.detailContainer.frame.origin.y)
            self.shadingView.alpha = 0.0
        }
        else
        {
            self.menuContainer.frame.origin = CGPointMake(self.menuContainer.frame.origin.x-self.menuContainer.bounds.width, self.menuContainer.frame.origin.y)
            self.detailContainer.frame.origin = CGPointMake(self.detailContainer.frame.origin.x-self.menuContainer.bounds.width, self.detailContainer.frame.origin.y)
            self.shadingView.alpha = PKSideMenuContainerController.kShadingViewAlpha
        }
    }
    
    func foldAnimation()
    {
        if self.menuHidden
        {
            self.detailContainer.frame.origin = CGPointMake(self.detailContainer.frame.origin.x+self.menuContainer.bounds.width, self.detailContainer.frame.origin.y)
            self.menuContainer.layer.transform = self.transformForFraction(1.0)
            self.shadingView.alpha = 0.0 //alpha is changed to create the darkening effect when folding in
        }
        else
        {
            self.detailContainer.frame.origin = CGPointMake(self.detailContainer.frame.origin.x-self.menuContainer.bounds.width, self.detailContainer.frame.origin.y)
            self.menuContainer.layer.transform = self.transformForFraction(0.0)
            self.shadingView.alpha = PKSideMenuContainerController.kShadingViewAlpha
        }
    }
    
    func revealAnimation()
    {
        if self.menuHidden
        {
            self.detailContainer.frame.origin = CGPointMake(self.detailContainer.frame.origin.x+self.menuContainer.bounds.width, self.detailContainer.frame.origin.y)
            self.shadingView.alpha = 0.0 //alpha is changed to create the darkening effect when folding in
        }
        else
        {
            
            self.detailContainer.frame.origin = CGPointMake(self.detailContainer.frame.origin.x-self.menuContainer.bounds.width, self.detailContainer.frame.origin.y)
            self.shadingView.alpha = PKSideMenuContainerController.kShadingViewAlpha
        }
    }
    
    //MARK: Transforms
    func transformForFraction(fraction:CGFloat) -> CATransform3D {
        var identity = CATransform3DIdentity
        let angle = Double(1.0 - fraction) * -M_PI_2
        let xOffset = CGRectGetWidth(menuContainer.bounds) * 0.5
        let translateTransform = CATransform3DMakeTranslation(-xOffset*(1.0-fraction), 0.0 ,0.0)
        
        if animationType == .Compress
        {
            identity.m34 = 0.0
            let rotateTransform = CATransform3DRotate(identity, CGFloat(angle), 0.0, 1.0, 0.0)
            return CATransform3DConcat(rotateTransform, translateTransform)
        }
        else
        {
            identity.m34 = PKSideMenuContainerController.kZOrderShift;
            let rotateTransform = CATransform3DRotate(identity, CGFloat(angle), 0.0, animationType == .FoldInward ? -1.0 : 1.0, 0.0)
            return CATransform3DConcat(rotateTransform, translateTransform)
        }
    }
    
    //MARK: User actions
    @IBAction func toggle(sender:AnyObject? = nil)
    {
        setInitialState()
        self.view.userInteractionEnabled = false
        if animationType == .Instant {
            instantOrPushAnimation()
            self.menuHidden = !self.menuHidden
            shadingView.alpha = 0.0
            self.view.userInteractionEnabled = true
        }
        else {
            UIView.animateWithDuration(animationDuration, animations: {
                [unowned self] () -> Void in
                switch self.animationType {
                case .Push, .Instant:
                    self.instantOrPushAnimation()
                case .FoldInward, .FoldOutward, .Compress:
                    self.foldAnimation()
                case .Reveal:
                    self.revealAnimation()
                }
                self.menuHidden = !self.menuHidden
                }) {
                    //completion block
                    [unowned self] _ in
                    self.view.userInteractionEnabled = true
                    self.view.sendSubviewToBack(self.menuContainer)
                }
        }
    }
}
