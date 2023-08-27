//
//  WordDifficultyComputer.swift
//  ReadingCompanion
//
//  Created by Jaiz Jeeson on 27/8/23.
//

import Foundation

class WordDifficultyComputer {
    /// Array of easy words from data set. Turn into set if you decided to disregard ranking.
    private var easyWords: [String]
    
    private let csvFile: String
    private var threshold: Int
    
    init(threshold: Int) {
        self.threshold = threshold
        self.csvFile = "word_frequencies.csv"
        
        do {
            self.easyWords = []
            let lines: [Substring] = try String(contentsOfFile: self.csvFile).split(separator: "\n")
            
            /// Every word at and after threshold is disregarded.
            let selectedLines = lines.dropLast(self.threshold)
            
            for selectedLine in selectedLines {
                let easyWord = selectedLine.split(separator: ",")[0]
                easyWords.append(String(easyWord))
            }
        }
        catch {
            self.easyWords = []
        }
    }
    
    /**
     Parse CSV file with name csvFile to find easy words (up til threshold) and set instance attribute.
     
     - Parameter csvFile is the name of the CSV file to be parsed.
     - Parameter threshold represents level of difficulty to stop at. Higher thresholds lead to a higher number of difficult words. Decrease to increase word difficulty looked out for.
     */
    func parseCsvFile() throws -> [String] {
        var easyWords: [String] = []
        let lines: [Substring] = try String(contentsOfFile: self.csvFile).split(separator: "\n")
        
        /// Every word at and after threshold is disregarded.
        let selectedLines = lines.dropLast(self.threshold)
        
        for selectedLine in selectedLines {
            let easyWord = selectedLine.split(separator: ",")[0]
            easyWords.append(String(easyWord))
        }
        
        return easyWords
    }
    
    /**
     Parse CSV file with name csvFile to find easy words (up til threshold).
     
     - Parameter recognizedWords are the words to be filtered.
     - Returns difficult words based on pre-set threshold.
     */
    func findDifficultWords(recognizedWords: [String]) -> [String] {
        var difficultWords: [String] = []
        
        for recognizedWord in recognizedWords {
            /// If a word is not easy, it is either difficult and in data set or so esoteric that it's not in the data set!
            if (!easyWords.contains(recognizedWord)) {
                difficultWords.append(recognizedWord)
            }
        }
        return difficultWords + easyWords
    }
}
