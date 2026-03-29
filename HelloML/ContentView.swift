//
//  ContentView.swift
//  HelloML
//
//  Created by Brian Surface on 3/28/26.
//

import SwiftUI
import CoreML

struct ContentView: View {
    let images = ["1","2","3","4"]
    @State private var currentIndex = 0
    @State private var imagePrediction: String = ""
    @State private var confidences: [String : Double] = [:]
    
    private var sortedProbs: [Dictionary<String, Double>.Element] {
        let probs = Array(confidences)
        return probs.sorted { $0.value > $1.value }
    }
    
    let model = try! MobileNetV2(configuration: MLModelConfiguration())
    var body: some View {
        VStack {
            Image(images[currentIndex])
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300, height: 300)
            HStack {
                Button("Previous") {
                    currentIndex -= 1
                }.buttonStyle(.bordered).disabled(currentIndex == 0)
                Button("Next") {
                    currentIndex += 1
                }.buttonStyle(.bordered)
                    .disabled(currentIndex == images.count - 1)
                
            }
            Button("Predict"){
                
                guard let uiimage = UIImage(named: images[currentIndex]) else{return print("No Image")}
                let resizedImage = uiimage.resize(to: CGSize(width: 224, height: 224))
                
                do{
                    let buffer = try resizedImage.toCVPixelBuffer()
                    let prediction = try self.model.prediction(image: buffer)
                    print(prediction.classLabel)
                    confidences = prediction.classLabelProbs
                     imagePrediction = prediction.classLabel
                }catch{
                    print(error)
                }
                
            }.buttonStyle(.borderedProminent)
            
           PredictionView(probs: Array(sortedProbs))
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
