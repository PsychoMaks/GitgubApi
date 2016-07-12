//
//  SearchResultsDataSource.swift
//  GithubApi
//
//  Created by Maks Sergeychuk on 7/10/16.
//  Copyright © 2016 remiy.com. All rights reserved.
//

import Foundation
import UIKit
import GithubPilot

class SearchResultsDataSource: NSObject, UITableViewDataSource {
    
    var repos = [Repo]()
    
    
    // MARK: - Init
    override init() { }
    
    init(repositories repos: [Repo]) {
        super.init()
        self.repos = repos
    }
    
    
    // MARK: - TableView Datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("userRepoListTableTitle", comment: "")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repos.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(repoCellIdentifier) as! RepoTableViewCell
        let repo = repos[indexPath.row]
        
        cell.labelRepoTitle.text = repo.name
        cell.labelRepoLanguage.text = repo.language
        cell.labelForkCount.text = String((repo.forksCount)!)
        cell.labelStarCount.text = String((repo.starsCount)!)
        
        return cell
    }
    
}
