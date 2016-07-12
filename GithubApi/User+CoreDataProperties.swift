//
//  User+CoreDataProperties.swift
//  GithubApi
//
//  Created by Maks Sergeychuk on 7/11/16.
//  Copyright © 2016 remiy.com. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var avatarURL: String?
    @NSManaged var company: String?
    @NSManaged var email: String?
    @NSManaged var followersCount: NSNumber?
    @NSManaged var followingCount: NSNumber?
    @NSManaged var gistsCount: NSNumber?
    @NSManaged var iD: NSNumber?
    @NSManaged var name: String?
    @NSManaged var reposCount: NSNumber?
    @NSManaged var reposURL: String?
    @NSManaged var url: String?
    @NSManaged var login: String?
    @NSManaged var repositories: NSSet?

}
