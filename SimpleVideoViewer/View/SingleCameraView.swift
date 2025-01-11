//
//  SingleCameraView.swift
//  SimpleVideoViewer
//
//  Created by aleksey.kazakov on 11.01.2025.
//

import SwiftUI

struct TextOverlay: View {
    let message: String

    var body: some View {
        Text(message)
            .foregroundColor(.red)
            .font(.caption)
            .padding(4)
            .background(Color.black.opacity(0.6))
            .cornerRadius(5)
            .padding([.trailing, .bottom], 8)
    }
}

// Виджет для отображения камеры
struct SingleCameraView: View {
    @EnvironmentObject var mgr: AppManager
    
    let index: Int

    var body: some View {
        // Разделяем вычисления на отдельные переменные для упрощения
        let loadedImage = mgr.lastLoadedImages[index]
        let loadFailures = mgr.loadFailures[index] ?? 0
        let imageToDisplay: Image

        if let loadedImage = loadedImage {
            imageToDisplay = loadedImage
        } else {
            imageToDisplay = Image(mgr.configuration.defaultImageName)
        }

        return ZStack {
            // Отображаем изображение
            imageToDisplay
                .resizable()
                .aspectRatio(mgr.configuration.aspectRatio.value, contentMode: .fit)

            // Проверяем количество неудачных попыток загрузки
            if loadFailures >= mgr.configuration.maxFailures {
                TextOverlay(message: "Изображение пропало")
            }
        }
    }
}
