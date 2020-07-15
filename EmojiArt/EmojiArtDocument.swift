//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Won Myeong Kwon on 2020/07/14.
//  Copyright © 2020 Won Myeong Kwon. All rights reserved.
//

import SwiftUI

class EmojiArtDocument: ObservableObject {
    static var palette : String = "🍏🍐🍎🍕🍉🍟"
    @Published private(set) var backgroundImage : UIImage?
    
    @Published
    private var emojiArt: EmojiArt = EmojiArt() {
        didSet {
            print("json = \(emojiArt.json?.utf8 ?? "nil")") // to make Data a String
            UserDefaults.standard.set(emojiArt.json, forKey: EmojiArtDocument.Untitled) // .set knows how to deal with Optionals
        }
    } // Model
    
    static let Untitled = "EmojiArtDocument.Untitled" // let's be a good programmer :), compile time check
    
    init() {
        emojiArt = EmojiArt(json: UserDefaults.standard.data(forKey: EmojiArtDocument.Untitled)) ?? EmojiArt()
        fetchBackgroundImageData()
    }
    
    var emojis : [EmojiArt.Emoji]  { emojiArt.emojis } // read only version of emojiart.emoji
    // MARK: -- Intent(s)
    
    func addEmoji(_ emoji: String , at location: CGPoint, size: CGFloat){
        emojiArt.addEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArt.Emoji, by offset: CGSize){
        if let index = emojiArt.emojis.firstIndex(matching: emoji){
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArt.Emoji, by scale: CGFloat){
        if let index = emojiArt.emojis.firstIndex(matching: emoji){
            emojiArt.emojis[index].size = Int(
                (CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrEven))
        }
    }
    
    func setBackgroundURL(_ url: URL?){
        emojiArt.backgroundURL  = url?.imageURL
        fetchBackgroundImageData()
    }
    
    private func fetchBackgroundImageData() {
        backgroundImage = nil
        if let url = self.emojiArt.backgroundURL {
            DispatchQueue.global(qos: .userInitiated).async {
                if let imageData = try? Data(contentsOf: url){
                    DispatchQueue.main.async {
                        if url == self.emojiArt.backgroundURL{
                            self.backgroundImage = UIImage(data: imageData)
                        }
                    }
                }
            }
        }
    }
}

extension EmojiArt.Emoji {
    var fontSize: CGFloat { CGFloat (self.size) }
    var location: CGPoint { CGPoint (x: CGFloat(x), y: CGFloat(y))}
}
