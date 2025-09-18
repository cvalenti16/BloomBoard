//
//  PostView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 7/18/25.
//
import SwiftUI

struct PostDetailView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var postProperties: PostProperties
    @State private var postPerformance: Post.Performance
    
    var isPosted: Bool {
        return postProperties.post.postDate != nil
    }
    
    var loadedImage: UIImage? {
        guard let imageData = postProperties.post.image else { return nil }
        return UIImage(data: imageData)
    }
    
    init(post: Post) {
        _postProperties = State(initialValue: PostProperties(post: post))
        _postPerformance = State(initialValue: post.performance ?? Post.Performance.unrated)
    }
    
    var body: some View {
        VStack{
            Text(postProperties.post.title)
                .font(.title3)
                .foregroundStyle(.text)
                .padding(10)
            
            PostDateView(
                postPerformance: $postPerformance,
            )
            .environment(postProperties)
            
            
            UIImageView(
                loadedImage: loadedImage,
            )
            .environment(postProperties)
            
            PostButton(
                isPosted: isPosted
            )
            .environment(postProperties)
            
            
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
        .environment(postProperties)
    }
}


// MARK: PostDate View
private struct PostDateView: View {
    @Environment(PostProperties.self) var postProperties
    @Binding var postPerformance: Post.Performance
    
    var body: some View {
        VStack {
            if let postDate = postProperties.post.postDate {
                Text("\(UIStrings.posted)\(Punctuation.colon)\(Punctuation.space)\(postDate, style: .date)")
                    .foregroundStyle(.secondary)
                
                
                Picker(UIStrings.performance, selection: $postPerformance) {
                    ForEach(Post.Performance.allCases, id: \.self) { performance in
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


// MARK: Post Button
private struct PostButton: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(PostProperties.self) var postProperties
    
    let isPosted: Bool
    
    var body: some View {
        Button {
            if isPosted {
                postProperties.post.postDate = nil
                postProperties.post.performance = nil
            } else {
                postProperties.post.postDate = postProperties.selectedPostDate
                postProperties.post.performance = .unrated
            }
            
            try? modelContext.save()
            dismiss()
            
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

@Observable
class PostProperties {
    var post: Post
    var showEditPostSheet = false
    var showPostDateSheet = false
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

#Preview {
    PostDetailView(post: Post.testPost)
        .preferredColorScheme(.dark)
}

