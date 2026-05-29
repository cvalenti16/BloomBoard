//
//  SettingsView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 12/15/25.
//

import SwiftUI
import SwiftData
import CloudKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("selectedAppearance")
    private var selectedAppearance: Appearance = .dark
    
    @Query(
        filter: #Predicate<Post> { post in
            post.isAITrainingPost == true
        },
        sort: [SortDescriptor(\Post.creationDate, order: .reverse)]
    ) var aiTrainingPosts: [Post]
    
    @State private var iCloudStatus: String? = nil
    @State private var showAITrainingAlert = false
    @State private var postToRemoveAITraining: Post? = nil
    
    var body: some View {
        NavigationStack {
            List(aiTrainingPosts) { posts in
                PostItemView(post: posts) { post in
                    postToRemoveAITraining = post
                    showAITrainingAlert = true
                }
            }
            .overlay {
                if aiTrainingPosts.isEmpty {
                    ContentUnavailableView {
                        Label("No AI Training Posts \n 3 are needed", systemImage: "tray.fill")
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Text(iCloudStatus ?? "")
                    .defaultMessageStyle()
            }
            .alert("Remove post from AI Training?", isPresented: $showAITrainingAlert, actions: {
                Button("Confirm", role: .destructive) {
                    postToRemoveAITraining?.isAITrainingPost = false
                    postToRemoveAITraining = nil
                }
                
                Button("Cancel", role: .cancel) {
                    postToRemoveAITraining = nil
                }
            })
            .scrollDisabled(true)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: UIIcons.cancel)
                            .foregroundStyle(.text)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        switch selectedAppearance {
                        case .dark: selectedAppearance = .light
                        case .light: selectedAppearance = .dark
                        }
                    } label: {
                        Image(systemName: selectedAppearance == .dark ? UIIcons.moon : UIIcons.sun)
                            .symbolEffect(.bounce, value: selectedAppearance)
                    }
                }
            }
            .environment(\.colorScheme, selectedAppearance == .dark ? .dark : .light)
        }
        .task {
            iCloudStatus = await fetchICloudAvailability()
        }
    }
    
    func fetchICloudAvailability() async -> String {
        let status = try? await CKContainer.default().accountStatus()
        switch status {
        case .available: return "iCloud Sync Enabled"
        case .noAccount: return "Sign into iCloud in Settings to sync data"
        case .restricted: return "iCloud Restricted"
        case .couldNotDetermine: return "iCloud Undetermined"
        case .temporarilyUnavailable: return "iCloud Temporarily Unavailable"
        case .none: return "iCloud Unknown Error"
        @unknown default: return "iCloud Unknown Error"
        }
    }
}

#Preview {
    SettingsView()
}
