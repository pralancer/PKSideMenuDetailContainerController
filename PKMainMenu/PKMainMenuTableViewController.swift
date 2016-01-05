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


let PKMainMenuTableViewDidSelectNotification = "PKMainMenuTableViewDidSelectNotification"

/** This is a protocol that objects can conform to provide a view for a menu item if any of the menu item is set to a View type
 The @see PKMainMenuTableViewController has a menuViewProvider delegate that conforms to this protocol. Apps should set
 the menuViewProvider property of the PKMainMenuTableViewController and then implement the viewForMenuItem method to 
 return a view for the specified menu item. Apps can use the identifier property of the item to determine which view to return
 if there are multiple menu items that are of View types
*/
protocol PKMainMenuTableViewDelegate : class
{
    /** Return the view to be used as a menu item. The view's height should be properly set because it is used as the height
     * of the table cell in the table 
    */
    func viewForMenuItem(item:PKMainMenuItem) -> UIView?
    
    /** Delegate callback when a menu item is selected. The selected menu item model is passed to the delegate function */
    func didSelectMenuItem(item:PKMainMenuItem)
}

/**

* This is a table view controller that can be used to display a menu that you find in many apps on the left hand side.
* Its driven by models defined in PKMainMenuModel that contains the menu properties and menu items defined by the
* PKMainMenuItem objects.

* The model is created from a plist. Default implementation looks for a MainMenu.plist file if present and uses that to create the model
* You can also set the model explicity from a different file by creating an instance of the PKMainMenuModel using the path
* and setting it to this table view controller

*/
class PKMainMenuTableViewController: UITableViewController {
    
    private static let kImageMenuItemTag = 1000 //tag of the image view used to set the table cell background
    private static let kMainMenuItemCellID = "MenuCell" //identifier to be set in the storyboard or xib for the table view cell
    weak var menuViewProvider:PKMainMenuTableViewDelegate!
    
    /**
    * Points to the model object for the menu
    */
    var menuModel = PKMainMenuModel() //the main menu model
    
    /**
    * Contains the last selected item in the menu
    */
    var selectedItem:PKMainMenuItem? = nil //last selected menu item
    
    //MARK: Overrides 
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tableView.registerClass(PKMenuTableViewCell.self, forCellReuseIdentifier: PKMainMenuTableViewController.kMainMenuItemCellID)
        self.setTableViewSettings()
    }

    //Set the table view UI attributes from the menu model such as background color and image
    func setTableViewSettings()
    {
        self.tableView.backgroundColor = menuModel.backgroundColor
        self.tableView.backgroundView = UIImageView(image: menuModel.backgroundImage)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1 //currently supporting only one section menu
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return menuModel.menuItems.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(PKMainMenuTableViewController.kMainMenuItemCellID, forIndexPath: indexPath) as! PKMenuTableViewCell
        let item = menuModel.menuItems[indexPath.row]
        // Configure the cell...
        cell.configure(item, menuViewProvider: self.menuViewProvider)
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        selectedItem = menuModel.menuItems[indexPath.row]
        NSNotificationCenter.defaultCenter().postNotificationName(PKMainMenuTableViewDidSelectNotification, object: self)
        if menuViewProvider != nil {
            menuViewProvider.didSelectMenuItem(selectedItem!)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        let item = menuModel.menuItems[indexPath.row]
        
        if item.type == PKMainMenuItem.ItemType.View {
            return item.view?.bounds.height ?? super.tableView(tableView, heightForRowAtIndexPath:indexPath)
        }
        
        //if we have the rowHeight in the model then use it
        if let rowHeight = item.rowHeight
        {
            return rowHeight
        }

        return super.tableView(tableView, heightForRowAtIndexPath:indexPath)
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let item = menuModel.menuItems[indexPath.row]
        return item.selectable
    }
}

/*
Menu item cell class.
*/
class PKMenuTableViewCell : UITableViewCell
{
    //Configure's a table view cell based on a model given to the cell
    func configure(item:PKMainMenuItem, menuViewProvider:PKMainMenuTableViewDelegate?)
    {
        //remove any views added to the contentView of the cell since reusing does not remove the content view when scrolling fast
        let _ = self.contentView.subviews.map {$0.removeFromSuperview()}
        
        self.textLabel?.text = item.title //set the title irrespective of the type
        self.textLabel?.textColor = item.textColor
        self.textLabel?.font = item.font

        self.imageView?.image = nil
        if item.type == PKMainMenuItem.ItemType.Text
        {
            self.imageView?.image = item.image
        }
        else if item.type == PKMainMenuItem.ItemType.Image
        {
            let imageView = UIImageView(frame: self.bounds)
            imageView.image = item.image
            imageView.tag = PKMainMenuTableViewController.kImageMenuItemTag
            imageView.frame.size.height = item.rowHeight
            self.contentView.addSubview(imageView)
        }
        else if item.type == PKMainMenuItem.ItemType.View
        {
            if menuViewProvider != nil
            {
                if let menuView = menuViewProvider?.viewForMenuItem(item)
                {
                    menuView.frame.origin = CGPointZero
                    menuView.frame.size = self.contentView.bounds.size
                    self.contentView.addSubview(menuView)
                    item.view = menuView
                }
            }
        }

        //set the backgroundColor if available
        if item.backgroundColor != nil
        {
            self.backgroundColor = item.backgroundColor
        }
        else //otherwise make it no color. Have to set it to avoid reused cells traits being left over because of cell reuse
        {
            self.backgroundColor = UIColor.clearColor()
        }
        
        //if selectedColor is set then create a view and set that color as the background.
        if item.selectedColor != nil
        {
            self.selectedBackgroundView = UIView(frame: self.bounds)
            self.selectedBackgroundView?.backgroundColor = item.selectedColor
        }
        else //otherwise remove it
        {
            self.selectedBackgroundView = nil
        }
    }
}
