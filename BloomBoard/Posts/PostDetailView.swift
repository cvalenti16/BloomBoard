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

    var isPosted: Bool {
        return postProperties.post.postDate != nil
    }
    
    var loadedImage: UIImage? {
        guard let imageData = postProperties.post.image else { return nil }
        return UIImage(data: imageData)
    }
    
    init(post: Post) {
        _postProperties = State(initialValue: PostProperties(post: post))
        _postPerformance = State(initialValue: post.performance ?? Performance.unrated)
    }
    
    var body: some View {
        VStack{
            Text(postProperties.post.title)
                .foregroundStyle(.text)
                .padding(5)
                .bold()
            
            PostDateView(
                postPerformance: $postPerformance,
            )
            
            
            UIImageView(
                loadedImage: loadedImage,
            )
            
            if(isPosted) {
                SocialMediaSummary()
            }
            
            PostButton(
                isPosted: isPosted
            )
            
            
            Text(postProperties.userFeedback ?? "")
                .defaultMessageStyle()
                .animation(.easeInOut, value: postProperties.userFeedback)
            
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
                PostDetailToolbar()
        }
        .sheet(isPresented: $postProperties.showPostDateSheet) {
            SelectPostDate(initialDate: postProperties.selectedPostDate) { date in
                postProperties.selectedPostDate = date
            }
            .presentationDetents([.fraction(0.75)])

        }
        .sheet(isPresented: $postProperties.showEditPostSheet) {
            FormEditPost(post: postProperties.post)
                .presentationDetents([.fraction(0.60)])
        }
        .sheet(isPresented: $postProperties.showSocialMediaSheet) {
            SocialMediaChecklist()
                .presentationDetents([.fraction(0.60)])
        }
        .sheet(isPresented: $postProperties.showPostSheet, content: {
            PostSheet(showPostSheet: $postProperties.showPostSheet) { didPost in
                if didPost {
                    dismiss()
                }
                
            }
        })
        .postAlert(showUnPostAlert: $postProperties.showUnPostAlert, isPosted: isPosted)
        .environment(postProperties)
    }
}

// MARK: PostProperties
@Observable
class PostProperties {
    var post: Post
    var showEditPostSheet = false
    var showPostDateSheet = false
    var showUnPostAlert = false
    var showPostSheet = false
    var showSocialMediaSheet = false
    var selectedPostDate = Date()
    var userFeedback: String? = nil
    
    init(post: Post) {
        self.post = post
    }
    
    func showFeedback(message: String, duration: TimeInterval = 1) {
        userFeedback = message
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.userFeedback = nil
        }
    }
}


// MARK: PostDateView
private struct PostDateView: View {
    @Environment(PostProperties.self) var postProperties
    @Binding var postPerformance: Performance
    
    var body: some View {
        VStack {
            if let postDate = postProperties.post.postDate {
                Text("\(UIStrings.posted)\(postDate, style: .date)")
                    .foregroundStyle(.secondary)
                    .font(.system(size: 14))
                
                
                Picker(UIStrings.performance, selection: $postPerformance) {
                    ForEach(Performance.allCases, id: \.self) { performance in
                        Text(performance.rawValue).tag(performance)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 10)
                .onChange(of: postPerformance) { _, newValue in
                    postProperties.post.performance = newValue
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


//MARK: UIImageView
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
                
                HStack {
                    Button {
                        postProperties.showEditPostSheet.toggle()
                    } label: {
                        Image(systemName: UIIcons.changeIcon)
                            .defaultIconStyle()
                    }
                    
                    
                    Button {
                        UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
                        
                        postProperties.showFeedback(message: FeedbackMessages.downloadSucceeded)
                        
                    } label: {
                        Image(systemName: UIIcons.download)
                            .defaultIconStyle()
                    }
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


// MARK: SocialMediaSummary
private struct SocialMediaSummary: View {
    @Environment(PostProperties.self) var postProperties
    
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
        guard let medias = postProperties.post.socialMedias,
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
    
    var body: some View {
        NavigationStack {
            VStack {
                ForEach(SocialMedia.allCases.filter{$0 != .none}) { platform in
                    Toggle(platform.rawValue, isOn: Binding(
                        get: {
                            postProperties.post.socialMedias?.contains(platform) ?? false
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
        var current = postProperties.post.socialMedias ?? []
        
        if isOn {
            if !current.contains(platform) {
                current.append(platform)
            }
        } else {
            current.removeAll { $0 == platform }
        }
        
        postProperties.post.socialMedias = current
        try? modelContext.save()
    }
}

// MARK: Post Button
private struct PostButton: View {
    @Environment(PostProperties.self) var postProperties
    
    let isPosted: Bool
    
    var body: some View {
        Button {
            if isPosted {
                postProperties.showUnPostAlert.toggle()
            } else {
                postProperties.showPostSheet.toggle()
            }
            
        } label: {
            Text(isPosted ? UIStrings.unpost : UIStrings.post)
                .defaultButtonStyle()
        }
    }
}


//MARK: Toolbar
private struct PostDetailToolbar: ToolbarContent {
    @Environment(PostProperties.self) var postProperties
    
    var body: some ToolbarContent {
        ToolbarItem {
            Button(UIStrings.copy, systemImage: UIIcons.copy) {
                UIPasteboard.general.string = postProperties.post.title
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

// MARK: UnPost Alert
private struct UnPostAlert: ViewModifier {
    @AppStorage("defaultSocialMedia") private var defaultSocialMedia: SocialMedia = .none
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(PostProperties.self) var postProperties
    @Binding var showUnPostAlert: Bool
    let isPosted: Bool
    
    func body(content: Content) -> some View {
        content
            .alert(isPosted ? UIStrings.confirmUnpost : UIStrings.confirmPost,
                   isPresented: $showUnPostAlert) {
                Button(UIStrings.confirm) {
                    if isPosted {
                        postProperties.post.postDate = nil
                        postProperties.post.performance = nil
                        postProperties.post.socialMedias = nil
                    } else {
                        postProperties.post.postDate = postProperties.selectedPostDate
                        postProperties.post.performance = .unrated
                        
                        if defaultSocialMedia != .none {
                            postProperties.post.socialMedias = [defaultSocialMedia]
                        }
                    }
                    try? modelContext.save()
                    dismiss()
                }
                
                Button(UIStrings.cancel, role: .cancel) {
                    showUnPostAlert.toggle()
                }
            }
    }
}

// MARK: Post Sheet
private struct PostSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) var modelContext
    @Environment(PostProperties.self) var postProperties
    @State private var selectedMedia: SocialMedia = .facebook
    @Binding var showPostSheet: Bool

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
                
                Button {
                    
                    postProperties.post.postDate = postProperties.selectedPostDate
                    postProperties.post.performance = .unrated

                    postProperties.post.socialMedias = [selectedMedia]

                    postProperties.showPostSheet = false
                     postProperties.showSocialMediaSheet = false
                     postProperties.showPostDateSheet = false
                     postProperties.showEditPostSheet = false
                     
                    dismiss()
                    
                    didPost(true)
                } label: {
                    Text(UIStrings.post)
                        .defaultButtonStyle()
                }
            }
            .navigationTitle(UIStrings.selectPlatform)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        didPost(false)
                        dismiss()
                    } label: {
                        Image(systemName: UIIcons.cancel)
                            .foregroundStyle(.text)
                    }
                }
                
//                ToolbarItem(placement: .topBarTrailing) {
//                    Button {
//                        
//                    } label: {
//                        Image(systemName: UIIcons.published)
//                            .foregroundStyle(.text)
//                    }
//                }
            }
        }
    }
}

private extension View {
    func postAlert(showUnPostAlert: Binding<Bool>, isPosted: Bool) -> some View { self.modifier(
        UnPostAlert(
            showUnPostAlert: showUnPostAlert,
            isPosted: isPosted
        ))
    }
}

