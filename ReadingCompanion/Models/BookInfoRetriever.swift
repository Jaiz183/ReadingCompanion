//
//  BookInfoRetriever.swift
//  ReadingCompanion
//
//  Created by Jaiz Jeeson on 1/8/23.
//

import Foundation
import SwiftUI
import OSLog

struct BookInfoRetriever {
    @Binding var information: String
    var defaultLogger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "network")
    
    func fetchBookInfo(completionHandler: @escaping ([Book]) -> Void, searchTerms: [String]) -> Void {
        
        defaultLogger.debug("Initializing URL...")
        self.information = "Initializing URL..."
        
        // Initialize URL.
        guard let apiUrl: URL = URL(string: "https://www.googleapis.com/books/v1/volumes?q=\(searchTerms.joined(separator: "+"))") else {
            self.information = "Request failed because URL was invalid."
            return
        }
        
        self.information = "Sending request to the following URL - \(apiUrl.absoluteString)."
        
        // Make API call.
        let apiTask = URLSession.shared.dataTask(with: apiUrl) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                print("This error occurred - \(error).")
                self.information = "Request failed because of \(error)."
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP response status code - \(httpResponse.statusCode).")
                self.information = "HTTP response status code - \(httpResponse.statusCode)."
            } else {
                print("Response was not an HTTP response. Here's the unaltered original - \(String(describing: response)).")
            }
            
            if let data = data {
                // Decode data.
                let decodedData: APIResult? = try? JSONDecoder().decode(APIResult.self, from: data)
                if let decodedData = decodedData {
                    completionHandler(decodedData.items)
                } else {
                    self.information += " Something went wrong while decoding."
                    return
                }
            } else {
                self.information += " No data could be retrieved."
            }
        }
        
        // Resume task.
        apiTask.resume()
        
        return
    }
}
