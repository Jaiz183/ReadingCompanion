//
//  TextRecognizer.swift
//  ReadingCompanion
//
//  Created by Jaiz Jeeson on 28/8/23.
//

import Foundation
import Vision
import VisionKit
import NaturalLanguage


// Manages asynchronous requests to Vision.
struct TextRecognizer {
    private let wordDifficultyComputer: WordDifficultyComputer
    
    init(wordDiffcultyComputer: WordDifficultyComputer) {
        self.wordDifficultyComputer = wordDiffcultyComputer
    }
    
    /**
     Performs text recognition given an image.
     
     - Parameter cgImage: image with text to be recognized.
     - Returns a tuple of 2 - a String storing recognized text split into words and an array of CGRect bounding boxes.
     */
    func performTextRecognition(image: UIImage?) async throws -> (recognizedWords: [String], boundingBoxes: [CGRect]) {
        guard let cgImage: CGImage = image?.cgImage else {throw RequestErrors.unableToRetrieveImage}
        let requestHandler: VNImageRequestHandler = VNImageRequestHandler(cgImage: cgImage)
        return try await withCheckedThrowingContinuation({ continuation in
            let recognizeTextRequest = VNRecognizeTextRequest(completionHandler: { request, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    let results = request.results as? [VNRecognizedTextObservation] ?? []
                    
                    var recognizedText: String = ""
                    var boundingRects: [CGRect] = []
                    let easyWords = self.wordDifficultyComputer.getEasyWords()
                    
                    for result in results {
                        // Returns array with 1 candidate at most and gets first element of that array
                        let candidate = result.topCandidates(1).first!
                        // Add space to separate conjoined words. Will be removed by tokenizer in self.cleanRecognizedText.
                        recognizedText += candidate.string + " "
                        
                        // Get bounding boxes for all results.
//                        if let range = candidate.string.range(of: candidate.string) {
//                            let boxObservation = try? candidate.boundingBox(for: range)
//                            let boundingBox = boxObservation?.boundingBox ?? .zero
//                            let boundingRect = VNImageRectForNormalizedRect(boundingBox, Int(image!.size.width), Int(image!.size.height))
//                            boundingRects.append(boundingRect)
//                        }
                        
                        // Get bounding boxes for all DIFFICULT results.
                        if (!easyWords.contains(candidate.string)) {
                            if let range = candidate.string.range(of: candidate.string) {
                                let boxObservation = try? candidate.boundingBox(for: range)
                                let boundingBox = boxObservation?.boundingBox ?? .zero
                                let boundingRect = VNImageRectForNormalizedRect(boundingBox, Int(image!.size.width), Int(image!.size.height))
                                boundingRects.append(boundingRect)
                            }}
                        
                        // Get bounding box for a specific word.
//                        if let range = candidate.string.range(of: self.targetText) {
//                            let boxObservation = try? candidate.boundingBox(for: range)
//                            // Ensure bounding box for word is not null.
//                            let boundingBox = boxObservation?.boundingBox ?? .zero
//                            // Translate normalized coordinates to coordinates on scan / image.
//                            let boundingRect = VNImageRectForNormalizedRect(boundingBox, Int(image!.size.width), Int(image!.size.height))
////                            let boundingRect = correctedBoundingBox(forRegionOfInterest: boundingBox, withinImageBounds: image!.imageRendererFormat.bounds)
//                            boundingRects.append(boundingRect)
//                        }
                    }
                    
                    let recognizedWords = self.cleanRecognizedText(recognizedText: recognizedText)
//                    let finalRecognizedText = recognizedWords.joined(separator: ", ") + "\n\(results.count) results."
                    
//                    let recognizedText: [String] = results.compactMap({result in result.topCandidates(1).first!.string})
//                    let boundingRects: [CGRect] = results.compactMap({result in
//                        guard let topCandidate = result.topCandidates(1).first else {return .zero}
//
//                        // Get string range.
//                        let stringRange = topCandidate.string.startIndex..<topCandidate.string.endIndex
//
//                        let boxObservation = try? topCandidate.boundingBox(for: stringRange)
//
//                            // Get the normalized CGRect value.
//                            let boundingBox = boxObservation?.boundingBox ?? .zero
//
//                            // Convert the rectangle from normalized coordinates to image coordinates.
//                            return VNImageRectForNormalizedRect(boundingBox,
//                                                                Int(image!.size.width),
//                                                                Int(image!.size.height))
//                        })
                    
                    continuation.resume(returning: (recognizedWords, boundingRects))
                }
            })
            
            recognizeTextRequest.recognitionLevel = .accurate
            recognizeTextRequest.usesLanguageCorrection = true
            
            do {
                try requestHandler.perform([recognizeTextRequest])
            } catch {
                continuation.resume(throwing: error)
            }
        })
    }
    
    /**
     Function that cleans up recognized text with tokenization, NER and other de-formatting.
     
     - Parameter recognizedText: recognized text to be cleaned.
     - Returns an array of cleaned text as words.
     */
    func cleanRecognizedText(recognizedText: String) -> [String] {
        var tokensSoFar: [String] = []
        
//        let tokenizer = NLTokenizer(unit: .word)
//        tokenizer.string = recognizedText
//
//        tokenizer.enumerateTokens(in: recognizedText.startIndex..<recognizedText.endIndex, using: {(tokenRange, _) -> Bool in
//            tokensSoFar.append(String(recognizedText[tokenRange]))
//            return true})
        
        /// Create tagger to reject names.
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = recognizedText
        
        /// Set options for tokenization.
        let options: NLTagger.Options = [.joinNames, .omitPunctuation, .omitWhitespace, .omitOther, .joinContractions]
        
        /// Set tags with name sub-types that we want to REJECT.
        let tags: [NLTag] = [.personalName, .placeName, .organizationName]
        
        /// Tokenize and get tags corresponding to each token. Add token if its tag is not in tags.
        tagger.enumerateTags(in: recognizedText.startIndex..<recognizedText.endIndex, unit: .word, scheme: .nameType, options: options) { tag, tokenRange in
            if let tag = tag, !tags.contains(tag) {
                let token = String(recognizedText[tokenRange]).lowercased()
                tokensSoFar.append(token)
                return true
            } else {
                return false
            }
        }
        
        return tokensSoFar
    }
    
    // Apple's sample function.
    fileprivate func correctedBoundingBox(forRegionOfInterest: CGRect, withinImageBounds bounds: CGRect) -> CGRect {
        
        let imageWidth = bounds.width
        let imageHeight = bounds.height
        
        // Begin with input rect.
        var rect = forRegionOfInterest
        
        // Reposition origin.
        rect.origin.x *= imageWidth
        rect.origin.x += bounds.origin.x
        rect.origin.y = (1 - rect.origin.y) * imageHeight + bounds.origin.y
        
        // Rescale normalized coordinates.
        rect.size.width *= imageWidth
        rect.size.height *= imageHeight
        
        return rect
    }
    
    func getData() -> [String] {
        return []
    }
}


enum RequestErrors: LocalizedError {
    case unableToRetrieveImage
}
