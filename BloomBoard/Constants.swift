//
//  UIStrings.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 7/3/25.
//

import Foundation
import SwiftUI

// MARK: FeedbackMessages
struct FeedbackMessages {
    static let emptyTitle = "Please Enter a Title"
    static let savedFailed = "Failed to save, please try again"
    static let downloadSucceeded = "Downloaded"
}

// MARK: UIStrings
struct UIStrings {
    static let cancel = "Cancel"
    static let delete = "Delete"
    static let edit = "Edit"
    static let created = "Created "
    static let add = "Add"
    static let title = "Title"
    static let drafts = "Drafts"
    static let published = "Published"
    static let uploadImage = "Upload Image"
    static let createPost = "Create Post"
    static let editPost = "Edit Post"
    static let deletePost = "Delete Post?"
    static let unpublish = "Unpublish"
    static let post = "Post"
    static let posted = "Posted "
    static let repost = "Repost"
    static let noPublishedPosts = "No Published Posts"
    static let noUnpublishedPosts = "No Unpublished Posts"
    static let noDrafts = "No Draft Posts"
    static let allPublished = "All Published"
    static let navigationTitle = "%@ (%d)"
    static let draftPosts = "Draft Posts"
    static let performance = "Performance"
    static let selectPlatform = "Select Platform"
    static let notPostedOn = "Not Posted On"
    static let clear = "Clear"
    static let filter = "Filter"
}

// MARK: UIIcons
struct UIIcons {
    static let add = "plus"
    static let trash = "trash"
    static let posts = "tray"
    static let published = "paperplane.fill"
    static let download = "square.and.arrow.down"
    static let edit = "pencil"
    static let calendar = "calendar"
    static let changeIcon = "arrow.triangle.2.circlepath"
    static let cancel = "xmark"
    static let save = "square.and.arrow.down"
    static let moon = "moon.fill"
    static let sun = "sun.max"
    static let upload = "square.and.arrow.up"
    static let socialMedia = "network"
    static let checkmark = "checkmark"
    static let filter = "line.3.horizontal.decrease"
    static let photo = "photo.artframe"
    static let document = "document"
    static let posted = "seal.fill"
    static let unpublished = "arrow.uturn.left"
    static let portrait = "rectangle.dashed"
}

// MARK: Default Icon Style
extension Image {
    func defaultIconStyle() -> some View {
        self
            .foregroundStyle(.text)
            .padding(12)
            .background(.ultraThinMaterial, in: Circle())
    }
}

// MARK: Default Button Style
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

// MARK: Default Message Style
extension Text {
    func defaultMessageStyle() -> some View {
        self
            .font(.subheadline)
            .foregroundStyle(.text)
    }
}

// MARK: Default Upload Image Style
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




