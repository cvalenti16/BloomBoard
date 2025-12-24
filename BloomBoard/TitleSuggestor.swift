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
    
    func generateTitles(_ posts: [Post], _ image: UIImage? = nil) async {
        titlesStatus = .fetching
        titles = nil
        let recentTitles = posts.map { "- \($0.title)" }.joined(separator: "\n")
        
        var prompt = """
        You are helping write a new social media post titles for this user.
        Here are all the published posts they have:

        \(recentTitles)
        
        
        
"""
        if image != nil {
            prompt += """
    The new post includes an image. Use the image as inspiration while keeping the user's tone and past topics in mind.
    
    """
        }
        
        prompt += """
        
        Constraints:
        - Match the tone and voice of the user
        - The size of the titles should related
        - Output exactly three lines, one title per line, no numbering or bullets
        - Avoid repeating the exact titles above
        - Keep it related to what the user has posted; no quotes or emojis
        """
        
        do {
            let response: GenerateContentResponse

            if let image {
                response = try await model.generateContent(prompt, image)
            } else {
                response = try await model.generateContent(prompt)
            }
            
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
