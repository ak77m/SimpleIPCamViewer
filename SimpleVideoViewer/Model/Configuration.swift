//
//  Configuration.swift
//  SimpleVideoViewer
//
//  Created by aleksey.kazakov on 11.01.2025.
//

import SwiftUI

// Основные переменные сохраняемые в конфигурационном файле
struct Configuration {
    
    var gridSize: CGSize = CGSize(width: 2, height: 2) // Размер сетки по умолчанию
    var contentType: ContentType = .image // Тип контента по умолчанию
    var aspectRatio: AspectRatio = .aspect16_9 // Соотношение сторон
    var borderColor: Color = .gray // Цвет границы
    var imageURLs: [String] = Array(repeating: "", count: 16) // Массив путей для картинок
    
    var defaultImageName = "sample1"
    var imageURLsFileName = "imageURLs.json"
    var refreshInterval: TimeInterval = 2 // Интервал обновления изображений
    var maxFailures = 3 // Максимальное количество неудачных загрузок перед отображением надписи
    
}

// Типы контента
enum ContentType {
    case image
    case video
}

// Соотношения сторон
enum AspectRatio {
    case aspect4_3
    case aspect16_9

    var value: CGFloat {
        switch self {
        case .aspect4_3:
            return 4.0 / 3.0
        case .aspect16_9:
            return 16.0 / 9.0
        }
    }
}
