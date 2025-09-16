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
    
    @State private var showEditPostSheet = false
    @State private var showPostDateSheet = false
    @State private var selectedPostDate = Date()
    @State private var postPerformance: Post.Performance
    
    @State private var userFeedback: String? = nil
    
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
        _postPerformance = State(initialValue: post.performance ?? Post.Performance.unrated)
    }
    
    var body: some View {
        VStack{
            Text(post.title)
                .font(.title3)
                .foregroundStyle(.text)
                .padding(10)
            
            PostStatusView(
                postPerformance: $postPerformance,
                showPostDateSheet: $showPostDateSheet,
                selectedPostDate: $selectedPostDate,
                post: post
            )
            
            UIImageView(
                loadedImage: loadedImage,
                showEditPostSheet: $showEditPostSheet,
                userFeedback: $userFeedback
            )
            
            PostButton(
                selectedPostDate: $selectedPostDate,
                post: post,
                isPosted: isPosted
            )
            
            Text(userFeedback ?? "")
                .defaultMessageStyle()
                .animation(.easeInOut, value: userFeedback)
            
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    Button {
                        UIPasteboard.general.string = post.title
                        userFeedback = FeedbackMessages.copySucceeded
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            userFeedback = nil
                        }
                        
                    } label: {
                        Image(systemName: UIIcons.copy)
                    }
                    
                    Button {
                        showEditPostSheet.toggle()
                    } label: {
                        Image(systemName: UIIcons.edit)
                    }
                }
            }
        }
        .sheet(isPresented: $showPostDateSheet) {
            SelectPostDate(initialDate: selectedPostDate) { date in
                selectedPostDate = date
            }
        }
        .sheet(isPresented: $showEditPostSheet) {
            EditPostSheet(post: post)
                .presentationDetents([.fraction(0.60)])
        }
    }
}

private struct PostButton: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Binding var selectedPostDate: Date
    var post: Post
    let isPosted: Bool
    
    var body: some View {
        Button {
            if isPosted {
                post.postDate = nil
                post.performance = nil
            } else {
                post.postDate = selectedPostDate
                post.performance = .unrated
            }
            
            try? modelContext.save()
            dismiss()
        } label: {
            Text(isPosted ? PostStrings.unpost : PostStrings.post)
                .defaultButtonStyle()
        }
    }
}

private struct UIImageView: View {
    var loadedImage: UIImage?
    @Binding var showEditPostSheet: Bool
    @Binding var userFeedback: String?
    
    
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
                        showEditPostSheet.toggle()
                    } label: {
                        Image(systemName: UIIcons.changeIcon)
                            .defaultIconStyle()
                    }
                    
                    
                    Button {
                        UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
                        userFeedback = FeedbackMessages.downloadSucceeded
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            userFeedback = nil
                        }
                        
                    } label: {
                        Image(systemName: UIIcons.download)
                            .defaultIconStyle()
                    }
                }
            }
            .frame(maxHeight: 250)
        } else {
            Button {
                showEditPostSheet.toggle()
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, maxHeight: 200)
                    .background(.ultraThinMaterial)
                    .clipShape(.rect(cornerRadius: 10))
                    .padding(10)
            }
        }
    }
}

private struct PostStatusView: View {
    @Binding var postPerformance: Post.Performance
    @Binding var showPostDateSheet: Bool
    @Binding var selectedPostDate: Date
    var post: Post
    
    var body: some View {
        VStack {
            if let postDate = post.postDate {
                Text("\(PostStrings.posted)\(Punctuation.colon)\(Punctuation.space)\(postDate, style: .date)")
                    .foregroundStyle(.secondary)
                
                
                Picker(PostStrings.performance, selection: $postPerformance) {
                    ForEach(Post.Performance.allCases, id: \.self) { performance in
                        Text(performance.rawValue).tag(performance)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 10)
                .onChange(of: postPerformance) { oldValue, newValue in post.performance = newValue }
                
            } else {
                Button {
                    showPostDateSheet.toggle()
                } label : {
                    Label("\(PostStrings.postDate)\(Punctuation.colon)\(Punctuation.space)\(selectedPostDate, style: .date)", systemImage: UIIcons.calendar)
                        .foregroundStyle(.text)
                        .padding()
                }
            }
        }
    }
}


#Preview {
    PostDetailView(post: Post.testPost)
        .preferredColorScheme(.dark)
}

