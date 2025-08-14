//
//  ImageService.swift
//  BloomBoard
//
//  Created by Carlos Valentin on 8/14/25.
//

import Foundation
import PhotosUI

@Observable
class ImageService {
    var errorMessage: String?
    
    @discardableResult
    func saveImage(_ data: Data, for post: Post) -> String? {
        let filename = filename(for: post.id)
        let url = fileURL(for: filename)
        
        do {
            try data.write(to: url, options: .atomic)
            return filename
        } catch {
            errorMessage = error.localizedDescription
            print("Error saving image:", error.localizedDescription)
            return nil
        }
    }
    
    func deleteImage(for post: Post) {
        guard let name = post.image else { return }
        
        do {
            try FileManager.default.removeItem(at: fileURL(for: name))
        } catch {
            errorMessage = error.localizedDescription
            print("Error deleting image:", error.localizedDescription)
        }
    }
    
    func loadImage(for post: Post) -> UIImage? {
        guard let name = post.image else { return nil }
        return UIImage(contentsOfFile: fileURL(for: name).path)
    }
    
    
    // MARK: Helper Functions
    
    private func fileURL(for filename: String) -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
    }
    
    
    private func filename(for postID: String) -> String {
        "\(postID).jpg"
    }
}
