# Demo
![This is what you get when you integrate the two controllers in your project. You can use this as the starting point for your project that requires this kind of container.](https://github.com/pralancer/PKSideMenuDetailContainerController/raw/master/Demo/Demo.gif)

# Introduction
There was a dire need of a container controller that displayed a menu on the left hand side and a detail controller on the right hand side.  Its similar to the Master detail controller but that didn't serve the purpose of having a retractable main menu which is usually implemented as a table view controller and a detail view controller which displays the details of the selected menu item. 

This project serves to fill that gap. It consists of two modules. A plist based main menu controllers that you can use as the left side of the side menu and a side menu container view controller in which you can host this menu controller and your app specific detail controller.

### Menu Table view Controller and model ###
A main menu table view controller that is driven by a plist based model for the menu items. You specify the menu items in a plist and a custom table view controller uses that plist as the model for the menu. Each menu item is highly configurable as a text or an image or a custom view. Each menu item attributes can be set indidivually or can be specified as defaults in the plist file. The menu itself can have a background color an background image.

This makes use of the [ColorUtils](http://github.com/nicklockwood/ColorUtils) by Nick Lockwood.

**PKMainMenuTableViewController**
This is a table view controller that uses a `PKMainMenuModel` instance to display the menu items. By default it creates the model from the MainMenu.plist file if present in the project. Otherwise you can get your own model by setting a instance of PKMainMenuModel to the `menuModel` property of the table view controller.

**PKMainMenuItem** - Specifies a single menu item in the table. It has many configurable properties that are created from the entries in the plist. You can create your own menu item dynamically and add it to the menu model of the menu view controller.

**PKMainMenuModel**
This is a menu model that is created by specifying a plist file path. You set the instance of this to the main menu table view controller.

**The Menu Model plist file format**
The plist specifies the model and the items for the menu table view and the menu items.
`Root.backgroundImage [String]` - Name of the image to be used as the background image for the menu
`Root.backgroundColor [String]` - Name or color code of the color for the background of the menu if no image is specified. The string can be of the form such as red, green, blue, cyan, lightgray etc or hex color code such as #FF0000, #00FF00 or 0xAABBCC etc
`Root.defaults.textColor [String]` - Default color of the menu item title
`Root.defaults.backgroundColor [String]` - Default background color for the menu item
`Root.defaults.selectedColor [String]` - Default selected menu item color
`Root.defaults.fontName [String]` - Default font name for the menu item
`Root.defaults.fontSize [Number]` - Default font size for the menu item
`Root.defaults.rowHeight [Number]` - Default row height for the menu item in the table view    `Root.items - [Array of Dictionaries]` - An array of dictionaries that define each menu item

**Menu item dictionaries**
You can override all the defaults key in each menu item if you want to customise each menu item separately. Wherever the are not specified then the defaults will be used. The properties for each menu item are:

 - `type [String]` - text, image or view. Text means its a text title, image indicates that entire menu item is an image. View means the menu item is created dynamically by specifying a view. The `PKMainMenuTableViewDelegate` delegate used to provide a menu item view using the `viewForMenuItem` method.
 - `title [String]` - Specifies the menu item title for a text type of menu
 - `identifier [String]` - A unique identifier used to identify which menu item was selected so that the appropriate action can be taken in the app
 - `imageName [String]` - Name of the icon image for the text based menu item or the menu item image if its a image based menu item.
 - `selectable [Boolean]` - Indicates whether this menu item can be selected or not.

### Side Menu Container controller ###
A container view controller for creating a side menu and detail view controller that you see in many applications. Using this you can easily create a container controller in storyboard and specify your own controlles for the left hand side which is usually a menu table and a detail controller which is usually hosted by a navigation controller. 
A menu table view controller can be easily created using the PKMainMenu* classes which offers a plist based model for the menu and a highly configurable table view controller to render that menu.

To use this class follow these steps.

 1. Create a view controller in storyboard and set its custom class to
    PKSideMenuContainerController.
 2. Add two container views to this view and set the embed segues of
    these two container views to the respective controllers.
 3. Set the menu controller segue id to menuVCSegue and the detail
    controller segue to detailVCSegue.
 4. Set the layout constraints of the left and right container views so that the left container view has a specific width and is constrained to top, left and bottom layouts. Set the layout constraints of the detail to constrain to all the four sides since its the detail view controller and has to cover the whole screen.

If you don't set a delegate to the menu table view controller then the selected menu item action is broadcasted via a notification `PKMainMenuTableViewDidSelectNotification` with the menu table view controller as the object. You can then use the selectedItem property of the table view controller to get the menu item that was selected.

I am trying to simplify the usage further but if you have any questions please let me know.
