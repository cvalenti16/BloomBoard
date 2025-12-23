//
//  PostSuggestor.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 12/11/25.
//

import SwiftUI
import Observation
import SwiftData
import FirebaseAILogic

enum FetchStatus {
    case notStarted
    case fetching
    case success
    case failed
}

@Observable
@MainActor
final class TitleSuggestor {
    private(set) var titles: [String]?
    private(set) var titlesStatus: FetchStatus = .notStarted
    
    private let ai: FirebaseAI
    private let model: GenerativeModel
    
    init() {
        self.ai = FirebaseAI.firebaseAI(backend: .googleAI())
        self.model = ai.generativeModel(modelName: "gemini-2.5-flash")
    }
    
    func generateTitle(_ posts: [Post]) async {
        titlesStatus = .fetching
        let recentTitles = posts.map { "- \($0.title)" }.joined(separator: "\n")
        
        let prompt = """
        You are helping write new social media post titles for this user.
        Here are all the published posts they have:

        \(recentTitles)

        Constraints:
        - Match the tone and voice of the user
        - The size of the titles should related
        - Output exactly three lines, one title per line, no numbering or bullets
        - Avoid repeating the exact titles above
        - Keep it related to what the user has posted; no quotes or emojis
        """
        
        do {
            let response = try await model.generateContent(prompt)
            let lines = response.text?
                .components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                ?? []
            
            let suggestions = Array(lines.prefix(3))

            self.titles = suggestions.isEmpty ? nil : suggestions
            titlesStatus = .success
            
        } catch {
            titlesStatus = .failed
            self.titles = nil
            
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(2))
                titlesStatus = .notStarted
            }
        }
    }
}



/*
import SwiftUI
import SwiftData
import PhotosUI
import FirebaseAILogic

enum EditorMode {
    case creating
    case editing(Post)
}

struct PostEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query(filter: #Predicate<Post> {$0.postDate != nil},
        sort: [
            SortDescriptor(\Post.postDate, order: .reverse)
        ]) var publishedPosts: [Post]
    
    @State private var title: String = ""
    @State private var imageState: ImageState
    @State private var titleSuggestor: TitleSuggestor?
    
    let mode: EditorMode
    var navigationTitle: String {
        switch mode {
        case .creating:
            return UIStrings.createPost
        case .editing:
            return UIStrings.editPost
        }
    }
    
    private var canUseAI: Bool {
        if case .creating = mode, publishedPosts.count >= 10 {
            return true
        }
        return false
    }
    
    init(mode: EditorMode) {
        self.mode = mode
        let imageState = ImageState()
        
        switch mode {
        case .creating:
            _title = State(initialValue: "")
            
        case .editing(let post):
            _title = State(initialValue: post.title)
            if let data = post.image {
                imageState.postImage = UIImage(data: data)
            }
        }
        _imageState = State(initialValue: imageState)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField(UIStrings.title, text: $title, axis: .vertical)
                    .padding(.horizontal)
                    .padding(.top)
                    .bold()
                
                Rectangle()
                    .foregroundStyle(.text)
                    .frame(height: 2)
                    .padding(.horizontal)
                
                ImagePickerView()
                    .environment(imageState)
                
                if canUseAI {
                    SuggestedTitlesView(
                        titleSuggestor: titleSuggestor,
                        publishedPosts: publishedPosts,
                        title: $title
                    )
                }
            }
            .navigationTitle(navigationTitle)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: UIIcons.cancel)
                    }
                }
                
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        switch mode {
                        case .creating:
                            return createPost()
                        case .editing:
                            return updatePost()
                        }
                        
                    } label: {
                        Image(systemName: UIIcons.save)
                            .foregroundStyle(.text)
                    }
                    .disabled(title.isEmpty)
                }
            }
            .task {
                if canUseAI {
                    titleSuggestor = TitleSuggestor()
                }
            }
        }
    }
    
    private func updatePost() {
        guard case .editing(let post) = mode else {
            return
        }
        
        post.title = title
        
        if imageState.imageWasChanged {
            post.image = imageState.postImage?.jpegData(compressionQuality: 0.9)
        }
        
        try? modelContext.save()
        dismiss()
    }
    
    private func createPost() {
        let newPost = Post(title: title)
        
        if let imageData = imageState.postImage?.jpegData(compressionQuality: 0.9) {
            newPost.image = imageData
        }
        modelContext.insert(newPost)
        try? modelContext.save()
        dismiss()
    }
}


@Observable
class ImageState {
    var selectedImage: PhotosPickerItem? = nil
    var postImage: UIImage? = nil
    var imageWasChanged = false
}

//MARK: ImagePickerView
struct ImagePickerView: View {
    @Environment(ImageState.self) var imageState

    var body: some View {
        @Bindable var imageState = imageState
        
        PhotosPicker(selection: $imageState.selectedImage, matching: .images, photoLibrary: .shared()) {
            if let image = imageState.postImage {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 220)
                        .clipShape(.rect(cornerRadius: 10))
                        .padding()
                    
                    HStack {
                        Image(systemName: UIIcons.change)
                            .defaultIconStyle()
                        
                        Button {
                            imageState.selectedImage = nil
                            imageState.postImage = nil
                            imageState.imageWasChanged = true
                        } label: {
                            Image(systemName: UIIcons.trash)
                                .defaultIconStyle()
                        }
                    }
                }
            } else {
                Text(UIStrings.uploadImage)
                    .defaultUploadImageStyle()
            }
        }
        .onChange(of: imageState.selectedImage) { _, newValue in
            Task {
                guard let data = try? await newValue?.loadTransferable(type: Data.self) else { return }
                
                await MainActor.run {
                    imageState.postImage = UIImage(data: data)
                    imageState.imageWasChanged = true
                }
            }
        }
    }
}

struct SuggestedTitlesView: View {
    let titleSuggestor: TitleSuggestor?
    let publishedPosts: [Post]
    @Binding var title: String
    
    var body: some View {
        VStack {
            switch titleSuggestor?.titlesStatus {
                
            case .fetching:
                Image(systemName: "sparkles")
                    .symbolEffect(.pulse)
                    .foregroundStyle(.text)
                
            case .success:
                if let titles = titleSuggestor?.titles {
                    VStack {
                        ForEach(titles, id: \.self) { title in
                            Button {
                                self.title = title
                            } label: {
                                Text(title)
                                    .defaultMessageStyle()
                            }
                        }
                        
                        Button {
                            Task {
                                await titleSuggestor?.generateTitle(publishedPosts)
                            }
                        } label: {
                            Label("Other titles", systemImage: "sparkles")
                        }
                        .padding(.horizontal)
                        .foregroundStyle(.text)
                        .font(.footnote)
                    }
                }
                
            case .failed:
                Text("Error generating titles, Please try again.")
                    .defaultMessageStyle()
                
            default:
                Button {
                    Task {
                        await titleSuggestor?.generateTitle(publishedPosts)
                    }
                } label: {
                    Label("Generate title ideas", systemImage: "sparkles")
                }
                .padding(.horizontal)
                .foregroundStyle(.text)
                .font(.subheadline)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 100)
    }
}

*/
