//
//  AppManager.swift
//  SimpleVideoViewer
//
//  Created by aleksey.kazakov on 11.01.2025.
//

import SwiftUI
import Combine

final class AppManager: ObservableObject {
    
    @Published var configuration = Configuration()
    @Published var loadFailures: [Int: Int] = [:] // Счетчики неудачных загрузок для каждого изображения
    @Published var lastLoadedImages: [Int: Image] = [:] // Последние успешно загруженные изображения
    var timers: [AnyCancellable] = [] // Таймеры обновления изображений
    
    func loadSettings() {
        if let url = getDocumentsDirectory()?.appendingPathComponent(configuration.imageURLsFileName),
           let data = try? Data(contentsOf: url),
           let loadedURLs = try? JSONDecoder().decode([String].self, from: data) {
            configuration.imageURLs = loadedURLs
        }
    }

    func saveSettings() {
        if let url = getDocumentsDirectory()?.appendingPathComponent(configuration.imageURLsFileName),
           let data = try? JSONEncoder().encode(configuration.imageURLs) {
            try? data.write(to: url)
        }
    }

    func startImageRefreshTimers() {
        timers = configuration.imageURLs.enumerated().map { index, _ in
            Timer.publish(every: configuration.refreshInterval, on: .main, in: .common)
                .autoconnect()
                .sink { _ in
                    self.loadImage(for: index)
                }
        }
    }

    private func loadImage(for index: Int) {
        guard let url = URL(string: configuration.imageURLs[index]) else {
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
    
    func removeURL(at index: Int) {
        guard index < configuration.imageURLs.count else { return }
        
        // Удаляем URL из массива
        configuration.imageURLs.remove(at: index)
        
        // Обновляем связанные структуры
        DispatchQueue.main.async {
            self.reindexDataStructures(afterRemovingIndex: index)
        }
    }
    
    private func reindexDataStructures(afterRemovingIndex removedIndex: Int) {
        // Удаляем связанные данные из loadFailures
        var updatedLoadFailures: [Int: Int] = [:]
        for (key, value) in loadFailures where key != removedIndex {
            updatedLoadFailures[key < removedIndex ? key : key - 1] = value
        }
        loadFailures = updatedLoadFailures

        // Удаляем связанные данные из lastLoadedImages
        var updatedLastLoadedImages: [Int: Image] = [:]
        for (key, value) in lastLoadedImages where key != removedIndex {
            updatedLastLoadedImages[key < removedIndex ? key : key - 1] = value
        }
        lastLoadedImages = updatedLastLoadedImages
        
        // Перезапускаем таймеры
        restartTimers()
    }
    
    private func restartTimers() {
        // Очищаем старые таймеры
        timers.forEach { $0.cancel() }
        timers.removeAll()
        
        // Запускаем новые таймеры
        startImageRefreshTimers()
    }
    
    private func getDocumentsDirectory() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
}
