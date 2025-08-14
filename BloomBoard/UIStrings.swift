//
//  UIStrings.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 7/3/25.
//

import Foundation
import SwiftUI

struct UIStrings {
    static let platformString = "Platform"
    static let postType = "Post Type"
    static let day = "Day"
    static let addBasePost = "Add Base Post"
    static let cancelString = "Cancel"
    static let saveString = "Save"
    static let basePlanEmpty = "Build Your Base Plan"
    static let startString = "Start"
    static let removeBasePost = "Remove Base Post"
    static let deleteString = "Delete"
    static let editBasePost = "Edit Base Post"
    static let basePlanString = "Base Plan"
    static let postDate = "Post Date"
}

struct PostStrings {
    static let created = "Created"
    static let copy = "Copy"
    static let communityString = "Community"
    static let title = "Title"
    static let drafts = "Drafts"
    static let published = "Published"
    static let postString = "Posts"
    static let uploadImage = "Upload Image"
    static let createPost = "Create Post"
    static let editPost = "Edit Post"
    static let noPosts = "No Posts"
    static let downloadImage = "Download Image"
    static let deletePost = "Delete Post?"
    static let edit = "Edit"
    static let post = "Post"
    static let posted = "Posted"
    static let selectPostDate = "Select Post Date"
    static let unpost = "Unpost"
    static let noPublishedPosts = "No Published Posts"
    static let noDrafts = "No Draft Posts"
    static let publishedPosts = "Published Posts"
    static let daftPosts = "Draft Posts"
    static let performance = "Performance"

}

struct Punctuation {
    static let colon = ":"
    static let space = " "
}

struct UIIcons {
    static let addIcon = "plus"
    static let copy = "doc.on.doc"
    static let trashIcon = "trash"
    static let basePlan = "list.bullet"
    static let posts = "tray"
    static let published = "checkmark.seal.text.page"
    static let download = "square.and.arrow.down"
    static let edit = "pencil.circle"
    static let calendar = "calendar.badge.plus"
    static let changeIcon = "arrow.triangle.2.circlepath"
    static let x = "xmark"
    static let save = "square.and.arrow.down"
}

extension Image {
    func defaultIconStyle() -> some View {
        self
            .font(.system(size: 20))
            .foregroundStyle(.white)
            .padding(12)
            .background(.ultraThinMaterial, in: Circle())
    }
}




