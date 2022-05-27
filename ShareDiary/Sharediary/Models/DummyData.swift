//
//  Dummy.swift
//  ShareDiary
//
//  Created by 김현철 on 2022/05/10.
//

import Foundation

var userDummies: [User] = [
    User(id: "RZ8Vzj8VyzP4mIOmfpPnCJD6qGY2",
         useremail: "khc18332@naver.com",
         username: "김현철",
         blockedUserId: ["NoatdXKDhdR6wiSQ2Sr2WU4nBXM2"],
         profileImageUrl: "images/profile_RZ8Vzj8VyzP4mIOmfpPnCJD6qGY2.jpg"),
    User(id: "MItGBOf72ZUwLBtOeUfSdGyaUEI2",
         useremail: "kjy4327@gmail.com",
         username: "김준엽",
         blockedUserId: ["afUVm4PXoCaxFQNSphCmp5h4W5l1"],
         profileImageUrl: nil),
    User(id: "afUVm4PXoCaxFQNSphCmp5h4W5l1",
         useremail: "pkw2273@gmail.com",
         username: "박근원",
         blockedUserId: ["MItGBOf72ZUwLBtOeUfSdGyaUEI2", "RZ8Vzj8VyzP4mIOmfpPnCJD6qGY2"],
         profileImageUrl: "images/profile_afUVm4PXoCaxFQNSphCmp5h4W5l1.jpg"),
    User(id: "4BtLUTwpAjNeZbey4BQ0twGkKvw2",
        useremail: "lys443@naver.com",
        username: "이융성",
        blockedUserId: [],
        profileImageUrl: nil),
    User(id: "NoatdXKDhdR6wiSQ2Sr2WU4nBXM2",
        useremail: "cbj2663@gmail.com",
        username: "최백준",
        blockedUserId: [],
        profileImageUrl: nil)
]

var groupDummies: [Group] = [
    Group(groupName: "EOS", //elVug0rGjegkC2f8ibVq
          memberId: ["RZ8Vzj8VyzP4mIOmfpPnCJD6qGY2","MItGBOf72ZUwLBtOeUfSdGyaUEI2", "afUVm4PXoCaxFQNSphCmp5h4W5l1"],
          inviteCode: "555781",
          createdAt: Calendar.current.date(from: DateComponents(year: 2011, month: 2, day: 1))!),
    Group(groupName: "알로하", // nuv0i2Y6Noi5R68Ckf1T
          memberId: ["MItGBOf72ZUwLBtOeUfSdGyaUEI2","4BtLUTwpAjNeZbey4BQ0twGkKvw2"],
          inviteCode: "361362",
          createdAt: Calendar.current.date(from: DateComponents(year: 2013, month: 1, day: 1))!),
    Group(groupName: "MDBB",
          memberId: ["RZ8Vzj8VyzP4mIOmfpPnCJD6qGY2","afUVm4PXoCaxFQNSphCmp5h4W5l1"],
          inviteCode: "005095",
          createdAt: Calendar.current.date(from: DateComponents(year: 2015, month: 11, day: 23))!),
    Group(groupName: "오소리",
         memberId: ["MItGBOf72ZUwLBtOeUfSdGyaUEI2","NoatdXKDhdR6wiSQ2Sr2WU4nBXM2"],
         inviteCode: "128181",
         createdAt: Calendar.current.date(from: DateComponents(year: 2012, month: 12, day: 17))!),
    Group(groupName: "2022소프트웨어스튜디오", // gUw4ilJm3pJH8dCP7doE
         memberId: ["RZ8Vzj8VyzP4mIOmfpPnCJD6qGY2","MItGBOf72ZUwLBtOeUfSdGyaUEI2"],
         inviteCode: "191198",
         createdAt: Calendar.current.date(from: DateComponents(year: 2022, month: 3, day: 2))!)
    
]

var diaryDummies: [Diary] = [
    Diary(authorId: "MItGBOf72ZUwLBtOeUfSdGyaUEI2",
          date: Calendar.current.date(from: DateComponents(year: 2022, month: 04, day: 5))!,
          tag: ["공부"],
          sharedGroupId: ["gUw4ilJm3pJH8dCP7doE"],
          imageUrls: [],
          videoUrls: [],
          text: "HIG 언제 다 듣지?",
          emotion: "😅"),
    Diary(authorId: "NoatdXKDhdR6wiSQ2Sr2WU4nBXM2",
          date: Calendar.current.date(from: DateComponents(year: 2013, month: 10, day: 25))!,
          tag: ["맛집", "친구", "동아리"],
          sharedGroupId: ["elVug0rGjegkC2f8ibVq"],
          imageUrls: ["images/U4y69eH6kzbVmOVJOJxR_0.jpg"],
          videoUrls: [],
          text: "오랜만에 술 한잔!",
          emotion: "😄"),
    Diary(authorId: "afUVm4PXoCaxFQNSphCmp5h4W5l1",
          date: Calendar.current.date(from: DateComponents(year: 2022, month: 4, day: 10))!,
          tag: ["IOS"],
          sharedGroupId: ["gUw4ilJm3pJH8dCP7doE"],
          imageUrls: [],
          videoUrls: [],
          text: "IOS 너무 재밌다!",
          emotion: "😁"),
    Diary(authorId: "4BtLUTwpAjNeZbey4BQ0twGkKvw2",
          date: Calendar.current.date(from: DateComponents(year: 2018, month: 12, day: 17))!,
          tag: ["공부", "알고리즘"],
          sharedGroupId: ["nuv0i2Y6Noi5R68Ckf1T"],
          imageUrls: [],
          videoUrls: [],
          text: "알고리즘 너무 어렵다 ㅠㅠ",
          emotion: "😥"),
    Diary(authorId: "NoatdXKDhdR6wiSQ2Sr2WU4nBXM2",
          date: Calendar.current.date(from: DateComponents(year: 2017, month: 9, day: 20))!,
          tag: ["IOS", "스위프트"],
          sharedGroupId: ["gUw4ilJm3pJH8dCP7doE", "elVug0rGjegkC2f8ibVq"],
          imageUrls: ["images/mbWmZzuzu9bophsgF6vv_0.jpg", "images/mbWmZzuzu9bophsgF6vv_1.jpg"],
          videoUrls: ["videos/mbWmZzuzu9bophsgF6vv_0.mp4"],
          text: "오늘 공부한 스위프트 문법",
          emotion: "🤓")
]
