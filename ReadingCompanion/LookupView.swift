//
//  LookupView.swift
//  ReadingCompanion
//
//  Created by Jaiz Jeeson on 1/8/23.
//

import SwiftUI

struct LookupView: View {
    var bookInfoRetriever: BookInfoRetriever = BookInfoRetriever()
    @State private var books: String = ""
    @State private var information: String = "No information about request."
    
    
    var body: some View {
        Text(information)
        Text(books)
        
        Button(action: {() -> Void in
            self.books = "Retrieving book info..."
            let information = self.bookInfoRetriever.fetchBookInfo(completionHandler: { bookResults in
            self.books = "\(bookResults)"
        }, searchTerms: ["flowers"])
            self.information = information
        }) {
            Text("Get Information")
        }
        
        // Testing template code.
        Button {
            Task {
                let (data, response) = try await URLSession.shared.data(from: URL(string: "https://www.googleapis.com/books/v1/volumes?q=flowers")!)
                
                // Problem line!
                let decodedResponse = try? JSONDecoder().decode(APIResult.self, from: data)
                
            
                let httpResponse = response as? HTTPURLResponse
                self.information = "Response code - \(httpResponse?.statusCode ?? 0). Data - \(decodedResponse)."
            }
        } label: {
            Text("Fetch Joke")
        }
    }
}

struct LookupView_Previews: PreviewProvider {
    static var previews: some View {
        LookupView()
    }
}

struct Joke: Codable {
    let value: String
}

struct APIResult: Codable {
    var kind: String
    var items: [Book]
}

struct Book: Codable {
    let title: String
    let authors: [String]
}
