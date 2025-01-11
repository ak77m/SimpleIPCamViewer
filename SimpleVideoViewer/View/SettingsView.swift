//
//  SettingsView.swift
//  SimpleVideoViewer
//
//  Created by aleksey.kazakov on 11.01.2025.
//

import SwiftUI

// Модальное окно настроек
struct SettingsView: View {
    @Binding var isSettingsVisible: Bool
    @Binding var gridSize: CGSize
    @Binding var contentType: ContentType
    @Binding var aspectRatio: AspectRatio
    @Binding var borderColor: Color
    @Binding var imageURLs: [String]

    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .padding()

            HStack {
                Text("Grid Size:")
                Picker("Rows", selection: $gridSize.height) {
                    ForEach(1...4, id: \.self) { row in
                        Text("\(Int(row))").tag(CGFloat(row))
                    }
                }
                Picker("Columns", selection: $gridSize.width) {
                    ForEach(1...4, id: \.self) { col in
                        Text("\(Int(col))").tag(CGFloat(col))
                    }
                }
            }

            Picker("Content Type", selection: $contentType) {
                Text("Image").tag(ContentType.image)
                Text("Video").tag(ContentType.video)
            }

            Picker("Aspect Ratio", selection: $aspectRatio) {
                Text("4:3").tag(AspectRatio.aspect4_3)
                Text("16:9").tag(AspectRatio.aspect16_9)
            }

            ColorPicker("Border Color", selection: $borderColor)

            List(0..<imageURLs.count, id: \.self) { index in
                TextField("URL for Image \(index + 1)", text: Binding(
                    get: { imageURLs[index] },
                    set: { imageURLs[index] = $0 }
                ))
            }

            Spacer()

            Button("Save and Close") {
                saveSettings()
                isSettingsVisible = false
            }
            .font(.title2)
            .padding()
        }
        .frame(width: 400, height: 600)
    }

    private func saveSettings() {
        if let url = getDocumentsDirectory()?.appendingPathComponent("imageURLs.json"),
           let data = try? JSONEncoder().encode(imageURLs) {
            try? data.write(to: url)
        }
    }

    private func getDocumentsDirectory() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
}
