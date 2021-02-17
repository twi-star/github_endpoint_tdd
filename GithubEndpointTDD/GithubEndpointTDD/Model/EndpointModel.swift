//
//  EndpointModel.swift
//  MougiTDD
//
//  Created by Julian on 2021/2/15.
//

import Foundation
import RealmSwift

class EndpointModel : Object, Codable {
    @objc dynamic var authorizations_url: String = ""
    @objc dynamic var code_search_url: String = ""
    @objc dynamic var commit_search_url: String = ""
    @objc dynamic var current_user_authorizations_html_url: String = ""
    @objc dynamic var current_user_repositories_url: String = ""
    @objc dynamic var current_user_url: String = ""
    @objc dynamic var emails_url: String = ""
    @objc dynamic var emojis_url: String = ""
    @objc dynamic var events_url: String = ""
    @objc dynamic var feeds_url: String = ""
    @objc dynamic var followers_url: String = ""
    @objc dynamic var following_url: String = ""
    @objc dynamic var gists_url: String = ""
    @objc dynamic var hub_url: String = ""
    @objc dynamic var issue_search_url: String = ""
    @objc dynamic var issues_url: String = ""
    @objc dynamic var keys_url: String = ""
    @objc dynamic var label_search_url: String = ""
    @objc dynamic var notifications_url: String = ""
    @objc dynamic var organization_repositories_url: String = ""
    @objc dynamic var organization_teams_url: String = ""
    @objc dynamic var organization_url: String = ""
    @objc dynamic var public_gists_url: String = ""
    @objc dynamic var rate_limit_url: String = ""
    @objc dynamic var repository_search_url: String = ""
    @objc dynamic var repository_url: String = ""
    @objc dynamic var starred_gists_url: String = ""
    @objc dynamic var starred_url: String = ""
    @objc dynamic var user_organizations_url: String = ""
    @objc dynamic var user_repositories_url: String = ""
    @objc dynamic var user_search_url: String = ""
    @objc dynamic var user_url: String = ""
}
