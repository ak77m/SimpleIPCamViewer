//
//  SettingsView.swift
//  SimpleVideoViewer
//
//  Created by aleksey.kazakov on 11.01.2025.
//

import SwiftUI

// Модальное окно настроек
struct SettingsView: View {
    
    @EnvironmentObject var mgr: AppManager
    
     @Binding var isSettingsVisible: Bool
//    @Binding var gridSize: CGSize
//    @Binding var contentType: ContentType
//    @Binding var aspectRatio: AspectRatio
//    @Binding var borderColor: Color
//    @Binding var imageURLs: [String]

    var body: some View {
        VStack {
            Text("Настройки")
                .font(.largeTitle)
                .padding()

            HStack {
                Text("Сетка:")
                Picker("", selection: $mgr.configuration.gridSize.height) {
                    ForEach(1...4, id: \.self) { row in
                        Text("\(Int(row))").tag(CGFloat(row))
                    }
                }
                Picker("х", selection: $mgr.configuration.gridSize.width) {
                    ForEach(1...4, id: \.self) { col in
                        Text("\(Int(col))").tag(CGFloat(col))
                    }
                }
                Spacer()
            }

            Picker("Nип изображения", selection: $mgr.configuration.contentType) {
                Text("Image").tag(ContentType.image)
                Text("Video").tag(ContentType.video)
            }

            Picker("Соотношение сторон", selection: $mgr.configuration.aspectRatio) {
                Text("4:3").tag(AspectRatio.aspect4_3)
                Text("16:9").tag(AspectRatio.aspect16_9)
            }

            ColorPicker("Border Color", selection: $mgr.configuration.borderColor)

            List(0..<mgr.configuration.imageURLs.count, id: \.self) { index in
                TextField("URL for Image \(index + 1)", text: Binding(
                    get: { mgr.configuration.imageURLs[index] },
                    set: { mgr.configuration.imageURLs[index] = $0 }
                ))
            }

            Spacer()

            Button("Save and Close") {
                mgr.saveSettings()
                isSettingsVisible = false
            }
            .font(.title2)
            .padding()
        }
        .padding()
        .frame(width: 500, height: 700)
    }

}
