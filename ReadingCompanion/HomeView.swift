//
//  HomeView.swift
//  ReadingCompanion
//
//  Created by Jaiz Jeeson on 30/5/23.
//

import SwiftUI

let appName: String = "Reading Companion"

struct HomeView: View {
    private let views: Array<any View> = [AnnotatorView(), LookupView()]
    private let viewNames: Array<String> = ["Annotator", "Lookup"]
    
    var body: some View {
        
        NavigationStack {
            List {
                NavigationLink {
                    AnnotatorView()
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
