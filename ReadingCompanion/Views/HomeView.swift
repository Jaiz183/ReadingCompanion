//
//  HomeView.swift
//  ReadingCompanion
//
//  Created by Jaiz Jeeson on 30/5/23.
//

import SwiftUI

let appName: String = "Reading Companion"

struct HomeView: View {
    private let textRecognizer: TextRecognizer
    private let wordDifficultyComputer: WordDifficultyComputer
    private let viewNames: Array<String> = ["Annotator", "Lookup"]
    
    init() {
        self.wordDifficultyComputer = .init(threshold: 5000)
        self.textRecognizer = .init(wordDiffcultyComputer: self.wordDifficultyComputer)
    }
    
    var body: some View {
        
        NavigationStack {
            List {
                NavigationLink {
                    AnnotatorView(textRecognizer: self.textRecognizer, wordDifficultyComputer: self.wordDifficultyComputer)
                } label: {
                    Label {
                        Text("Annotator")
                    } icon: {
                        Image(systemName: "note")
                    }
                }
                
                NavigationLink {
                    LookupView()
                } label: {
                    Label {
                        Text("Lookup")
                    } icon: {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
            .navigationTitle(Text(appName))
        }
        
//        NavigationSplitView {
//            Text("Annotator")
//        } detail: {
//            AnnotatorView()
//        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
