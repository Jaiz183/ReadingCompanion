//
//  AnnotatorView.swift
//  ReadingCompanion
//
//  Created by Jaiz Jeeson on 31/5/23.
//

import SwiftUI
import Vision
import VisionKit

struct AnnotatorView: View {
    // Control fullscreen covers.
    @State private var isCameraDisplayed: Bool = false
    @State private var isAnnotatedImageDisplayed: Bool = false
    @State private var isAdminPageDisplayed: Bool = false
    // Determines when fullscreen cover of text recognized is displayed.
    @State private var isRecognizedTextDisplayed: Bool = false
    // Determines whether a drawn image or raw image is displayed. A drawn image is displayed when isTextRecognitionComplete is true.
    @State private var isTextRecognitionComplete: Bool = false
    
    // Image vars.
    @State private var rawImage: UIImage? = UIImage(named: "default_image")
    @State private var drawnImage: UIImage? = UIImage(named: "default_image")
    
    @State private var rawImages: [UIImage] = [UIImage(named: "default_image")!]
    @State private var drawnImages: [UIImage] = [UIImage(named: "default_image")!]
    
    // Text recognition vars.
    @State private var recognizedText: [String] = ["No text recognized yet."]
    @State private var difficultRecognizedText: [Word] = []
    @State private var boundingBoxes: [CGRect] = []
    
    // Other vars.
    @State private var apiCallInformation: String = "No information about request."
    
    // Structs to perform computations.
    private let textRecognizer: TextRecognizer = .init()
    private let imageManipulator: ImageManipulator = .init()
    private let wordDifficultyComputer: WordDifficultyComputer = .init(threshold: 5000)
    
    
    var body: some View {
        VStack(spacing: 15) {
            
        // Camera opening button.
        Button(action: {
            () -> Void in
            self.isCameraDisplayed = true
            print("Camera opened.")
            
        }) {Image(
            systemName: "camera"
        )}
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        
        // Image opening button.
        Button(action: {
            () -> Void in
            self.isAnnotatedImageDisplayed = true
            print("Annotated image displayed.")
        }) {
            Image(systemName: "photo")}
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        
        // Text viewing button.
        Button(action: {() -> Void in
            self.isRecognizedTextDisplayed = true
        }){
            Image(systemName: "doc.text")
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        
        // Admin button.
        Button(action: {() -> Void in
            self.isAdminPageDisplayed = true
        }){
            Image(systemName: "exclamationmark.triangle")
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        
        // Fullscreen cover that displays camera.
        .fullScreenCover(isPresented: self.$isCameraDisplayed) {
//            Camera(image: self.$rawImage, isTextRecognitionComplete: self.$isTextRecognitionComplete)
//                .edgesIgnoringSafeArea(.all)
            DocumentCamera(scannedImages: self.$rawImages, isTextRecognitionComplete: self.$isTextRecognitionComplete)
                .edgesIgnoringSafeArea(.all)
//            Button(action: {() -> Void in self.isCameraDisplayed = false}) {
//                Text("Close")
//            }
//            .buttonStyle(.borderedProminent)
//            .controlSize(.large)
        }
        
        // Fullscreen cover that displays image(s).
        .fullScreenCover(isPresented: self.$isAnnotatedImageDisplayed) {
            VStack {
                // Display image taken (possibly with swiping gesture).
//                Image(uiImage: self.isTextRecognitionComplete ? self.drawnImage! : self.rawImage!)
//                    .resizable()
//                    .scaledToFit()
                ImageSwipeView(images: self.isTextRecognitionComplete ? self.drawnImages : self.rawImages)
                
                // Tried a solution for offset bounding boxes that I saw on StackOverflow. Doesn't display any bounding boxes.
//                Image(uiImage: self.rawImages[0])
//                    .resizable()
//                    .scaledToFit()
//                    .overlay {GeometryReader { geometry in
//                        ZStack {
//                            ForEach(0..<self.boundingBoxes.count) { index in
//                                Rectangle()
//                                    .stroke(lineWidth: 2)
//                                    .foregroundColor(.red)
//                                    .frame(width: self.boundingBoxes[index].width, height: self.boundingBoxes[index].height)
//                                    .offset(x: self.boundingBoxes[index].origin.x, y: self.boundingBoxes[index].origin.y)
//                            }
//                        }
//                    }}
                
                Button(action: {() -> Void in self.isAnnotatedImageDisplayed = false}) {
                    Text("Close")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        
        /// Fullscreen cover that displays text / difficult words
        .fullScreenCover(isPresented: self.$isRecognizedTextDisplayed) {
            ScrollView {
                List(self.difficultRecognizedText) { difficultWord in
                    Text(String(describing: difficultWord.shortdef))
                }
            }
            
            Button(action: {() -> Void in self.isRecognizedTextDisplayed = false}) {
                Text("Close")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        
        /// Fullscreen cover that displays admin / debug info. For dev purposes.
        .fullScreenCover(isPresented: self.$isAdminPageDisplayed, content: {
            Text("Bounding boxes - " + String(describing: self.boundingBoxes))
                .multilineTextAlignment(.center)
                .frame(alignment: .center)
            
            Text("All recognized text - " + String(describing: self.recognizedText))
                .multilineTextAlignment(.center)
                .frame(alignment: .center)
            
            Text("Easy words - " + String(describing: self.wordDifficultyComputer.getEasyWords()))
                .multilineTextAlignment(.center)
                .frame(alignment: .center)
            
            Text("Information about API call - \(self.apiCallInformation)")
                .multilineTextAlignment(.center)
                .frame(alignment: .center)
            
            Button(action: {() -> Void in self.isAdminPageDisplayed = false}) {
                Text("Close")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        })
        
        // When an image is taken, self.image changes. onChange watches for changes in self.
        .onChange(of: self.rawImages, perform: {
        // Task is used because model.performTextRecognition is an async method.
        (rawImages: [UIImage]) -> Void in Task {
                do {
                    self.difficultRecognizedText = []
                    
                    // Outdated method to get drawn images. Used with regular camera.
//                    (self.recognizedText, self.boundingBoxes) = try await model.performTextRecognition(image: self.rawImage)
//                    if let undrawnImage = self.rawImage {
//                        self.drawnImage = imageManipulator.drawBoundingBoxes(undrawnImage: undrawnImage, boundingBoxes: self.boundingBoxes)
//                    }
                    
                    self.drawnImages = []
                    for rawImage in rawImages {
                        let result = try await textRecognizer.performTextRecognition(image: rawImage)
                        
                        self.boundingBoxes = result.boundingBoxes
                        self.drawnImages.append(imageManipulator.drawBoundingBoxes(undrawnImage: rawImage, boundingBoxes: self.boundingBoxes)!)
                        
                        self.recognizedText = result.recognizedWords
                        var difficultRecognizedWords = wordDifficultyComputer.findDifficultWords(recognizedWords: self.recognizedText)
                        
                        let definitionRetriever = DefinitionRetriever(information: self.$apiCallInformation)
                        
                        for difficultRecognizedWord in difficultRecognizedWords {
                            definitionRetriever.fetchDefinition(completionHandler: { word in
                                self.difficultRecognizedText.append(word)
                            }, word: difficultRecognizedWord)
                        }
                    }
                    self.isTextRecognitionComplete = true
                } catch {
                    self.recognizedText = ["Something went wrong: \(error)"]
                    print(error)
                }
                }
        })
    }
}
