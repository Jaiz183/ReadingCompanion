//
//  TextRecognitionModel.swift
//  ReadingCompanion
//
//  Created by Jaiz Jeeson on 10/6/23.
//

import Foundation
import Vision
import VisionKit
import NaturalLanguage


// Struct that manages asynchronous requests to Vision.
struct TextRecognitionModel {
    private let targetText: String = "Movies"
    
    /**
     Function that performs text recognition given an image.
     
     - Parameter cgImage: image with text to be recognized.
     - Returns a tuple of 2 - a String storing recognized text split into words and an array of CGRect bounding boxes.
     */
    func performTextRecognition(image: UIImage?) async throws -> (recognizedText: String, boundingBoxes: [CGRect]) {
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
                        
                        // Get bounding box for a specific word.
                        if let range = candidate.string.range(of: self.targetText) {
                            let boxObservation = try? candidate.boundingBox(for: range)
                            // Ensure bounding box for word is not null.
                            let boundingBox = boxObservation?.boundingBox ?? .zero
                            // Translate normalized coordinates to coordinates on scan / image.
                            let boundingRect = VNImageRectForNormalizedRect(boundingBox, Int(image!.size.width), Int(image!.size.height))
                            boundingRects.append(boundingRect)
                        }
                    }
                    
                    let recognizedWords = self.cleanRecognizedText(recognizedText: recognizedText)
                    let finalRecognizedText = recognizedWords.joined(separator: ", ") + "\n\(results.count) results."
                    
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
                    
                    continuation.resume(returning: (finalRecognizedText, boundingRects))
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
     Function that cleans up recognized text by separating words and rejecting names with NER.
     
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
        
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = recognizedText
        
        let options: NLTagger.Options = [.joinNames, .omitPunctuation, .omitWhitespace, .omitOther]
        let tags: [NLTag] = [.personalName, .placeName, .organizationName]
        tagger.enumerateTags(in: recognizedText.startIndex..<recognizedText.endIndex, unit: .word, scheme: .nameType, options: options) { tag, tokenRange in
            if let tag = tag, !tags.contains(tag) {
                tokensSoFar.append(String(recognizedText[tokenRange]))
                return true
            } else {
                return false
            }
        }
        
        return tokensSoFar
    }
    
    func getData() -> [String] {
        return []
    }
}


enum RequestErrors: LocalizedError {
    case unableToRetrieveImage
}
