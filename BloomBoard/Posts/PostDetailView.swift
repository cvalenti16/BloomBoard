//
//  PostView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 7/18/25.
//
import SwiftUI

struct PostDetailView: View {
    @State private var showEditSheet = false
    @State private var showPostDateSheet = false
    @State private var selectedPostDate = Date()
    
    let post: Post
    
    var loadedImage: UIImage? {
        guard let filename = post.image else { return nil }
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
        return UIImage(contentsOfFile: url.path)
    }
    
    var body: some View {
        VStack {
            Text(post.title)
                .font(.title3)
                .textSelection(.enabled)
            
            if let postDate = post.postDate {
                Text(postDate, format: .dateTime.day().month().year())
                    .font(.subheadline)
            }
            
            
            if let uiImage = loadedImage {
                ZStack {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(.rect(cornerRadius: 10))
                        .padding()
                        .frame(maxHeight: 300)
                    
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
            
            HStack {
                Button {
                    showEditSheet.toggle()
                } label: {
                    Text(PostStrings.edit)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(.rect(cornerRadius: 10))
                }
                
                Spacer()
                
                Button {
                    if post.postDate != nil {
                        post.postDate = nil
                    } else {
                        selectedPostDate = post.postDate ?? Date()
                        showPostDateSheet = true
                    }
                } label: {
                    Text(post.postDate == nil  ? PostStrings.post : PostStrings.unpost)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(.rect(cornerRadius: 10))
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
        }
        .sheet(isPresented: $showEditSheet) {
            AddPostView(postToEdit: post)
                .presentationDetents([.fraction(0.60)])
        }
        .sheet(isPresented: $showPostDateSheet) {
            VStack {
                Text(PostStrings.selectPostDate)
                    .font(.headline)
                
                DatePicker(
                    PostStrings.postedOn,
                    selection: $selectedPostDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                
                HStack {
                    Button(UIStrings.cancelString) { showPostDateSheet = false }
                    
                    Spacer()
                    
                    Button(UIStrings.saveString) {
                        post.postDate = selectedPostDate
                        showPostDateSheet = false
                    }
                }
                .padding(.horizontal)
            }
         
        }
    }
}

#Preview {
    PostDetailView(post: Post.testPost)
        .preferredColorScheme(.dark)
}
