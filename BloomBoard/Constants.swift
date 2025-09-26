//
//  UIStrings.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 7/3/25.
//

import Foundation
import SwiftUI

struct FeedbackMessages {
    static let emptyTitle = "Please a Enter Title"
    static let savedFailed = "Failed to save, please try again"
    static let copySucceeded = "Copied"
    static let downloadSucceeded = "Downloaded"
}

struct Punctuation {
    static let colon = ":"
    static let space = " "
}

struct UIStrings {
    static let cancel = "Cancel"
    static let save = "Save"
    static let delete = "Delete"
    static let edit = "Edit"
    static let created = "Created"
    static let copy = "Copy"
    static let add = "Add"
    static let close = "Close"
    static let title = "Title"
    static let drafts = "Drafts"
    static let published = "Published"
    static let uploadImage = "Upload Image"
    static let createPost = "Create Post"
    static let editPost = "Edit Post"
    static let deletePost = "Delete Post?"
    static let confirmUnpost = "Do you want to unpost?"
    static let confirmPost = "Do you want to post?"
    static let post = "Post"
    static let posted = "Posted: "
    static let selectPostDate = "Select Post Date"
    static let postDate = "Post Date"
    static let unpost = "Unpost"
    static let noPublishedPosts = "No Published Posts"
    static let noDrafts = "No Drafts"
    static let publishedPosts = "Published Posts"
    static let draftPosts = "Draft Posts"
    static let performance = "Performance"
    static let enterTitle = "Enter Title"
    static let postedOn = "Posted On: "
    static let selectPlatforms = "Select Platforms"
    static let platforms = "Platforms: "
    static let confirm = "Confirm"
    static let selectDefaultPlatform = "Select Default Platform"
    static let socialMediaPicker = "Social Media Picker"
}


struct UIIcons {
    static let addIcon = "plus"
    static let copy = "doc.on.doc"
    static let trashIcon = "trash"
    static let basePlan = "list.bullet"
    static let posts = "tray"
    static let published = "paperplane.fill"
    static let download = "square.and.arrow.down"
    static let edit = "pencil"
    static let calendar = "calendar.badge.plus"
    static let changeIcon = "arrow.triangle.2.circlepath"
    static let cancel = "xmark"
    static let save = "square.and.arrow.down"
    static let moon = "moon.fill"
    static let sun = "sun.max"
    static let upload = "square.and.arrow.up"
    static let socialMedia = "network"
    static let checkmark = "checkmark"
}

extension Image {
    func defaultIconStyle() -> some View {
        self
            .font(.system(size: 20))
            .foregroundStyle(.text)
            .padding(12)
            .background(.ultraThinMaterial, in: Circle())
    }
}

extension Text {
    func defaultButtonStyle() -> some View {
        self
            .font(.headline)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(.thinMaterial)
            .foregroundStyle(.text)
            .clipShape(.rect(cornerRadius: 10))
            .padding()
    }
}


extension Text {
    func defaultMessageStyle() -> some View {
        self
            .font(.system(size: 12))
            .foregroundStyle(.text)
    }
}

extension Text {
    func defaultUploadImageStyle() -> some View {
        self
            .foregroundStyle(.gray)
            .frame(maxWidth: .infinity, maxHeight: 200)
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 10))
            .padding(10)
    }
}




