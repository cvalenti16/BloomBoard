//
//  PostView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 7/18/25.
//
import SwiftUI

struct PostDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State private var postState: PostState
    @State private var postPerformance: Performance
    let post: Post
    
    var isPosted: Bool {
        return post.postDate != nil
    }
    
    var loadedImage: UIImage? {
        guard let imageData = post.image else { return nil }
        return UIImage(data: imageData)
    }
    
    init(post: Post) {
        self.post = post
        _postState = State(initialValue: PostState())
        _postPerformance = State(initialValue: post.performance ?? Performance.unrated)
    }
    
    var body: some View {
        VStack{
            Text(post.title)
                .font(.title3)
                .bold()
            
            PostDateView(postPerformance: $postPerformance, post: post)
            
            UIImageView(loadedImage: loadedImage)
            
            if(isPosted) {
                SocialMediaSummary(post: post)
            }
            
            PostButton(
                isPosted: isPosted
            )
            
            Text(postState.userFeedback ?? "")
                .defaultMessageStyle()
                .animation(.easeInOut, value: postState.userFeedback)
            
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            PostDetailToolbar(post: post)
        }
        //MARK: Sheets
        .sheet(isPresented: $postState.showEditPostSheet) {
            PostEditorView(post: post)
                .presentationDetents([.fraction(0.60)])
        }
        .sheet(isPresented: $postState.showSocialMediaSheet) {
            SocialMediaChecklist(post: post)
                .presentationDetents([.fraction(0.60)])
        }
        .sheet(isPresented: $postState.showPostSheet) {
            PostSheet(post: post) { didPost in
                if didPost {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $postState.showUnPostSheet){
            UnPostSheet(post: post) { didUnpost in
                if didUnpost {
                    dismiss()
                }
            }
            .presentationDetents([.fraction(0.50)])
        }
        .environment(postState)
    }
}

// MARK: Post Properties
@Observable
class PostState {
    var showEditPostSheet = false
    var showUnPostSheet = false
    var showPostSheet = false
    var showSocialMediaSheet = false
    var selectedPostDate = Date()
    var userFeedback: String? = nil
    
    func showFeedback(message: String, duration: TimeInterval = 1) {
        userFeedback = message
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.userFeedback = nil
        }
    }
}


// MARK: Post Date View
private struct PostDateView: View {
    @Environment(PostState.self) var postState
    @Binding var postPerformance: Performance
    
    let post: Post
    
    var body: some View {
        @Bindable var postState = postState
        
        VStack {
            if let postDate = post.postDate {
                Text("\(UIStrings.posted)\(postDate, style: .date)")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                    .padding()
                
                Picker(UIStrings.performance, selection: $postPerformance) {
                    ForEach(Performance.allCases, id: \.self) { performance in
                        Text(performance.rawValue).tag(performance)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 10)
                .onChange(of: postPerformance) { _, newValue in
                    post.performance = newValue
                }
            } else {
                HStack {
                    Image(systemName: "calendar")
                    
                    DatePicker(
                        "",
                        selection: $postState.selectedPostDate,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                }
            }
        }
    }
}

//MARK: UI Image View
private struct UIImageView: View {
    @Environment(PostState.self) var postState
    var loadedImage: UIImage?
    
    var body: some View {
        if let uiImage = loadedImage {
            ZStack {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(.rect(cornerRadius: 10))
                    .padding()
                
                Button {
                    UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
                    
                    postState.showFeedback(message: FeedbackMessages.downloadSucceeded)
                    
                } label: {
                    Image(systemName: UIIcons.download)
                        .defaultIconStyle()
                }
            }
            .frame(maxHeight: 250)
        } else {
            Button {
                postState.showEditPostSheet.toggle()
            } label: {
                Image(systemName: UIIcons.upload)
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, maxHeight: 200)
                    .background(.ultraThinMaterial)
                    .clipShape(.rect(cornerRadius: 10))
                    .padding(10)
            }
        }
    }
}


// MARK: Social Media Summary
private struct SocialMediaSummary: View {
    @Environment(PostState.self) var postState
    let post: Post
    
    var body: some View {
        Button {
            postState.showSocialMediaSheet.toggle()
        } label: {
            Label(summaryText, systemImage: UIIcons.socialMedia)
                .padding(.horizontal,10)
        }
    }
    
    private var summaryText: String {
        guard let medias = post.socialMedias,
              !medias.isEmpty else {
            return UIStrings.selectPlatforms
        }
        
        let names = medias.map { $0.shortName }.sorted()
        return UIStrings.postedOn + names.joined(separator: ", ")
    }
}


private struct SocialMediaChecklist: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    let post: Post
    
    
    var body: some View {
        NavigationStack {
            VStack {
                ForEach(SocialMedia.allCases.filter{$0 != .none}) { platform in
                    Toggle(platform.rawValue, isOn: Binding(
                        get: {
                            post.socialMedias?.contains(platform) ?? false
                        },
                        set: { isOn in
                            updateSocialMedias(for: platform, isOn: isOn)
                        }
                    ))
                    .padding(.horizontal, 10)
                    .scaleEffect(0.90)
                }
                
                Button {
                    dismiss()
                } label: {
                    Text(UIStrings.close)
                        .defaultButtonStyle()
                }
            }
            .navigationTitle(UIStrings.selectPlatform)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func updateSocialMedias(for platform: SocialMedia, isOn: Bool) {
        var current = post.socialMedias ?? []
        
        if isOn {
            if !current.contains(platform) {
                current.append(platform)
            }
        } else {
            current.removeAll { $0 == platform }
        }
        
        post.socialMedias = current
        try? modelContext.save()
    }
}

// MARK: Post/UnPost Button
private struct PostButton: View {
    @Environment(PostState.self) var postState
    
    let isPosted: Bool
    
    var body: some View {
        Button {
            if isPosted {
                postState.showUnPostSheet.toggle()
            } else {
                postState.showPostSheet.toggle()
            }
            
        } label: {
            Text(isPosted ? UIStrings.unpost : UIStrings.post)
                .defaultButtonStyle()
        }
    }
}

// MARK: UnPostSheet
private struct UnPostSheet: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(PostState.self) var postState
    
    let post: Post
    let didUnPost: (Bool) -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                Text(UIStrings.confirmUnpost)
                    .font(.title3)
                
                
                HStack {
                    Button {
                        didUnPost(false)
                        postState.showUnPostSheet.toggle()
                    } label: {
                        Text(UIStrings.cancel)
                            .defaultButtonStyle()
                    }
                    
                    Button {
                        post.postDate = nil
                        post.performance = nil
                        post.socialMedias = nil
                        try? modelContext.save()
                        didUnPost(true)
                        dismiss()
                    } label: {
                        Text(UIStrings.confirm)
                            .defaultButtonStyle()
                    }
                }
                
            }
        }
    }
}


// MARK: Post Sheet
private struct PostSheet: View {
    @Environment(\.modelContext) var modelContext
    @Environment(PostState.self) var postState
    @State private var selectedMedia: SocialMedia = .facebook
    let post: Post
    let didPost: (Bool) -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                List(SocialMedia.allCases.filter{$0 != .none}) { media in
                    Button {
                        selectedMedia = media
                    } label: {
                        HStack {
                            Text(media.rawValue)
                            Spacer()
                            if selectedMedia == media {
                                Image(systemName: UIIcons.checkmark)
                                    .foregroundStyle(.tint)
                            }
                        }
                    }
                }
                .scrollDisabled(true)
            }
            .navigationTitle(UIStrings.selectPlatform)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        didPost(false)
                        postState.showPostSheet.toggle()
                    } label: {
                        Image(systemName: UIIcons.cancel)
                            .foregroundStyle(.text)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        post.postDate = postState.selectedPostDate
                        post.performance = .unrated
                        
                        post.socialMedias = [selectedMedia]
                        
                        postState.showPostSheet.toggle()
                        didPost(true)
                    } label: {
                        Image(systemName: UIIcons.published)
                            .foregroundStyle(.text)
                    }
                }
            }
        }
    }
}

//MARK: Toolbar
private struct PostDetailToolbar: ToolbarContent {
    @Environment(PostState.self) var postState
    
    let post: Post
    
    var body: some ToolbarContent {
        ToolbarItem {
            Button(UIStrings.copy, systemImage: UIIcons.copy) {
                UIPasteboard.general.string = post.title
                postState.showFeedback(message: FeedbackMessages.copySucceeded)
            }
        }
        
        if #available(iOS 26.0, *) {
            ToolbarSpacer(.fixed)
        }
        
        ToolbarItem {
            Button(UIStrings.edit, systemImage: UIIcons.edit) {
                postState.showEditPostSheet.toggle()
                
            }
        }
    }
}

