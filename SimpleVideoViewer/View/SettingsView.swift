//
//  SettingsView.swift
//  SimpleVideoViewer
//
//  Created by aleksey.kazakov on 11.01.2025.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var mgr: AppManager
    @Binding var isSettingsVisible: Bool
    
    // Дополнительная переменная для нового URL
    @State private var newImageURL: String = ""
    
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

            Picker("Тип изображения", selection: $mgr.configuration.contentType) {
                Text("Image").tag(ContentType.image)
                Text("Video").tag(ContentType.video)
            }

            Picker("Соотношение сторон", selection: $mgr.configuration.aspectRatio) {
                Text("4:3").tag(AspectRatio.aspect4_3)
                Text("16:9").tag(AspectRatio.aspect16_9)
            }

            ColorPicker("Цвет границы", selection: $mgr.configuration.borderColor)

            // Новая секция для добавления, удаления и перетаскивания URL
            VStack {
                Text("Список URL-адресов:")
                    .font(.headline)

                List {
                    ForEach(mgr.configuration.imageURLs.indices, id: \.self) { index in
                        HStack {
                            TextField("URL for Image \(index + 1)", text: Binding(
                                get: { mgr.configuration.imageURLs[index] },
                                set: { mgr.configuration.imageURLs[index] = $0 }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.trailing, 8)
                            
                            // Удаление только если строка не пустая
                            Button(action: {
                                mgr.removeURL(at: index)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .onMove(perform: moveURL)
                }
                .frame(height: 200)
                .padding()
                
                HStack {
                    TextField("Новый URL", text: $newImageURL)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.trailing, 8)
                    
                    Button("Добавить URL") {
                        // Добавляем новый URL в список, если он не пустой
                        if !newImageURL.isEmpty {
                            mgr.configuration.imageURLs.append(newImageURL)
                            newImageURL = "" // очищаем поле
                        }
                    }
                    .padding()
                    .disabled(newImageURL.isEmpty)
                }
                .padding()
            }
            
            Spacer()

            Button("Сохранить и закрыть") {
                mgr.saveSettings()
                isSettingsVisible = false
            }
            .font(.title2)
            .padding()
        }
        .padding()
        .frame(width: 500, height: 700)
    }

    // Функция для перемещения URL в списке
    private func moveURL(from source: IndexSet, to destination: Int) {
        mgr.configuration.imageURLs.move(fromOffsets: source, toOffset: destination)
    }
}
