//
//  BookInfoRetriever.swift
//  ReadingCompanion
//
//  Created by Jaiz Jeeson on 1/8/23.
//

import Foundation

struct BookInfoRetriever {
    
    func fetchBookInfo(completionHandler: @escaping ([Book]) -> Void, searchTerms: [String]) -> String {
        var information: String = "No information about request available."
        
        // Initialize URL.
        guard let apiUrl: URL = URL(string: "https://www.googleapis.com/books/v1/volumes?q=\(searchTerms.joined(separator: "+"))") else {
            information += "Request failed because URL was invalid."
            return information
        }
        
        // Make API call.
        let apiTask = URLSession.shared.dataTask(with: apiUrl) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                print("This error occurred - \(error).")
                information += "Request failed because of \(error)."
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP response status code - \(httpResponse.statusCode).")
                information += "HTTP response status code - \(httpResponse.statusCode)."
            } else {
                print("Response was not an HTTP response. Here's the unaltered original - \(String(describing: response)).")
            }
            
            // Decode data.
            if let data = data, let result = try? JSONDecoder().decode(APIResult.self, from: data) {
                // Pass to completionHandler.
                completionHandler(result.items)
                information += "Request completed successfully."
            } else {
                print("No data could be retrieved.")
                information += "No data could be retrieved."
            }
        }
        
        // Resume task.
        apiTask.resume()
        
        return information
    }
}
