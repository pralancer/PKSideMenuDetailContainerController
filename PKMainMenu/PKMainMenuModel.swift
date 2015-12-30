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

import Foundation
import UIKit

//Type aliases for easier usage in the code
typealias PKMainMenuItemsType = [String:AnyObject] //a dictionary of string keys and string values
typealias PKMainMenuItemsArr = [PKMainMenuItemsType] //an array of dictionaries

/*

This class is a model wrapper for the plist file that defines the menu attributes and items. It intialises the menu items
from the plist and is used by the table view controller to configure the table and display the menu items

*/
class PKMainMenuModel
{
    /** An array of menu item models */
    var menuItems:[PKMainMenuItem] = [PKMainMenuItem]()

    /** Default background color for the menu table */
    var backgroundColor:UIColor!
    /** Default background image for the menu table */
    var backgroundImage:UIImage!

    /** Designated initialiser using which you can create the menu model using a custom path */
    init(path:String?)
    {
        guard path != nil else { return }
        guard let itemsDict = NSDictionary(contentsOfFile: path!) else { return }
        guard let itemsArray = itemsDict["items"] as? PKMainMenuItemsArr else { return }
        
        //Read the table view background settings if provided
        if let value = itemsDict["backgroundColor"], colorStr = value as? String {
            backgroundColor = UIColor(string: colorStr)
        }
        if let value = itemsDict["backgroundImage"], imageStr = value as? String {
            backgroundImage = UIImage(named: imageStr)
        }
        
        let defaults:PKMainMenuItemsType? = itemsDict["defaults"] as? PKMainMenuItemsType
        addItemsFromArray(itemsArray, usingDefaults: defaults)
    }
    
    /** Convenience initialiser that uses MainMenu.plist file in the app bundle as the model for the menu */
    convenience init()
    {
        let defaultPath:String? = NSBundle.mainBundle().pathForResource("MainMenu", ofType: "plist")
        self.init(path:defaultPath)
    }
    
    /** Create the menu items from an array of dictionaries of type @see PKMainMenuItemsArr. THe usingDefaults is used
      * to specify another dictionary that contains the default values for some menu properties if they are not defined
      * in the menu item model
     */
    func addItemsFromArray(itemsArr:PKMainMenuItemsArr, usingDefaults:PKMainMenuItemsType?)
    {
        for item in itemsArr
        {
            let item = PKMainMenuItem(dictionary: item)
            if usingDefaults != nil {
                addEntriesFromDefaults(usingDefaults!, item: item)
            }
            menuItems.append(item)
        }
    }
    
    /** Add entries from the defaults dictionary */
    private func addEntriesFromDefaults(defaults:PKMainMenuItemsType, item:PKMainMenuItem)
    {
        if item.fontName == nil && defaults["fontName"] != nil {
            item.fontName = defaults["fontName"] as? String
        }
        if item.fontSize == 0 && defaults["fontSize"] != nil {
            item.fontSize = defaults["fontSize"] as! CGFloat
        }
        if item.rowHeight == nil && defaults["rowHeight"] != nil {
            item.rowHeight = defaults["rowHeight"] as! CGFloat
        }
        if let colorStr = defaults["backgroundColor"] as? String {
            if item.backgroundColor == nil {
                item.backgroundColor = UIColor(string: colorStr)
            }
        }
        if let colorStr = defaults["textColor"] as? String {
            if item.textColor == nil {
                item.textColor = UIColor(string: colorStr)
            }
        }
        if let colorStr = defaults["selectedColor"] as? String {
            if item.selectedColor == nil {
                item.selectedColor = UIColor(string: colorStr)
            }
        }
    }
}

/*

This class represents one menu item in the main menu table view controller. This encapsulates all the properties of the
table view cell. Using this you can configure each menu item separately or you could use defaults by not specifying those
properties

*/
class PKMainMenuItem
{
    /**
    * This enum is used to set the type of the menu item. If its Image then a background image view is created for the table view cell
     */
    enum ItemType:String {
        /** Image is used to set a image for a menu item cell. An image view is added to the content view */
        case Image = "image"
        
        /** Text is used to specify a menu item as a text */
        case Text = "text"
        
        /** View is used to set a custom view as a menu item. You specify this view via a PKMainMenuTableViewDelegate delegate 
         * set to the table view controller
        */
        case View = "view"
    }

    /** Menu item title */
    var title:String = ""
    
    /** Type of the menu item as specified by the @see ItemType enum. Default is Text */
    var type:ItemType = .Text
    
    /** Unique identifier that you have to set in order to determine which menu item was selected */
    var identifier:String = ""

    /** Specify the row height for this menu item. If the type is Image then this will hold the height of the image
     */
    var rowHeight:CGFloat!
    
    /** Background color for the menu item */
    var backgroundColor:UIColor! = nil //background color for the menu item
    
    /** Text color */
    var textColor:UIColor! = nil //text color for the menu item
    
    /** Selected color. If set then the selectedBackgroundView with the specified color as background is set on the cell */
    var selectedColor:UIColor! = nil //selected color for text
    
    /** Font name for the title */
    var fontName:String! = nil //font for the menu item title
    
    /** Font size */
    var fontSize:CGFloat = 0 //default to 0. Set in the main menu model if not available in the dict
    
    /** Font object calculated based on the fontName and fontSize */
    lazy var font:UIFont! = { //font object based on font name and size
        [unowned self] in
        return (self.fontName != nil ? UIFont(name: self.fontName!, size: self.fontSize) : nil)
        }()
    
    /** Image name for the table cell. It can either be used as a background image if the type is Image or as a cell image
     * if the type is Text 
    */
    var imageName:String? = nil //name of the image for text or image type
    /** Image object to be set. If the image properties are set then a image view is set as the background on the cell's content view */
    lazy var image: UIImage! = { //image object created after the imageName is set
        [unowned self] in
        let image:UIImage? = ((self.imageName != nil && !self.imageName!.isEmpty) ? UIImage(named: self.imageName!) : nil)
        if self.type == .Image && image != nil
        {
            //if an explicit row height is not specified then use the image's height
            if self.rowHeight == nil {
                self.rowHeight = image!.size.height * image!.scale
            }
        }
        return image
    }()
    
    /** View if the type is set to View */
    weak var view:UIView?
    
    var selectable:Bool = true
    
    /** Designated initialiser. You pass an item of @see PKMainMenuItemsType which is a dictionary of [String:String] that 
     * contains the various properties defining the menu item
    */
    init(dictionary:PKMainMenuItemsType)
    {
        title = dictionary["title"] as? String ?? ""
        identifier = dictionary["identifier"] as? String ?? ""
        imageName = dictionary["imageName"] as? String //could be nil or could have a name
        if let colorStr = dictionary["backgroundColor"] as? String {
            backgroundColor = UIColor(string: colorStr)
        }
        if let colorStr = dictionary["textColor"] as? String {
            textColor = UIColor(string: colorStr)
        }
        if let colorStr = dictionary["selectedColor"] as? String {
            selectedColor = UIColor(string: colorStr)
        }
        fontName = dictionary["fontName"] as? String
        fontSize = dictionary["fontSize"] as? CGFloat ?? 0
        rowHeight = dictionary["rowHeight"] as? CGFloat
        selectable = dictionary["selectable"] as? Bool ?? true
        
        if let type = dictionary["type"]
        {
            switch type.lowercaseString
            {
                case "image":
                    self.type = .Image
                case "text":
                    self.type = .Text
                case "view":
                    self.type = .View
                default:
                    self.type = .Text
            }
        }
    }
    
    /** Default initializer that sets just the title to Menu Item */
    init()
    {
        title = "Menu item"
    }
}