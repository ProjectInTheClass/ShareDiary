//
//  Diary.swift
//  ShareDiary
//
//  Created by 김현철 on 2022/05/10.
//

import Foundation

struct Diary : Codable {
    var authorId: String
    var date: Date
    var tag: [String]
    var sharedGroupId: [String]
    var imageUrls: [String]
    var videoUrls: [String]
    var text: String
    var emotion: String
}

extension Encodable {
    /// Object to Dictionary
    /// cf) Dictionary to Object: JSONDecoder().decode(Object.self, from: dictionary)
    var asDictionary: [String: Any]? {
        guard let object = try? JSONEncoder().encode(self),
              let dictinoary = try? JSONSerialization.jsonObject(with: object, options: []) as? [String: Any] else { return nil }
        return dictinoary
    }
}
