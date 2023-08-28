//
//  WordDifficultyComputer.swift
//  ReadingCompanion
//
//  Created by Jaiz Jeeson on 27/8/23.
//

import Foundation

class WordDifficultyComputer {
    /// Array of easy words from data set. Turn into set if you decide to disregard ranking.
    private var easyWords: Set<String>
    
    private let csvFilePath: String?
    
    /// Number of easy words to keep. Higher the threshold, the more difficult words have to be for them to be displayed.
    private var threshold: Int
    
    init(threshold: Int) {
        self.threshold = threshold
        let csvFile = "word_frequencies"
        
        self.easyWords = []
        if let csvFilePath = Bundle.main.path(forResource: csvFile, ofType: "csv") {
            self.csvFilePath = csvFilePath
        } else {
            self.csvFilePath = nil
            print("Error - file not found.")
            return
        }
        
        do {
            /// Doesn't work ALONE. Try optimizing by only reading a certain part of the file - look for a file iterable...
            let lines: [Substring] = try String(contentsOfFile: self.csvFilePath!).split(separator: "\n")
            
            /// Every word at and after threshold is disregarded.
            let selectedLines = lines[..<self.threshold]
            
            /// Skip header.
            for i in 1..<selectedLines.count {
                let easyWord = selectedLines[i].split(separator: ",")[0]
                easyWords.insert(String(easyWord))
            }
        }
        catch {
            print("Error - couldn't read file.")
            self.easyWords = []
        }
    }
    
    /**
     Parse CSV file with name csvFile to find easy words (up til threshold) and set instance attribute.
     
     - Parameter csvFile is the name of the CSV file to be parsed.
     - Parameter threshold represents level of difficulty to stop at. Higher thresholds lead to a higher number of difficult words. Decrease to increase word difficulty looked out for.
     */
    func parseCsvFile() throws -> Void {
        do {
            /// Doesn't work ALONE.
            let lines: [Substring] = try String(contentsOfFile: self.csvFilePath!).split(separator: "\n")
            
            /// Every word at and after threshold is disregarded.
            let selectedLines = lines[..<self.threshold]
            
            for selectedLine in selectedLines {
                let easyWord = selectedLine.split(separator: ",")[0]
                easyWords.insert(String(easyWord))
            }
        }
        catch {
            print("Error - couldn't read file.")
            self.easyWords = []
        }
    }
    
    /**
     Parse CSV file with name csvFile to find easy words (up til threshold).
     
     - Parameter recognizedWords are the words to be filtered.
     - Returns difficult words based on pre-set threshold.
     */
    func findDifficultWords(recognizedWords: [String]) -> [String] {
        /// Just filter instead.
//        var difficultWords: [String] = []
//
//        for recognizedWord in recognizedWords {
//            /// If a word is not easy, it is either difficult and in data set or so esoteric that it's not in the data set!
//            if (!easyWords.contains(recognizedWord)) {
//                difficultWords.append(recognizedWord)
//            }
//        }
//        return difficultWords + easyWords
        
        /// If a word is not easy, it is either difficult and in data set or so esoteric that it's not in the data set!
        return recognizedWords.filter({ recognizedWord in
            !easyWords.contains(recognizedWord)
        })
    }
    
    func getEasyWords() -> Set<String> {
        return self.easyWords
    }
}
