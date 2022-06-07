//
//  Diary.swift
//  ShareDiary
//
//  Created by 김현철 on 2022/05/10.
//

import Foundation
import FirebaseFirestore

struct Diary : Codable {
    var id: String
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

extension Diary {
    
    init?(data: [String: Any]) {
        guard let id = data["id"] as? String,
              let authorId = data["authorId"] as? String,
              let date = data["date"] as? Timestamp,
              let tag = data["tag"] as? [String],
              let sharedGroupId = data["sharedGroupId"] as? [String],
              let imageUrls = data["imageUrls"] as? [String],
              let videoUrls = data["videoUrls"] as? [String],
              let text = data["text"] as? String,
              let emotion = data["emotion"] as? String else {
            return nil
        }
        
        self.init(id: id, authorId: authorId, date: date.dateValue(), tag: tag, sharedGroupId: sharedGroupId, imageUrls: imageUrls, videoUrls: videoUrls, text: text, emotion: emotion)
    }
}
