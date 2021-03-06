//
//  Repo+CoreDataProperties.swift
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

extension Repo {

    @NSManaged var forksCount: NSNumber?
    @NSManaged var iD: NSNumber?
    @NSManaged var language: String?
    @NSManaged var name: String?
    @NSManaged var starsCount: NSNumber?
    @NSManaged var url: String?
    @NSManaged var owner: User?

}
