//
//  ContentView.swift
//  SimpleVideoViewer
//
//  Created by aleksey.kazakov on 10.01.2025.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State private var gridSize: CGSize = CGSize(width: 2, height: 2) // Размер сетки по умолчанию
    @State private var contentType: ContentType = .image // Тип контента по умолчанию
    @State private var aspectRatio: AspectRatio = .aspect16_9 // Соотношение сторон
    @State private var borderColor: Color = .gray // Цвет границы
    @State private var fullscreenItem: Int? = nil // Индекс элемента в полноэкранном режиме
    @State private var isSettingsVisible: Bool = false // Видимость модального окна настроек
    @State private var imageURLs: [String] = Array(repeating: "", count: 16) // Массив путей для картинок
    @State private var lastLoadedImages: [Int: Image] = [:] // Последние успешно загруженные изображения
    @State private var loadFailures: [Int: Int] = [:] // Счетчики неудачных загрузок для каждого изображения
    @State private var timers: [AnyCancellable] = [] // Таймеры обновления изображений

    private let defaultImageName = "sample1"
    private let imageURLsFileName = "imageURLs.json"
    private let refreshInterval: TimeInterval = 2 // Интервал обновления изображений
    private let maxFailures = 3 // Максимальное количество неудачных загрузок перед отображением надписи

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                if gridSize.width > 0 && gridSize.height > 0 {
                    let totalWidth = geometry.size.width
                    let cellWidth = totalWidth / CGFloat(gridSize.width)
                    let cellHeight = totalWidth / CGFloat(gridSize.width) / aspectRatio.value

                    VStack(spacing: 0) {
                        ForEach(0..<Int(gridSize.height), id: \.self) { row in
                            HStack(spacing: 0) {
                                ForEach(0..<Int(gridSize.width), id: \.self) { col in
                                    let index = row * Int(gridSize.width) + col
                                    MediaView(
                                        contentType: contentType,
                                        index: index,
                                        aspectRatio: aspectRatio,
                                        imageURL: imageURLs[index],
                                        lastLoadedImage: $lastLoadedImages[index],
                                        loadFailures: loadFailures[index] ?? 0,
                                        maxFailures: maxFailures,
                                        defaultImageName: defaultImageName
                                    )
                                    .frame(width: cellWidth, height: cellHeight)
                                    .overlay(
                                        Rectangle()
                                            .stroke(borderColor, lineWidth: 2)
                                    )
                                    .contextMenu {
                                        Button("Show Settings") {
                                            isSettingsVisible.toggle()
                                        }
                                    }
                                    .onLongPressGesture(minimumDuration: 0.5) {
                                        fullscreenItem = index
                                    }
                                }
                            }
                        }
                    }
                } else {
                    Text("Grid is hidden.")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }

            if let fullscreenIndex = fullscreenItem {
                MediaView(
                    contentType: contentType,
                    index: fullscreenIndex,
                    aspectRatio: aspectRatio,
                    imageURL: imageURLs[fullscreenIndex],
                    lastLoadedImage: $lastLoadedImages[fullscreenIndex],
                    loadFailures: loadFailures[fullscreenIndex] ?? 0,
                    maxFailures: maxFailures,
                    defaultImageName: defaultImageName
                )
                .onTapGesture {
                    fullscreenItem = nil
                }
                .transition(.scale)
            }
        }
        .animation(.default, value: fullscreenItem)
        .sheet(isPresented: $isSettingsVisible) {
            SettingsView(
                isSettingsVisible: $isSettingsVisible,
                gridSize: $gridSize,
                contentType: $contentType,
                aspectRatio: $aspectRatio,
                borderColor: $borderColor,
                imageURLs: $imageURLs
            )
        }
        .onAppear {
            loadSettings()
            startImageRefreshTimers()
        }
        .onDisappear {
            timers.forEach { $0.cancel() }
        }
    }

    private func loadSettings() {
        if let url = getDocumentsDirectory()?.appendingPathComponent(imageURLsFileName),
           let data = try? Data(contentsOf: url),
           let loadedURLs = try? JSONDecoder().decode([String].self, from: data) {
            imageURLs = loadedURLs
        }
    }

    private func saveSettings() {
        if let url = getDocumentsDirectory()?.appendingPathComponent(imageURLsFileName),
           let data = try? JSONEncoder().encode(imageURLs) {
            try? data.write(to: url)
        }
    }

    private func startImageRefreshTimers() {
        timers = imageURLs.enumerated().map { index, _ in
            Timer.publish(every: refreshInterval, on: .main, in: .common)
                .autoconnect()
                .sink { _ in
                    loadImage(for: index)
                }
        }
    }

    private func loadImage(for index: Int) {
        guard let url = URL(string: imageURLs[index]) else {
            print("Invalid URL for index \(index)")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error loading image for index \(index): \(error)")
                DispatchQueue.main.async {
                    self.loadFailures[index] = (self.loadFailures[index] ?? 0) + 1
                }
                return
            }

            guard let data = data, let nsImage = NSImage(data: data) else {
                print("Invalid image data for index \(index)")
                DispatchQueue.main.async {
                    self.loadFailures[index] = (self.loadFailures[index] ?? 0) + 1
                }
                return
            }

            DispatchQueue.main.async {
                self.lastLoadedImages[index] = Image(nsImage: nsImage)
                self.loadFailures[index] = 0 // Успешная загрузка сбрасывает счетчик
            }
        }.resume()
    }

    private func getDocumentsDirectory() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
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

// Виджет для отображения мультимедиа
struct MediaView: View {
    let contentType: ContentType
    let index: Int
    let aspectRatio: AspectRatio
    let imageURL: String
    @Binding var lastLoadedImage: Image?
    let loadFailures: Int
    let maxFailures: Int
    let defaultImageName: String

    var body: some View {
        ZStack {
            if let loadedImage = lastLoadedImage {
                loadedImage
                    .resizable()
                    .aspectRatio(aspectRatio.value, contentMode: .fit)
            } else {
                Image(defaultImageName)
                    .resizable()
                    .aspectRatio(aspectRatio.value, contentMode: .fit)
            }

            if loadFailures >= maxFailures {
                TextOverlay(message: "Изображение пропало")
            }
        }
    }
}


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
