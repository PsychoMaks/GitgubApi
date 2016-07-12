//
//  User.swift
//  GithubApi
//
//  Created by Maks Sergeychuk on 7/9/16.
//  Copyright © 2016 remiy.com. All rights reserved.
//

import Foundation
import CoreData
import GithubPilot


class User: NSManagedObject {
    
    class func userWithUserInfo(userInfo: GithubUser, inManagedObjectContext context: NSManagedObjectContext) -> User? {
        let request = NSFetchRequest(entityName: "User")
        request.predicate = NSPredicate(format: "iD = %@", NSNumber(int: userInfo.id))
        
        if let user = (try? context.executeFetchRequest(request))?.first as? User {
            return user
        } else if let user = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: context) as? User {
            user.avatarURL = userInfo.avatarURL
            user.company = userInfo.company
            user.email = userInfo.email
            user.url = userInfo.url
            user.followersCount = NSNumber(int: userInfo.followers!)
            user.followingCount = NSNumber(int: userInfo.following!)
            user.gistsCount = NSNumber(int: userInfo.publicGists!)
            user.reposCount = NSNumber(int: userInfo.publicRepos!)
            user.iD = NSNumber(int: userInfo.id)
            user.name = userInfo.name
            user.login = userInfo.login
            user.reposURL = userInfo.reposURL
            return user
        }
        return nil
    }
    
    class func userWithJSONInfo(userJSONInfo: Dictionary<String, AnyObject>, inManagedObjectContext context: NSManagedObjectContext) -> User? {
        let request = NSFetchRequest(entityName: "User")
        request.predicate = NSPredicate(format: "iD = %@", argumentArray: [(userJSONInfo["id"] as? Int)!])
        
        
        
        if let user = (try? context.executeFetchRequest(request))?.first as? User {
            return user
        } else if let user = NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: context) as? User {  
            user.avatarURL = userJSONInfo[kAvatarURL] as? String
            user.company = userJSONInfo[kCompany] as? String
            user.email = userJSONInfo[kEmail] as? String
            user.url = userJSONInfo[kURL] as? String
            user.followersCount = userJSONInfo[kFollowers] as? NSNumber
            user.followingCount = userJSONInfo[kFollowing] as? NSNumber
            user.gistsCount = userJSONInfo[kGists] as? NSNumber
            user.reposCount = userJSONInfo[kRepos] as? NSNumber
            user.iD = userJSONInfo[kID] as? NSNumber
            user.name = userJSONInfo[kName] as? String
            user.login = userJSONInfo[kLogin] as? String
            user.reposURL = userJSONInfo[kReposURL] as? String
            return user
        }
        return nil
    }
    
    class func userInDataBase(user: GithubUser, inManagedObjectContext context: NSManagedObjectContext) -> User? {
        let request = NSFetchRequest(entityName: "User")
        request.predicate = NSPredicate(format: "iD = %@", NSNumber(int: user.id))
        
        if let user = (try? context.executeFetchRequest(request))?.first as? User {
            return user
        } else {
            return nil
        }
    }
}
