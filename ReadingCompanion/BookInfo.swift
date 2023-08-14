//
//  BookInfo.swift
//  ReadingCompanion
//
//  Created by Jaiz Jeeson on 11/8/23.
//

import SwiftUI

struct BookInfo: View {
    let title: String
    let subtitle: String
    let authors: [String]
    
    @State private var coverImage: UIImage? = UIImage(named: "default_image")
    
    var body: some View {
        VStack {
            Text(self.subtitle)
            Text(self.subtitle)
            ForEach(0..<self.authors.count) { index in
                Text(self.authors[index])
            }

        }
    }
}
