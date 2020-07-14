//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by Won Myeong Kwon on 2020/07/14.
//  Copyright © 2020 Won Myeong Kwon. All rights reserved.
//

import Foundation

struct EmojiArt {
    var backgroundURL : URL?
    var emojis = [Emoji] ()
    
    struct Emoji: Identifiable{
        let text: String
        var x: Int
        var y: Int // Be the center, regardless of iOS System Coordinate System which upper-left being the (0, 0). needs a converter
        var size : Int
        let id : Int // UUID() Unique
        fileprivate init(text : String, x: Int, y : Int, size: Int, id: Int){
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        } // To add Emoji, being only through addEmoji () is required(to sustain id unique). fileprivate! 
    }
    
    private var uniqueEmojiID = 0
    
    mutating func addEmoji(_ text: String, x: Int, y: Int, size: Int) {
        uniqueEmojiID += 1
        emojis.append(Emoji(text: text, x: x, y:y, size: size, id: uniqueEmojiID))
    }
}
