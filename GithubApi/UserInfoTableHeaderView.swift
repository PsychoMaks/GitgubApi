//
//  UserInfoTableHeaderView.swift
//  GithubApi
//
//  Created by Maks Sergeychuk on 7/12/16.
//  Copyright © 2016 remiy.com. All rights reserved.
//

import UIKit

class UserInfoTableHeaderView: UITableViewHeaderFooterView {
    
    @IBInspectable  @IBOutlet weak var userPickImageView: UIImageView!
    @IBInspectable  @IBOutlet weak var labelUserTitle: UILabel?
    @IBInspectable  @IBOutlet weak var labelFollowersCount: UILabel!
    @IBInspectable  @IBOutlet weak var labelFollowingCount: UILabel!
    @IBInspectable  @IBOutlet weak var labelGist: UILabel!
    @IBInspectable  @IBOutlet weak var labelRepos: UILabel!
    @IBInspectable  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func layoutSubviews() {
        super.layoutSubviews()
        if let label = labelUserTitle {
            label.preferredMaxLayoutWidth = label.bounds.width
        }
    }
    
}
