//
//  HomeView.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 7/2/25.
//

import SwiftUI
import SwiftData

struct BasePlanView: View {
    @Query var socialPosts: [SocialPost]
    @State private var showAddSheet = false
    
    var body: some View {
        
        NavigationStack {
            if (socialPosts.isEmpty) {
                VStack {
                    Text(UIStrings.basePlanEmpty)
                        .font(.title3)
                    
                    Button {
                        showAddSheet.toggle()
                    } label: {
                        Text(UIStrings.startString)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(.thinMaterial)
                            .foregroundStyle(.white)
                            .clipShape(.rect(cornerRadius: 10))
                            .padding()
                    }
                }
            } else {
                ScrollView {
                    ForEach(Day.allCases, id: \.self) { day in
                        BasePostListView(socialPost: socialPosts, day: day)
                    }
                }
                .scrollIndicators(.hidden)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showAddSheet.toggle()
                        } label: {
                            Image(systemName: UIIcons.addIcon)
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddBasePostView()
        }
    }
}

#Preview {
    BasePlanView()
}
