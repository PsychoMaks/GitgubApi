//
//  Repo.swift
//  GithubApi
//
//  Created by Maks Sergeychuk on 7/9/16.
//  Copyright © 2016 remiy.com. All rights reserved.
//

import Foundation
import CoreData
import GithubPilot


class Repo: NSManagedObject {

    class func repoWithRepoInfo(repoInfo: GithubRepo,userInfo: GithubUser, inManagedObjectContext context: NSManagedObjectContext) -> Repo? {
        let request = NSFetchRequest(entityName: "Repo")
        request.predicate = NSPredicate(format: "iD = %@", NSNumber(int: repoInfo.id))
        
        if let repo = (try? context.executeFetchRequest(request))?.first as? Repo {
            return repo
        } else if let repo = NSEntityDescription.insertNewObjectForEntityForName("Repo", inManagedObjectContext: context) as? Repo {
            
            repo.iD = NSNumber(int: repoInfo.id)
            repo.name = repoInfo.name
            repo.language = repoInfo.language
            repo.url = repoInfo.url
            repo.forksCount = NSNumber(int: repoInfo.forksCount!)
            repo.starsCount = NSNumber(int: repoInfo.stargazersCount!)
            repo.owner = User.userWithUserInfo(userInfo, inManagedObjectContext: context)
            return repo
        }
        return nil
    }
    
    class func repoWithJSONInfo(repoJSONInfo: Dictionary<String, AnyObject>, inManagedObjectContext context: NSManagedObjectContext) -> Repo? {
        let request = NSFetchRequest(entityName: "Repo")
        request.predicate = NSPredicate(format: "iD = %@", argumentArray: [(repoJSONInfo["id"] as? Int)!])
        
        if let repo = (try? context.executeFetchRequest(request))?.first as? Repo {
            return repo
        } else if let repo = NSEntityDescription.insertNewObjectForEntityForName("Repo", inManagedObjectContext: context) as? Repo {
            repo.iD = repoJSONInfo[kID] as? NSNumber
            repo.name = repoJSONInfo[kName] as? String
            repo.language = repoJSONInfo[kLanguage] as? String
            repo.starsCount = repoJSONInfo[kStarsCount] as? NSNumber
            repo.forksCount = repoJSONInfo[kForksCount] as? NSNumber
            repo.url = repoJSONInfo[kURL] as? String
            let repoOwner = repoJSONInfo[kOwner] as! Dictionary<String, AnyObject>
            repo.owner = User.userWithJSONInfo(repoOwner, inManagedObjectContext: context)
            return repo
        }
        return nil
    }
}
