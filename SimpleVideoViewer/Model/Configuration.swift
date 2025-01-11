//
//  Cfg.swift
//  SimpleVideoViewer
//
//  Created by aleksey.kazakov on 11.01.2025.
//

import SwiftUI
import Combine


// Основные переменные сохраняемые в конфигурационном файле
struct Cfg {
    
    var gridSize: CGSize = CGSize(width: 2, height: 2) // Размер сетки по умолчанию
    var contentType: ContentType = .image // Тип контента по умолчанию
    var aspectRatio: AspectRatio = .aspect16_9 // Соотношение сторон
    var borderColor: Color = .gray // Цвет границы
    var fullscreenItem: Int? = nil // Индекс элемента в полноэкранном режиме
    var isSettingsVisible: Bool = false // Видимость модального окна настроек
    var imageURLs: [String] = Array(repeating: "", count: 16) // Массив путей для картинок
    var lastLoadedImages: [Int: Image] = [:] // Последние успешно загруженные изображения
    var loadFailures: [Int: Int] = [:] // Счетчики неудачных загрузок для каждого изображения
    var timers: [AnyCancellable] = [] // Таймеры обновления изображений
    
}
