//
//  Settings.swift
//  GithubApi
//
//  Created by Maks Sergeychuk on 7/11/16.
//  Copyright © 2016 remiy.com. All rights reserved.
//

import Foundation
import CoreData


class Settings: NSManagedObject {

    class func getSettings(inManagedObjectContext context: NSManagedObjectContext) -> Settings? {
        let request = NSFetchRequest(entityName: "Settings")
//        request.predicate = NSPredicate(format: "iD = %@", argumentArray: [(userJSONInfo["id"] as? Int)!])
        
        if let settings = (try? context.executeFetchRequest(request))?.first as? Settings {
            return settings
        } else if let settings = NSEntityDescription.insertNewObjectForEntityForName("Settings", inManagedObjectContext: context) as? Settings {
            settings.name = "Settings"
            settings.useAutoAuth = false
            settings.authenticated = false
            settings.firstLaunch = true
            return settings
        }
        return nil
    }

}
