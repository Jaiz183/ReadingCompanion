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
    
    
    var body: some View {
        ScrollView {
            VStack {
                Text(information)
                Text(String(describing: self.books))
                
                Button {
                    let bookInfoRetriever = BookInfoRetriever(information: self.$information)
                    bookInfoRetriever.fetchBookInfo(completionHandler: { books in
                        self.books = books
                    }, searchTerms: ["isbn:0716604892"])
                    self.isBookDataDisplayed = true
                } label: {
                    Text("Search")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                // Testing template code.
//                Button {
//                    Task {
//                        let (data, response) = try await URLSession.shared.data(from: URL(string: "https://www.googleapis.com/books/v1/volumes?q=isbn:0716604892")!)
//
//
//                        /*
//                         Format of data:
//                         - JSON object mapping from String to String / [Dictionary<String, Any>]
//
//                         Decodable struct:
//                         - APIResult struct with items attribute mapped to [Book]
//                         - Book struct with id, other attributes mapped to String
//                         - Book attributes:
//                            - etag
//                            - selfLink
//                            - volumeInfo (JSON object containing title, authors, etc.)
//                            - accessInfo (JSON object with information about level of access, etc.)
//                            - kind
//                         */
//
//                        // Serialization approach (but it's annoyingly hard.
//    //                    let decodedData = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any]
//    //                    var intermediateDecodedData = (decodedData?["items"] as? [Dictionary<String, Any>])?[0] ?? [:]
//    //                    var testDecodedData = intermediateDecodedData
//    //                    var testDecodedDataType = type(of: testDecodedData)
//
//                        let decodedData: APIResult? = try? JSONDecoder().decode(APIResult.self, from: data)
//
//                        let httpResponse = response as? HTTPURLResponse
//
//                        self.information = "Response code - \(httpResponse?.statusCode ?? 0). Data type - \(type(of: decodedData))."
//                        self.books = decodedData?.items ?? []
//                        self.isBookDataDisplayed = true
//                    }
//                } label: {
//                    Text("Search")
//                }
//                .buttonStyle(.borderedProminent)
//                .controlSize(.large)
            }
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

struct APIResult: Codable {
    var items: [Book]
}

struct Book: Codable, Identifiable {
    let etag: String
    let selfLink: String
    let id: String
    let volumeInfo: VolumeInfo
//    let accessInfo: String
    let kind: String
}


struct VolumeInfo: Codable {
    let title: String
    let subtitle: String
    let authors: [String]
}
