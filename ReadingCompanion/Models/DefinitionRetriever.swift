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
        guard let apiUrl: URL = URL(string: "https://dictionaryapi.com/api/v3/references/collegiate/json/test?key=de8d85cf-136a-4fcc-9e33-1ba010aaad6d") else {
            self.information = "Request failed because URL was invalid."
            return
        }
        
        self.information = "Sending request to the following URL - \(apiUrl.absoluteString)."
        
        self.information = "Awaiting response..."
        /// Make API call.
        let apiTask = URLSession.shared.dataTask(with: apiUrl) { (data: Data?, response: URLResponse?, error: Error?) in
            self.information = "Entered first completion handler."
            
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
                    do {
                        let deserializedData = try JSONSerialization.jsonObject(with: data)
                        self.information += " Something went wrong while decoding. Here's the deserialized data - \(deserializedData). "
                        return}
                    catch {
                        self.information += "Something went wrong while de-serializing. Here's the error - \(error)."
                    }
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
struct Word: Codable {
    let shortdef: [String]
    let hwi: String
    let def: String
}

struct HeadwordInformation: Codable {
    let hw: String
}
