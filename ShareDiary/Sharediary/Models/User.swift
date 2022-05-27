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
