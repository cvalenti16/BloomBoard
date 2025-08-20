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
    
    @State private var showEditSheet = false
    @State private var showPostDateSheet = false
    @State private var selectedPostDate = Date()
    @State private var postPerformance: Post.Performance
    
    let post: Post
    
    var isPosted: Bool {
        return post.postDate != nil
    }
    
    var loadedImage: UIImage? {
        guard let filename = post.image else { return nil }
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
        return UIImage(contentsOfFile: url.path)
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
                .padding()
                .contextMenu { // gives a copy option on long press
                    Button {
                        UIPasteboard.general.string = post.title
                    } label: {
                        Label(PostStrings.copy, systemImage: UIIcons.copy)
                    }
                    
                    Button {
                        
                    } label: {
                        Label(UIStrings.cancelString, systemImage: UIIcons.x)
                    }
                }
            
            if let postDate = post.postDate {
                Text("\(PostStrings.posted)\(Punctuation.colon)\(Punctuation.space)\(postDate, style: .date)")
                    .foregroundStyle(.secondary)
                    .padding()
                
                Picker(PostStrings.performance, selection: $postPerformance) {
                    ForEach(Post.Performance.allCases, id: \.self) { performance in
                        Text(performance.rawValue).tag(performance)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                .onChange(of: postPerformance) { oldValue, newValue in
                    post.performance = newValue
                }
                
            } else {
                Button {
                    showPostDateSheet.toggle()
                } label : {
                    Label("\(PostStrings.postDate)\(Punctuation.colon)\(Punctuation.space)\(selectedPostDate, style: .date)", systemImage: UIIcons.calendar)
                        .foregroundStyle(.text)
                        .padding()
                }
            }
            
            if let uiImage = loadedImage {
                ZStack {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(.rect(cornerRadius: 10))
                        .padding()
                    
                    HStack {
                        Button {
                            showEditSheet.toggle()
                        } label: {
                            Image(systemName: UIIcons.changeIcon)
                                .font(.system(size: 20))
                                .foregroundStyle(.white)
                                .padding(12)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                        
                        Button {
                            UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
                        } label: {
                            Image(systemName: UIIcons.download)
                                .font(.system(size: 20))
                                .foregroundStyle(.white)
                                .padding(12)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                    }
                }
                .frame(maxHeight: 250)
            }
            
            Button {
                if (isPosted) {
                    post.postDate = nil
                    post.performance = nil
                    dismiss()
                } else {
                    post.postDate = selectedPostDate
                    post.performance = .unrated
                    dismiss()
                }
            } label: {
                Text(isPosted ? PostStrings.unpost : PostStrings.post)
                    .defaultButtonStyle()
            }
            
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showEditSheet.toggle()
                } label: {
                    Image(systemName: UIIcons.edit)
                        .font(.system(size: 20))
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            AddPostSheet(postToEdit: post)
                .presentationDetents([.fraction(0.60)])
        }
        .sheet(isPresented: $showPostDateSheet) {
            SelectPostDate(initialDate: selectedPostDate) { date in
                selectedPostDate = date
            }
        }
    }
}

#Preview {
    PostDetailView(post: Post.testPost)
        .preferredColorScheme(.dark)
}
