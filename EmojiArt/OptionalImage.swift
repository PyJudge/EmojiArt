//
//  OptionalImage.swift
//  EmojiArt
//
//  Created by Won Myeong Kwon on 2020/07/14.
//  Copyright © 2020 Won Myeong Kwon. All rights reserved.
//

import SwiftUI

struct OptionalImage: View {
    var uiimage : UIImage?
    var body: some View{
        Group {
            if uiimage != nil {
                Image(uiImage: uiimage!)
            }
        }
    }
}
