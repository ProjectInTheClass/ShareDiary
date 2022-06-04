//
//  Group.swift
//  ShareDiary
//
//  Created by 김현철 on 2022/05/10.
//

import Foundation
import FirebaseFirestore

struct Group:Codable {
    var groupName: String
    var memberId: [String]
    var inviteCode: String
    var createdAt: Date
}

extension Group {
    init?(data: [String: Any]) {
        guard let groupName = data["groupName"] as? String,
              let memberId = data["memberId"] as? [String],
              let inviteCode = data["inviteCode"] as? String,
              let createdAt = data["createdAt"] as? Timestamp else {
            return nil
        }
        self.init(groupName: groupName, memberId: memberId, inviteCode: inviteCode, createdAt: createdAt.dateValue())
    }
}
