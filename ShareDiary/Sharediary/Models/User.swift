//
//  User.swift
//  ShareDiary
//
//  Created by 김현철 on 2022/05/10.
//

import Foundation

struct User: Codable {
    var id: String
    var useremail: String
    var username: String
    var blockedUserId: [String]
    var profileImageUrl: String?
}

extension User {
    init?(data: [String:Any]) {
        guard let id = data["id"] as? String,
              let useremail = data["useremail"] as? String,
              let username = data["username"] as? String,
              let blockedUserId = data["blockedUserId"] as? [String],
              let profileImageUrl = data["profileImageUrl"] as? String? else {
            return nil
        }
        self.init(id: id, useremail: useremail, username: username, blockedUserId: blockedUserId, profileImageUrl: profileImageUrl)
    }
}
