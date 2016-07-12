//
//  SearchViewController.swift
//  GithubApi
//
//  Created by Maks Sergeychuk on 7/8/16.
//  Copyright © 2016 remiy.com. All rights reserved.
//

import UIKit
import Alamofire
import GithubPilot
import CoreData
import Whisper

class SearchViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var catImageView: UIImageView!
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var autoAuthSwitch: UISwitch!
    @IBOutlet var searchTopConstraint: NSLayoutConstraint!
    @IBOutlet var catConstraint: NSLayoutConstraint!
    
    
    var cachedGithubUser: User?
    var settings: Settings?
    var context: NSManagedObjectContext?
    
    var searchTerm: String {
        var term = searchTextField.text!
        if term.containsString(" ") || term.containsString("\n") {
            term = term.stringByReplacingOccurrencesOfString(" ", withString: "")
        }
        
        return term
    }
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        searchTextField.delegate = self
        context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        settings = (UIApplication.sharedApplication().delegate as! AppDelegate).settings
        searchTopConstraint.active = false

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SearchViewController.tap(_:)))
        view.addGestureRecognizer(tapGesture)
    
        autoAuthSwitch.setOn(settings?.useAutoAuth as! Bool, animated: false)
        if autoAuthSwitch.on {
            Router.authenticate()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(SearchViewController.keyboardShown(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(SearchViewController.keyboardShown(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    // MARK: - Network
    func searchGithubForUser() {
        if self.cachedGithubUser?.login == searchTerm {
            performSegueWithIdentifier(showSearchResultsVC, sender: nil)
        } else {
            if settings?.useAutoAuth as! Bool {
                if (Github.authorizedClient != nil) {
                    self.settings?.authenticated = true
                    self.searchAuthUser()
                } else {
                    self.showAuthAlert()
                }
            } else {
                self.searchGuestUser()
            }
        }
    }
    
    func searchAuthUser() {
        Router.searchGithubForUser(searchTerm, inContext: context!) { [unowned self] (user, success, error) in
            if success {
                self.cachedGithubUser = user
                dispatch_async(dispatch_get_main_queue(), {
                    self.performSegueWithIdentifier(showSearchResultsVC, sender: nil)
                })
            } else {
                let controller = self.navigationController as! BaseViewController
                controller.showNotification(Message(title: NSLocalizedString(error!, comment: ""), textColor: UIColor.whiteColor(), backgroundColor: UIColor.lightGrayColor(), images:nil ))
                
            }
        }
    }
    
    func searchGuestUser() {
        Router.searchGuestGithubForUser(searchTerm, inContext: context!) { [unowned self] (user, success, error) in
            if success {
                self.cachedGithubUser = user
                dispatch_async(dispatch_get_main_queue(), {
                    self.performSegueWithIdentifier(showSearchResultsVC, sender: nil)
                })
            } else {
                let controller = self.navigationController as! BaseViewController
                controller.showNotification(Message(title: NSLocalizedString(error!, comment: ""), textColor: UIColor.whiteColor(), backgroundColor: UIColor.lightGrayColor(), images:nil ))
            }
        }
    }
    
    
    // MARK: - Actions
    @IBAction func searchButtonPressed(sender: UIButton) {
        if !searchTerm.isEmpty {
            self.searchTextField.resignFirstResponder()
            searchGithubForUser()
        }
    }
    
    @IBAction func switchValueChanged(sender: UISwitch) {
        if sender.on {
            settings?.useAutoAuth = true
            if (Github.authorizedClient != nil) {
                settings?.authenticated = true
            } else {
                if settings?.firstLaunch! == true {
                    showAuthAlert()
                    settings?.firstLaunch = false
                } else {
                    Router.authenticate()
                }
            }
        } else {
            settings?.useAutoAuth = false
        }
    }
    
    func tap(gesture: UITapGestureRecognizer) {
        if searchTextField.isFirstResponder() {
            searchTextField.resignFirstResponder()
        }
    }
    
    func keyboardShown(notification: NSNotification) {
        

        if notification.name == UIKeyboardWillHideNotification {
            self.searchTopConstraint.active = false
            self.catConstraint.active = true
        } else if notification.name == UIKeyboardWillShowNotification {
            self.catConstraint.active = false
            self.searchTopConstraint.active = true
            let info  = notification.userInfo!
            let value: AnyObject = info[UIKeyboardFrameEndUserInfoKey]!
            let rawFrame = value.CGRectValue
            let frame = view.convertRect(rawFrame, fromView: nil)
            self.searchTopConstraint.constant = frame.origin.y - 150.0
        }
        
        
        UIView.animateWithDuration(NSTimeInterval(1.4)) {
            if notification.name == UIKeyboardWillHideNotification {
                self.catImageView.alpha = 1
            } else if notification.name == UIKeyboardWillShowNotification {
                self.catImageView.alpha = 0.3
            }
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Common Delegates
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationVC = segue.destinationViewController as! SearchResultsViewController
        destinationVC.user = cachedGithubUser
        destinationVC.navigationItem.title = cachedGithubUser?.login
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == showSearchResultsVC {
            if !searchTerm.isEmpty && self.cachedGithubUser?.login == searchTerm {
                return true
            }
        }
        return false
    }

    // MARK: - TextField Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if !searchTerm.isEmpty {
            textField.resignFirstResponder()
            searchGithubForUser()
            return true
        } else {
            return false
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return (string == " ") ? false : true
    }
    
    // MARK: - Show alert And Auth
    func showAuthAlert() {
        let authNotificationAlert = UIAlertController(title: NSLocalizedString("alertNeedAuth", comment: ""),
                                                      message: NSLocalizedString("alertAuthCaption", comment: ""),
                                                      preferredStyle: .Alert)
        authNotificationAlert.addAction(UIAlertAction(title: NSLocalizedString("alertAuthOK", comment: ""), style: .Default, handler: { (UIAlertAction) in
            Router.authenticate()
        }))
        presentViewController(authNotificationAlert, animated: true, completion: nil)
    }
    
}
