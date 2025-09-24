//
//  PostView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 7/18/25.
//
import SwiftUI

struct PostDetailView: View {
    @State private var postProperties: PostProperties
    @State private var postPerformance: Performance
    
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
            Group {
                PostDetailToolbar()
            }
        }
        .sheet(isPresented: $postProperties.showPostDateSheet) {
            SelectPostDate(initialDate: postProperties.selectedPostDate) { date in
                postProperties.selectedPostDate = date
            }
        }
        .sheet(isPresented: $postProperties.showEditPostSheet) {
            FormEditPost(post: postProperties.post)
                .presentationDetents([.fraction(0.60)])
        }
        .sheet(isPresented: $postProperties.showSocialMediaSheet) {
            SocialMediaChecklist()
                .presentationDetents([.fraction(0.60)])
        }
        .postAlert(showPostSheet: $postProperties.showPostSheet, isPosted: isPosted)
        .environment(postProperties)
    }
}

// MARK: PostProperties
@Observable
class PostProperties {
    var post: Post
    var showEditPostSheet = false
    var showPostDateSheet = false
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


// MARK: PostDate View
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
                    Label("\(UIStrings.postDate)\(Punctuation.colon)\(Punctuation.space)\(postProperties.selectedPostDate, style: .date)", systemImage: UIIcons.calendar)
                        .foregroundStyle(.text)
                        .padding()
                }
            }
        }
    }
}


//Mark: UIImageView
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


// MARK: Social Media
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
        
        let names = medias.map { $0.rawValue }.sorted()
        return UIStrings.postedOn + names.joined(separator: ", ")
    }
}


private struct SocialMediaChecklist: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Environment(PostProperties.self) var postProperties
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text(UIStrings.selectPlatforms)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 10)
            
            
            ForEach(SocialMedias.allCases, id: \.self) { platform in
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
    }
    
    private func updateSocialMedias(for platform: SocialMedias, isOn: Bool) {
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
            postProperties.showPostSheet.toggle()
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
            Button(UIStrings.editString, systemImage: UIIcons.edit) {
                postProperties.showEditPostSheet.toggle()
                
            }
        }
    }
}

// MARK: Post Alert
private struct PostAlert: ViewModifier {
    @AppStorage("defaultSocialMedia") private var defaultSocialMedia: SocialMedias = .none
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(PostProperties.self) var postProperties
    @Binding var showPostSheet: Bool
    let isPosted: Bool
    
    func body(content: Content) -> some View {
        content
            .alert(isPosted ? UIStrings.confirmUnpost : UIStrings.confirmPost,
                   isPresented: $showPostSheet) {
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
                
                Button(UIStrings.cancelString, role: .cancel) {
                    showPostSheet.toggle()
                }
            }
    }
}

private extension View {
    func postAlert(showPostSheet: Binding<Bool>, isPosted: Bool) -> some View { self.modifier(
        PostAlert(
            showPostSheet: showPostSheet,
            isPosted: isPosted
        ))
    }
}





#Preview {
    PostDetailView(post: Post.testPost)
        .preferredColorScheme(.dark)
}

