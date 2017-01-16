//
//  Constants.swift
//  TestProject
//
//  Created by Sudhansu Singh on 6/9/16.
//  Copyright © 2016 Sudhansu Singh. All rights reserved.
//

let kBlankString = ""
let kSingleSpaceString = " "
let kDBBaseRef = "https://testproject-65c75.firebaseio.com"
let kFBStorage = "gs://testproject-65c75.appspot.com"
let kDBPostRef = "/posts"
let kDBUserRef = "users"
let kDBImageRef = "/images"
let kDBBidRef = "/bids"
let kDBPostBidRef = "/postBids"

let kOlive = "3D9970"
let kNewOlive = "33AA99"
let kMenuColor = "61A6AB"
let kLightPink = "#f48fb1"
let kBarColor = "#e05038"
let kBarRedColor = "#f26964"
let kNavBarColor = "#61A6A9"
let ktabBarColor = "#80CBC4"
let kFreeColor = "#7FC7AF"
let kWhiteFD = "#FDFDFD"
let kFGTextColor = "#00897B"

let kPostLimit :UInt =  20


let kCloseCellHeight: CGFloat = 179
let kOpenCellHeight: CGFloat = 488

let kDimLevel: CGFloat = 0.5
let kDimSpeed: Double = 0.5

//MARK: cell elements tags
// foreground elements
let kFLeftView = 8
let kFName = 50
let kFLocation = 51
let kFPrice = 52
let kDay = 53
let kTime = 54
let kDate = 55
let kBids = 56

// background elements

// bar items
let kBBar = 88

let kBBarPriceLabel = 89
let kBDefaultImage = 90
let kBUserImg = 91
let kBUserName = 92
let kBUserLoc = 93
let kBUserMsg = 94
let kBLastBidAmount = 95
let kBLastBidder = 96

// Buttons
let kBidButton = 60
let kChatButton = 61


let kDateFormatter = "yyyy-MM-dd'T'HH:mm:ssZ"

// UserDefault

public struct defaultsKeys {
    static let  fbId = "fbId"
    static let firId = "firId"
    static let name = "name"
    static let email = "email"
    static let image = "image"
    static let imageUrl = "iUrl"
}
