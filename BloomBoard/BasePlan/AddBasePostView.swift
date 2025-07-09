//
//  AddBasePostView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 7/9/25.
//

import SwiftUI

struct AddBasePostView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedPlatform: SocialMediaPlatform = .Youtube
    @State private var selectedPostType: PostType = .LongFormVideo
    @State private var selectedDay: Day = .Sunday
    
    var body: some View {
        NavigationStack {
            Form {
                Picker(UIStrings.platformString.rawValue, selection: $selectedPlatform) {
                    ForEach(SocialMediaPlatform.allCases, id: \.self) { platform in
                        Text(platform.rawValue)
                    }
                }
                
                Picker(UIStrings.postType.rawValue, selection: $selectedPostType) {
                    ForEach(PostType.allCases, id: \.self) { platform in
                        Text(platform.rawValue)
                    }
                }
                
                Picker(UIStrings.day.rawValue, selection: $selectedDay) {
                    ForEach(Day.allCases, id: \.self) { platform in
                        Text(platform.rawValue)
                    }
                }
            }
            .scrollDisabled(true)
            .navigationTitle(UIStrings.addBasePost.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text(UIStrings.cancelString.rawValue)
                            .foregroundStyle(.white)
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        
                    } label: {
                        Text(UIStrings.saveString.rawValue)
                            .foregroundStyle(.white)
                    }
                }
            }
        }
    }
}

#Preview {
    AddBasePostView()
}
