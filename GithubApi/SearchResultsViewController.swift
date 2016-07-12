//
//  SearchResultsViewController.swift
//  GithubApi
//
//  Created by Maks Sergeychuk on 7/8/16.
//  Copyright © 2016 remiy.com. All rights reserved.
//

import UIKit
import GithubPilot
import Alamofire
import AlamofireImage
import SafariServices
import CoreData

let repoCellIdentifier = "repoCell"

class SearchResultsViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infoButton: UIButton!
    
    let dataSource = SearchResultsDataSource()
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    weak var user: User?
    var repositoriesNextPage: String = "1" // default page
    var settings: Settings?
    var context: NSManagedObjectContext?
    let overlayView = UIView()
    
    

    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        settings = (UIApplication.sharedApplication().delegate as! AppDelegate).settings
        context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        overlayView.backgroundColor = UIColor.blackColor()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 64.0
        self.tableView.dataSource = dataSource
        
        self.loadRepos()
        self.setupUserInfo()
        self.setupBarButton()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sizeHeaderToFit()
    }
    
    func sizeHeaderToFit() {
        let headerView = tableView.tableHeaderView!
        
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        
        let height = headerView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        var frame = headerView.frame
        frame.size.height = height
        headerView.frame = frame
        
        tableView.tableHeaderView = headerView
    }
    
    
    // MARK: - UI
    func setupUserInfo() {
        if let headerView = self.tableView.tableHeaderView as? UserInfoTableHeaderView {
            
            headerView.activityIndicator.startAnimating()
            
            var userNameCompanyAndEmail = ((user?.name) != nil) ? user?.name! : user?.login
            let company = user?.company, email = user?.email
            
            if company != nil && company != "" { userNameCompanyAndEmail = userNameCompanyAndEmail! + ", " + company! }
            if email != nil && email != "" { userNameCompanyAndEmail = userNameCompanyAndEmail! + ", " + email! }
            
            headerView.labelUserTitle!.text = userNameCompanyAndEmail
            
            headerView.labelFollowersCount.text = NSLocalizedString("userFollowers", comment: "") + ": \((user?.followersCount)!)"
            headerView.labelFollowingCount.text = NSLocalizedString("userFollowing", comment: "") + ": \((user?.followingCount)!)"
            headerView.labelGist.text = NSLocalizedString("userGists", comment: "") + ": \((user?.gistsCount)!)"
            headerView.labelRepos.text = NSLocalizedString("userRepositories", comment: "") + ": \((user?.reposCount)!)"
            
            Alamofire.request(.GET, user!.avatarURL!).responseImage {[weak headerView] response in
                if let image = response.result.value {
                    headerView!.userPickImageView.image = image
                }
                headerView!.activityIndicator.stopAnimating()
            }
        }
    }
    
    
    // MARK: - Sharing
    func setupBarButton() {
       self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(add(_:)))
    }
    
    func makeItems() -> [PopoverItem] {
        
        let item0 = PopoverItem(title: NSLocalizedString("Open in safari", comment: ""), image: nil) {[unowned self] (PopoverItem) in
            
            if let profileLink = self.user?.url {
                self.presentViewController(SFSafariViewController(URL: NSURL(string: profileLink)!), animated: true, completion: nil)
            }
            self.add(nil)
        }
        let item1 = PopoverItem(title: NSLocalizedString("Save", comment: ""), image: nil) {[unowned self] (PopoverItem) in
            if let url = self.user?.url {
                UIPasteboard.generalPasteboard().string = url
            }
            self.add(nil)
        }
        let item2 = PopoverItem(title: NSLocalizedString("Share", comment: ""), image: nil) {[unowned self] (PopoverItem) in
            self.shareButtonPressed()
            self.add(nil)
        }
        
        return [item0, item1, item2]
    }
    
    func add(sender: UIBarButtonItem?) {
        if popoverDidAppear {
            UIView.animateWithDuration(1.5, delay: NSTimeInterval(0), usingSpringWithDamping: 1.7, initialSpringVelocity: 0.6, options: UIViewAnimationOptions.CurveLinear, animations: {
                
                self.overlayView.alpha = 0.0
                self.tableView.transform = CGAffineTransformMakeScale(1, 1)
                self.dismissPopover()
                
                }, completion: { (Bool) in
                    self.overlayView.removeFromSuperview()
            })
            
        } else {
            overlayView.frame = self.view.frame
            overlayView.alpha = 0.0
            
            self.view.addSubview(overlayView)
            let controller = PopoverController(items: makeItems(), fromView: infoButton, direction: .Down, style: .Normal)

            UIView.animateWithDuration(1.5, delay: NSTimeInterval(0), usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4, options: UIViewAnimationOptions.CurveLinear, animations: {
                self.overlayView.alpha = 0.3
                self.tableView.transform = CGAffineTransformMakeScale(0.9, 0.9)
                }, completion: nil)
            popover(controller)
        }
    }
    
    func shareButtonPressed() {
        let URL = NSURL(string: (user?.url)!)!
        var string = (user?.name != nil) ? (user?.name)! : (user?.login)!
        string += NSLocalizedString("sharingNameTitle", comment: "")
        
        let activityViewController = UIActivityViewController(activityItems: [URL, string],
                                                              applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityTypePostToFacebook]
        
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func infoButtonPressed(sender: UIButton) {
        let controller = PopoverController(items: makeItems(), fromView: infoButton, direction: .Down, style: .Normal)
        popover(controller)
    }
    
    
    // MARK: - Network
    func loadRepos() {
        if user?.repositories?.count > 0 {
            let repoArray: Array = user?.repositories?.allObjects as! [Repo]
            self.dataSource.repos = repoArray
        } else {
            if (Github.authorizedClient != nil) {
                loadAuthRepos()
            } else {
                loadGuestRepos()
            }
        }
    }
    
    func loadAuthRepos() {
        Router.searchGithubForReposByUser((user?.login)!, page: repositoriesNextPage, inContext: context!) {[unowned self] (repos, nextPage, success, error) in
            if success {
                
                self.dataSource.repos = repos!
                if let nextPage = nextPage {
                    self.repositoriesNextPage = nextPage
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.prepareToShowRepos()
                })
            } else { print(error) }
        }
    }
    
    func loadGuestRepos() {
        Router.searchGuestGithubForReposByUser((user?.login)!, inContext: context!) { (repos, success, error) in
            if success {
                self.dataSource.repos = repos!
                dispatch_async(dispatch_get_main_queue(), {
                    self.prepareToShowRepos()
                })
            } else { print(error) }
        }
    }
    
    func prepareToShowRepos() {
        if  dataSource.repos.count > 0 {
            
            self.tableView.alpha = 0.0
            self.tableView.reloadData()
            
            let diff = 0.05
            let tableHeight = self.tableView.bounds.size.height
            let cells = self.tableView.visibleCells
            
            for cell in cells {
                if cell.isKindOfClass(UITableViewCell) {
                    cell.transform = CGAffineTransformMakeTranslation(0, tableHeight)
                }
            }
            
            self.tableView.alpha = 1.0
            var counter = 0.0
            for cell in cells {
                UIView.animateWithDuration(1.6,
                                           delay: diff*counter,
                                           usingSpringWithDamping: 0.77,
                                           initialSpringVelocity: 0,
                                           options: .CurveEaseInOut,
                                           animations: {
                                            cell.transform = CGAffineTransformMakeTranslation(0, 0)
                    }, completion: nil)
                counter += 1
            }
        }
    }
    

    // MARK: - TableView Delegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let hubURL = self.dataSource.repos[indexPath.row].url where !hubURL.isEmpty {
            
            self.presentViewController(SFSafariViewController(URL: NSURL(string: hubURL)!),
                                       animated: true,
                                       completion: nil)
        }
    }
}
