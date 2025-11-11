//
//  PostView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 7/18/25.
//
import SwiftUI

// MARK: PostDetailView
struct PostDetailView: View {
    @State private var postProperties: PostProperties
    @State private var postPerformance: Performance
    @Environment(\.dismiss) var dismiss
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
        _postProperties = State(initialValue: PostProperties())
        _postPerformance = State(initialValue: post.performance ?? Performance.unrated)
    }
    
    var body: some View {
        // MARK: Main View
        VStack{
            Text(post.title)
                .foregroundStyle(.text)
                .padding(5)
                .bold()
            
            PostDateView(
                postPerformance: $postPerformance, post: post,
            )
            
            UIImageView(
                loadedImage: loadedImage,
            )
            
            if(isPosted) {
                SocialMediaSummary(post: post)
            }
            
            PostUnPostButton(
                isPosted: isPosted
            )
            
            
            Text(postProperties.userFeedback ?? "")
                .defaultMessageStyle()
                .animation(.easeInOut, value: postProperties.userFeedback)
            
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            PostDetailToolbar(post: post)
        }
        //MARK: Sheets
        .sheet(isPresented: $postProperties.showPostDateSheet) {
            SelectPostDate(initialDate: postProperties.selectedPostDate) { date in
                postProperties.selectedPostDate = date
            }
            .presentationDetents([.fraction(0.75)])
        }
        .sheet(isPresented: $postProperties.showEditPostSheet) {
            PostEditorView(post: post)
                .presentationDetents([.fraction(0.60)])
        }
        .sheet(isPresented: $postProperties.showSocialMediaSheet) {
            SocialMediaChecklist(post: post)
                .presentationDetents([.fraction(0.60)])
        }
        .sheet(isPresented: $postProperties.showPostSheet) {
            PostSheet(post: post) { didPost in
                if didPost {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $postProperties.showUnPostSheet){
            UnPostSheet(post: post) { didUnpost in
                if didUnpost {
                    dismiss()
                }
            }
            .presentationDetents([.fraction(0.50)])
        }
        .environment(postProperties)
    }
}

// MARK: Post Properties
@Observable
class PostProperties {
    var showEditPostSheet = false
    var showPostDateSheet = false
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
    @Environment(PostProperties.self) var postProperties
    @Binding var postPerformance: Performance
    
    let post: Post
    
    var body: some View {
        VStack {
            if let postDate = post.postDate {
                Text("\(UIStrings.posted)\(postDate, style: .date)")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                
                
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
                Button {
                    postProperties.showPostDateSheet.toggle()
                } label : {
                    Label("\(UIStrings.postDate)\(postProperties.selectedPostDate, style: .date)", systemImage: UIIcons.calendar)
                        .foregroundStyle(.text)
                        .padding()
                }
            }
        }
    }
}

// MARK: Select Post Date
struct SelectPostDate: View {
    var initialDate: Date
    let onSave: (Date) -> Void
    
    @State private var selectedDate: Date
    @Environment(\.dismiss) var dismiss
    
    init(initialDate: Date, onSave: @escaping (Date) -> Void) {
        self.initialDate = initialDate
        self.onSave = onSave
        _selectedDate = State(initialValue: initialDate)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    UIStrings.posted,
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
            }
            .navigationTitle(UIStrings.selectPostDate)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: UIIcons.cancel)
                    }
                    
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onSave(selectedDate)
                        dismiss()
                    } label: {
                        Image(systemName: UIIcons.save)
                    }
                }
            }
        }
    }
}


//MARK: UI Image View
private struct UIImageView: View {
    @Environment(PostProperties.self) var postProperties
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
                    
                    postProperties.showFeedback(message: FeedbackMessages.downloadSucceeded)
                    
                } label: {
                    Image(systemName: UIIcons.download)
                        .defaultIconStyle()
                }
            }
            .frame(maxHeight: 250)
        } else {
            Button {
                postProperties.showEditPostSheet.toggle()
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
    @Environment(PostProperties.self) var postProperties
    let post: Post
    
    var body: some View {
        Button {
            postProperties.showSocialMediaSheet.toggle()
        } label: {
            Label(summaryText, systemImage: UIIcons.socialMedia)
                .font(.system(size: 14))
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
    @Environment(PostProperties.self) var postProperties
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
private struct PostUnPostButton: View {
    @Environment(PostProperties.self) var postProperties
    
    let isPosted: Bool
    
    var body: some View {
        Button {
            if isPosted {
                postProperties.showUnPostSheet.toggle()
            } else {
                postProperties.showPostSheet.toggle()
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
    @Environment(PostProperties.self) var postProperties
   
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
                        postProperties.showUnPostSheet.toggle()
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
    @Environment(PostProperties.self) var postProperties
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
                        postProperties.showPostSheet.toggle()
                    } label: {
                        Image(systemName: UIIcons.cancel)
                            .foregroundStyle(.text)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        post.postDate = postProperties.selectedPostDate
                        post.performance = .unrated
                        
                        post.socialMedias = [selectedMedia]
                        
                        postProperties.showPostSheet.toggle()
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
    @Environment(PostProperties.self) var postProperties
    
    let post: Post
    
    var body: some ToolbarContent {
        ToolbarItem {
            Button(UIStrings.copy, systemImage: UIIcons.copy) {
                UIPasteboard.general.string = post.title
                postProperties.showFeedback(message: FeedbackMessages.copySucceeded)
            }
        }
        
        if #available(iOS 26.0, *) {
            ToolbarSpacer(.fixed)
        }
        
        ToolbarItem {
            Button(UIStrings.edit, systemImage: UIIcons.edit) {
                postProperties.showEditPostSheet.toggle()
                
            }
        }
    }
}

