//
//  Group.swift
//  ShareDiary
//
//  Created by 김현철 on 2022/05/10.
//

import Foundation

struct Group:Codable {
    var groupName: String
    var memberId: [String]
    var inviteCode: String
    var createdAt: Date
}
