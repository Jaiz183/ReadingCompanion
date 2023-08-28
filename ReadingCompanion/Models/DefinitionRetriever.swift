//
//  WordDefinitionRetriever.swift
//  ReadingCompanion
//
//  Created by Jaiz Jeeson on 28/8/23.
//

import Foundation
import SwiftUI
import OSLog

struct DefinitionRetriever {
    @Binding var information: String
    
    func fetchDefinition(completionHandler: @escaping (Word) -> Void, word: String) -> Void {
        self.information = "Initializing URL..."
        
        /// Initialize URL.
        guard let apiUrl: URL = URL(string: "https://www.dictionaryapi.com/api/v3/references/collegiate/json/\(word)?key=your-api-key") else {
            self.information = "Request failed because URL was invalid."
            return
        }
        
        self.information = "Sending request to the following URL - \(apiUrl.absoluteString)."
        
        /// Make API call.
        let apiTask = URLSession.shared.dataTask(with: apiUrl) { (data: Data?, response: URLResponse?, error: Error?) in
            
            /// Completion handler.
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
                /// Decode data.
                let decodedData: Word? = try? JSONDecoder().decode(Word.self, from: data)
                if let decodedData = decodedData {
                    completionHandler(decodedData)
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

/*
 Structs for API response decoding.
 
 Format of data:
    - JSON object mapping from String to String / [Dictionary<String, Any>]
 
 Decodable struct:
    - Word:
        - def contains full data about the word's definition in different contexts
        - shortdef mapped to a list of defintions for top 3 senses (contexts in which homonyms are used), abridged version of definitions section
        - hwi mapped to HeadwordInformation, for identifying what the word is
    - HeadwordInformation with hw (headword).
*/
struct Word: Codable, Identifiable {
    let shortdef: [String]
    let hwi: HeadwordInformation
    let def: String
    let id: String
}

struct HeadwordInformation: Codable {
    let hw: String
}
