//
//  ContentView.swift
//  HelloML
//
//  Created by Brian Surface on 3/28/26.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var currentIndex = 0
    @State private var imagePrediction: String = ""
    @State private var confidences: [String: Double] = [:]
    @State private var inferenceError: String = ""

    let images: [String] = [
        "cat_113",
        "cat_114",
        "cat_116",
        "dog_123",
        "dog_124",
        "dog_130"
    ]

    private var sortedProbs: [Dictionary<String, Double>.Element] {
        let probs = Array(confidences)
        return probs.sorted { $0.value > $1.value }
    }

    private let model: CatsVsDogsImageClassifier_1? = {
        do {
            let config = MLModelConfiguration()
            return try CatsVsDogsImageClassifier_1(configuration: config)
        } catch {
            print("Model load failed: \(error)")
            return nil
        }
    }()

    var body: some View {
        VStack {
            Image(images[currentIndex])
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300, height: 300)

            HStack {
                Button("Previous") {
                    currentIndex -= 1
                }
                .buttonStyle(.bordered)
                .disabled(currentIndex == 0)

                Button("Next") {
                    currentIndex += 1
                }
                .buttonStyle(.bordered)
                .disabled(currentIndex == images.count - 1)
            }

            Button("Predict") {
                predictCurrentImage()
            }
            .buttonStyle(.borderedProminent)

            if !imagePrediction.isEmpty {
                Text("Prediction: \(imagePrediction)")
                    .font(.headline)
            }

            if !inferenceError.isEmpty {
                Text(inferenceError)
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            PredictionView(probs: Array(sortedProbs))
        }
        .padding()
    }

    private func predictCurrentImage() {
        inferenceError = ""

        if ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil {
            inferenceError = "This Create ML pipeline model cannot run in the iOS Simulator on this setup. Run the app on a physical iPhone or iPad to get predictions."
            return
        }

        guard let model else {
            inferenceError = "Model failed to load."
            return
        }

        guard let uiimage = UIImage(named: images[currentIndex]) else {
            inferenceError = "Unable to load image: \(images[currentIndex])."
            return
        }

        let resizedImage = uiimage.resize(to: CGSize(width: 299, height: 299))

        do {
            let buffer = try resizedImage.toCVPixelBuffer()
            let prediction = try model.prediction(image: buffer)
            confidences = prediction.targetProbability
            imagePrediction = prediction.target
        } catch {
            inferenceError = "Prediction failed: \(error.localizedDescription)"
            print(error)
        }
    }
}

#Preview {
    ContentView()
}
