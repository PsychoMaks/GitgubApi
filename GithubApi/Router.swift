//
//  Router.swift
//  GithubApi
//
//  Created by Maks Sergeychuk on 7/10/16.
//  Copyright © 2016 remiy.com. All rights reserved.
//

import Foundation
import GithubPilot
import Alamofire
import CoreData


class Router {
    class func authenticate() {
        Github.setupClientID("e25b41ede21ca059e9ae",
                             clientSecret: "2901c3693aa23d940d0d8f60da2a5f80201b9f9e",
                             scope: ["user", "repo"],
                             redirectURI: "GithubApi://admin")
        Github.authenticate()
    }
    
    class func searchGithubForUser(userName: String, inContext context: NSManagedObjectContext, completion: (user: User?, success: Bool, error: String?) -> Void) {
        if let client = Github.authorizedClient {
            client.users.getUser(username: userName).response({(githubUser, error) -> Void in
                if error == nil {
                    if let trueUser = githubUser {
                        if let user = User.userWithUserInfo(trueUser, inManagedObjectContext: context) {
                            completion(user: user, success: true, error: nil)
                        }
                    }
                } else {
                    completion(user: nil, success: false, error: error?.description)
                }
            })
        }
    }
    
    class func searchGuestGithubForUser(userName: String, inContext context: NSManagedObjectContext, completion: (user: User?, success: Bool, error: String?) -> Void) {
        
        Alamofire.request(.GET, githubGuestApiSearchUserURL + userName).validate().responseJSON { response in
            if let JSON = response.result.value {
                if let user = User.userWithJSONInfo(JSON as! Dictionary<String, AnyObject>, inManagedObjectContext: context) {
                    completion(user: user, success: true, error: nil)
                }
            }
            if let errorBack = response.response?.statusCode {
                completion(user: nil, success: false, error: String(errorBack))
            } else {
                completion(user: nil, success: false, error: "Error")
            }
        }
    }
    
    
    class func searchGithubForReposByUser(name: String, page: String, inContext context: NSManagedObjectContext, completion: (repos: [Repo]?, nextPage: String?, success: Bool, error: String?) -> Void) {
        if let client = Github.authorizedClient {
            client.repos.getRepoFrom(owner: name, page: page).response({ (nextPage, result, error) -> Void in
                if (error == nil) {
                    let repoArray = NSMutableArray()
                    for repo in result! {
                        repoArray.addObject(Repo.repoWithRepoInfo(repo, userInfo: repo.owner!, inManagedObjectContext: context)!)
                    }
                    completion(repos: repoArray as NSArray as? [Repo],nextPage: page, success: true, error: nil)
                } else {
                    completion(repos: nil,nextPage: nil, success: false, error: error?.description)
                }
            })
        }
    }
    
    class func searchGuestGithubForReposByUser(userName: String, inContext context: NSManagedObjectContext, completion: (repos: [Repo]?, success: Bool, error: String?) -> Void) {
        
        Alamofire.request(.GET, githubGuestApiSearchUserURL + userName + githubGuestApiSearchRepos).validate().responseJSON { response in
            if let JSON = response.result.value {
                let repoArray = NSMutableArray()
                for repo in JSON as! Array<Dictionary<String, AnyObject>> {
                    repoArray.addObject(Repo.repoWithJSONInfo(repo, inManagedObjectContext: context)!)
                }
                completion(repos: repoArray as NSArray as? [Repo], success: true, error: nil)
            } else {
                completion(repos: nil, success: false, error: response.result.error?.description)
            }
        }
    }
}

