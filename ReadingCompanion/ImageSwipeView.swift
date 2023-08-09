//
//  ImageSwipeView.swift
//  ReadingCompanion
//
//  Created by Jaiz Jeeson on 25/7/23.
//

import SwiftUI

struct ImageSwipeView: View {
    var images: [UIImage]
    @State var imageIndex: Int = 0
    
    init(images: [UIImage]) {
        self.images = images
    }
    
    var drag: some Gesture {
        DragGesture()
            .onEnded { dragGestureValue in
                let translation = dragGestureValue.location.x - dragGestureValue.startLocation.x
                
                // A left swipe swipes to image on right and vice versa. Therefore, negative translation means self.imageIndex increment.
                let isSwipeValid = (translation < 0 && self.imageIndex < self.images.count - 1) || (translation > 0 && self.imageIndex > 0)
                if translation < 0 && isSwipeValid {
                    self.imageIndex += 1}
                else if isSwipeValid {
                    self.imageIndex -= 1
                }
            }
    }
    
    var body: some View {
        Image(uiImage: self.images[self.imageIndex])
            .resizable()
            .scaledToFit()
            .gesture(drag)
    }
}

struct ImageSwipeView_Previews: PreviewProvider {
    static var previews: some View {
        ImageSwipeView(images: [UIImage(named: "default_image")!])
    }
}
