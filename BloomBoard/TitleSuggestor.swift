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
    private(set) var title: String?
    private(set) var titlesStatus: FetchStatus = .notStarted
    
    private let ai: FirebaseAI
    private let model: GenerativeModel
    
    init() {
        self.ai = FirebaseAI.firebaseAI(backend: .googleAI())
        self.model = ai.generativeModel(modelName: "gemini-2.5-flash")
    }
    
    func generateTitles(_ posts: [Post], _ image: UIImage , _ title: String) async {
        titlesStatus = .fetching
        self.title = nil
        
        let recentTitles = posts.map {"- \($0.title)"}
            .joined(separator: "\n")
        
        let prompt = """
        You are helping improve a social media post title written by the user.

        Original title:
        \(title)

        The user has previously published these titles:
        \(recentTitles)

        The post includes an image. Use it as supporting context to better understand the title’s intent. Do not introduce new topics.
        
        Constraints:
        - Preserve the original meaning and intent
        - Match the user's tone and writing style
        - Keep the title length similar to their previous titles
        - Output exactly one improved variations
        - No emojis, quotes, numbering, or explanations
        - Improve clarity, flow, or impact without over-polishing
        """
        
        do {
            let response = try await model.generateContent(prompt, image)
            
            let title = response.text
//                .components(separatedBy: .newlines)
//                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
//                .filter { !$0.isEmpty }
            ?? ""
            
            
            self.title = title.isEmpty ? nil : title
            titlesStatus = .success
            
        } catch {
            titlesStatus = .failed
            self.title = nil
            
            Task { @MainActor in
                try? await Task.sleep(for: .seconds(2))
                titlesStatus = .notStarted
            }
        }
    }
}
