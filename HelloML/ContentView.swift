//
//  ContentView.swift
//  HelloML
//
//  Created by Brian Surface on 3/28/26.
//

import SwiftUI
import CoreML
import PhotosUI

struct ContentView: View {
    @State private var currentIndex = 0
    @State private var imagePrediction: String = ""
    @State private var confidences: [String: Double] = [:]
    @State private var inferenceError: String = ""
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var photoImage: UIImage? = UIImage(named: "cat_113" )
    @State private var isCameraSelected: Bool = false

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
            Image(uiImage: photoImage ?? UIImage(named: "cat_113" )!)
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)

            HStack {
                
                PhotosPicker(selection: $selectedPhoto, matching: .images){
                    Text("Select an image")
                }.buttonStyle(.bordered)

                Button("Camera") {
                    isCameraSelected = true
                }
                .buttonStyle(.bordered)
                
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
        }.onChange(of: selectedPhoto, { oldValue, newValue in
            if oldValue == newValue {
                return
            }
            if let newValue {
                newValue.loadTransferable(type: Data.self, completionHandler: { result in
                    switch result {
                    case .success(let data):
                        guard let img = UIImage(data: data!) else {
                            return
                        }
                        photoImage = img
                    case .failure(let error):
                        print("Error loading image data: \(error)")
                    }
                })
            }
        })
        .sheet(isPresented: $isCameraSelected, content: {
            ImagePickerCamera(image: $photoImage, sourceType: .camera)
        }
    )
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

        guard let uiimage = photoImage else {
            inferenceError = "Unable to load image: \(photoImage)."
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
