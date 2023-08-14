//
//  LookupView.swift
//  ReadingCompanion
//
//  Created by Jaiz Jeeson on 1/8/23.
//

import SwiftUI
import Foundation

struct LookupView: View {
    @State private var isBookDataDisplayed: Bool = false
    @State private var books: [Book] = []
    @State private var information: String = "No information about request."
    @State private var searchTerms: String = "isbn:0716604892"
    
    
    
    var body: some View {
            VStack {
                TextField("Book Name", text: self.$searchTerms)
                    .disableAutocorrection(true)
                    .frame(width: 240)
                    .textFieldStyle(.roundedBorder)
                
                Button {
                    let bookInfoRetriever = BookInfoRetriever(information: self.$information)
                    bookInfoRetriever.fetchBookInfo(completionHandler: { books in
                        self.books = books
                    }, searchTerms: [self.searchTerms])
                    self.isBookDataDisplayed = true
                } label: {
                    Text("Search")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Divider()
                
                Text(information)
                self.isBookDataDisplayed ? Text("Found \(self.books.count) results.") : Text("Search something!")
                
            }
        .fullScreenCover(isPresented: self.$isBookDataDisplayed) {
            NavigationStack {
                List(self.books) { book in
                    NavigationLink {
                        BookInfo(title: book.volumeInfo.title, subtitle: book.volumeInfo.subtitle, authors: book.volumeInfo.authors)
                    } label: {
                        Text(book.volumeInfo.title)
                    }

                }
            }
            Button(action: {() -> Void in self.isBookDataDisplayed = false}) {
                Text("Close")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
}

/*
 Format of data:
    - JSON object mapping from String to String / [Dictionary<String, Any>]
 
 Decodable struct:
    - APIResult struct with items attribute mapped to [Book]
    - Book struct with id, other attributes mapped to String
    - Book attributes:
    - etag
    - selfLink
    - volumeInfo (JSON object containing title, authors, etc.)
    - accessInfo (JSON object with information about level of access, etc.)
    - kind
*/

struct APIResult: Codable {
    var items: [Book]
}

struct Book: Codable, Identifiable {
    let etag: String
    let selfLink: String
    let id: String
    let volumeInfo: VolumeInfo
    let kind: String
}


struct VolumeInfo: Codable {
    let title: String
    let subtitle: String
    let authors: [String]
}
