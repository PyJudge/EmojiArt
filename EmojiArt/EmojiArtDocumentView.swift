//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Won Myeong Kwon on 2020/07/14.
//  Copyright © 2020 Won Myeong Kwon. All rights reserved.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document : EmojiArtDocument
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) { // Making it horizontally scrollable
                HStack {
                    ForEach(EmojiArtDocument.palette.map { String ($0) }, id: \.self) { emoji in
                        Text(emoji)
                            .font(Font.system(size: self.defaultEmojiSize))
                            .onDrag{ NSItemProvider(object: emoji as NSString) }
                    }
                }
            }
                .padding(.horizontal)
            
            GeometryReader { geometry in
                ZStack{
                    Color.white.overlay(
                        OptionalImage(uiimage: self.document.backgroundImage)
                            .scaleEffect(self.zoomScale)
                    )
                            .gesture(self.doubleTapGesture(in: geometry.size))
                    ForEach(self.document.emojis) { emoji in
                        Text(emoji.text)
                            .font(animatableWithSize: emoji.fontSize * self.zoomScale)
                            .position(self.position(for: emoji, in: geometry.size))
                    }
                }
                    .clipped()
                    .gesture(self.zoomGesture())
                    .edgesIgnoringSafeArea([.bottom, .horizontal])
                    .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                        var location = geometry.convert(location, from: .global) // geometry.convert already implemented by the prof, because onDrop location is on the global coordinate, having to be converted!
                        location = CGPoint(x: location.x - geometry.size.width / 2, y: location.y - geometry.size.height / 2) // location offsetting to the center
                        location = CGPoint(x: location.x / self.zoomScale, y: location.y / self.zoomScale) // apply zoomScale
                        return self.drop(providers: providers, at: location)
                    }
            }
        }
    }

    @State private var steadyStateZoomScale : CGFloat = 1.0
    @GestureState private var gestureZoomScale : CGFloat = 1.0
    private var zoomScale: CGFloat {
        let value = steadyStateZoomScale * gestureZoomScale
        print("steady \(steadyStateZoomScale) gesture \(gestureZoomScale) multiply \(value)")
        return value
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, _ in
                gestureZoomScale = latestGestureScale

        }
            .onEnded{ finalGestureScale in
                self.steadyStateZoomScale *= finalGestureScale
        }
    }
    
    private func zoomToFit(_ image : UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0  {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            self.steadyStateZoomScale = min (hZoom, vZoom) // always full!
        }
    }
    
    private func doubleTapGesture(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation{
                    self.zoomToFit(self.document.backgroundImage, in: size)
                }
        }
    }
    private func font (for emoji: EmojiArt.Emoji) -> Font {
        Font.system(size: emoji.fontSize * zoomScale) // apply zoomScale
    }
    
    private func position (for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        var location = emoji.location
        location = CGPoint(x: zoomScale * location.x, y: location.y * zoomScale) // apply zoomScale
        location = CGPoint(x: location.x + size.width / 2 , y: location.y + size.height / 2)
        return location
    }
    
    
    private func drop(providers : [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            print("dropped \(url)")
            self.document.setBackgroundURL(url)
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                self.document.addEmoji(string, at: location, size: self.defaultEmojiSize)
            }
        }
        return found
    }
    
    private let defaultEmojiSize: CGFloat = 40
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document : EmojiArtDocument())
    }
}

