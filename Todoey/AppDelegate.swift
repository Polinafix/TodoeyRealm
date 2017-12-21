//
//  AppDelegate.swift
//  Todoey
//
//  Created by Polina Fiksson on 18/12/2017.
//  Copyright © 2017 PolinaFiksson. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }


    func applicationWillTerminate(_ application: UIApplication) {
        
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    //NSPersistentContainer: this is where we are basically going to store all our data > SQLite database
    lazy var persistentContainer: NSPersistentContainer = {
       //set up the new persistent container
        let container = NSPersistentContainer(name: "DataModel")
        //load it up
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            //check for errors
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        //set the container that we loaded up and set it as a value of persistentContainer variable
        //we can access it in other classes to persist and save our data into DB
        return container
    }()
    
    // MARK: - Core Data Saving support
    //saving our data when/if app gets terminated
    func saveContext () {
        //context = area where you can change and update your data until you're happy with it
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                //save the data that's in your temporary area(context) to the permanent storage(container > DB)
                try context.save()
            } catch {
             
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }


}

