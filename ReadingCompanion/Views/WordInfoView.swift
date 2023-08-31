//
//  WordInfoView.swift
//  ReadingCompanion
//
//  Created by Jaiz Jeeson on 31/8/23.
//

import Foundation
import SwiftUI

struct WordInfoView: View {
    let word: String
    let definitions: [String]
    
    var body: some View {
        VStack {
            Text(self.word)
            ForEach(0..<self.definitions.count) { index in
                Text("\(index + 1). \(self.definitions[index])")
            }

        }
    }
}
