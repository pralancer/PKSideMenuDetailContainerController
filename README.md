# Introduction
There was a dire need of a container controller that displayed a menu on the left hand side and a detail controller on the right hand side.  Its similar to the Master detail controller but that didn't serve the purpose of having a retractable main menu which is usually implemented as a table view controller and a detail view controller which displays the details of the selected menu item. 

This project serves to fill that gap. It consists of two modules

### Menu Table view Controller and model ###
A main menu table view controller that is driven by a plist based model for the menu items. You specify the menu items in a plist and a custom table view controller uses that plist as the model for the menu. Each menu item is highly configurable as a text or an image or a custom view. Each menu item attributes can be set indidivually or can be specified as defaults in the plist file. The menu itself can have a background color an background image.

This makes use of the [ColorUtils](http://github.com/nicklockwood/ColorUtils) by Nick Lockwood.

**PKMainMenuTableViewController**
This is a table view controller that uses a `PKMainMenuModel` instance to display the menu items. By default it creates the model from the MainMenu.plist file if present in the project. Otherwise you can get your own model by setting a instance of PKMainMenuModel to the `menuModel` property of the table view controller.

**PKMainMenuItem** - Specifies a single menu item in the table. It has many configurable properties that are created from the entries in the plist. You can create your own menu item dynamically and add it to the menu model of the menu view controller.

**PKMainMenuModel**
This is a menu model that is created by specifying a plist file path. You set the instance of this to the main menu table view controller.

**The Menu Model plist file format**


### Side Menu Container controller ###
A container view controller for creating a side menu and detail view controller that you see in many applications. Using this you can easily create a container controller in storyboard and specify your own controlles for the left hand side which is usually a menu table and a detail controller which is usually hosted by a navigation controller. 
A menu table view controller can be easily created using the PKMainMenu* classes which offers a plist based model for the menu and a highly configurable table view controller to render that menu.


