//
//  Configuration.swift
//  SimpleVideoViewer
//
//  Created by aleksey.kazakov on 11.01.2025.
//

import SwiftUI

// Основные переменные сохраняемые в конфигурационном файле

struct Configuration: Codable {
    var gridSize: CGSize = CGSize(width: 2, height: 2)
    var contentType: ContentType = .image
    var aspectRatio: AspectRatio = .aspect4_3
    var borderColor: Color = .blue
    var refreshInterval: TimeInterval = 5
    var imageURLs: [String] = []
    var imageURLsFileName: String = "imageURLs.json" // Имя файла для сохранения данных
    var defaultImageName = "NoImage"
    var maxFailures = 3 // Максимальное количество неудачных загрузок перед отображением надписи о потере изображения
    
    // Преобразование цвета для кодирования
    private enum CodingKeys: String, CodingKey {
        case gridSize, contentType, aspectRatio, borderColor, refreshInterval, imageURLs
    }

    init() {}
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        gridSize = try container.decode(CGSize.self, forKey: .gridSize)
        contentType = try container.decode(ContentType.self, forKey: .contentType)
        aspectRatio = try container.decode(AspectRatio.self, forKey: .aspectRatio)
        refreshInterval = try container.decode(TimeInterval.self, forKey: .refreshInterval)
        imageURLs = try container.decode([String].self, forKey: .imageURLs)
        
        // Раскодировать цвет как HEX
        if let hexString = try? container.decode(String.self, forKey: .borderColor),
           let color = Color(hex: hexString) {
            borderColor = color
        } else {
            borderColor = .blue
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(gridSize, forKey: .gridSize)
        try container.encode(contentType, forKey: .contentType)
        try container.encode(aspectRatio, forKey: .aspectRatio)
        try container.encode(refreshInterval, forKey: .refreshInterval)
        try container.encode(imageURLs, forKey: .imageURLs)

        // Кодировать цвет как HEX
        try container.encode(borderColor.toHex(), forKey: .borderColor)
    }
}

// Типы контента
enum ContentType: String, Codable {
    case image
    case video
}

// Соотношения сторон
enum AspectRatio: String, Codable {
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

extension Color {
    
    init?(hex: String) {
            var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
            
            var rgb: UInt64 = 0
            guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
                return nil // Некорректный HEX-код
            }
            
            let length = hexSanitized.count
            
            let red, green, blue, alpha: Double
            if length == 6 {
                red = Double((rgb >> 16) & 0xFF) / 255.0
                green = Double((rgb >> 8) & 0xFF) / 255.0
                blue = Double(rgb & 0xFF) / 255.0
                alpha = 1.0
            } else if length == 8 {
                red = Double((rgb >> 24) & 0xFF) / 255.0
                green = Double((rgb >> 16) & 0xFF) / 255.0
                blue = Double((rgb >> 8) & 0xFF) / 255.0
                alpha = Double(rgb & 0xFF) / 255.0
            } else {
                return nil // Некорректная длина HEX-кода
            }

            self.init(red: red, green: green, blue: blue, opacity: alpha)
        }
    
    /// Преобразует SwiftUI Color в шестнадцатеричный цветовой код
    func toHex() -> String? {
        guard let components = NSColor(self).cgColor.components else {
            return nil
        }

        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        return String(format: "#%02lX%02lX%02lX",
                      lround(Double(r * 255)),
                      lround(Double(g * 255)),
                      lround(Double(b * 255)))
    }
}

