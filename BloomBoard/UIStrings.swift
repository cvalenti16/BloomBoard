//
//  UIStrings.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 7/3/25.
//

import Foundation
import SwiftUI

struct PostStrings {
    static let created = "Created"
    static let copy = "Copy"
    static let title = "Title"
    static let drafts = "Drafts"
    static let published = "Published"
    static let postString = "Posts"
    static let uploadImage = "Upload Image"
    static let createPost = "Create Post"
    static let editPost = "Edit Post"
    static let downloadImage = "Download Image"
    static let deletePost = "Delete Post?"
    static let edit = "Edit"
    static let post = "Post"
    static let posted = "Posted"
    static let selectPostDate = "Select Post Date"
    static let postDate = "Post Date"
    static let unpost = "Unpost"
    static let noPublishedPosts = "No Published Posts"
    static let noDrafts = "No Drafts"
    static let publishedPosts = "Published Posts"
    static let draftPosts = "Draft Posts"
    static let performance = "Performance"
}
struct errorMessages {
    static let emptyTitle = "Please Enter Title"
}
struct Punctuation {
    static let colon = ":"
    static let space = " "
}

struct UIStrings {
    static let cancelString = "Cancel"
    static let saveString = "Save"
    static let deleteString = "Delete"
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
    static let x = "xmark"
    static let save = "square.and.arrow.down"
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
    func defaultErrorStyle() -> some View {
        self
            .font(.system(size: 12))
            .foregroundStyle(.text)
            
    }
}




