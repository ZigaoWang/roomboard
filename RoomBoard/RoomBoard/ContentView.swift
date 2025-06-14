//
//  ContentView.swift
//  RoomBoard
//
//  Created by Zigao Wang on 6/7/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var boardVM = BoardViewModel()
    @State private var isShowingImagePicker = false
    @State private var selectedUIImage: UIImage?

    var body: some View {
        NavigationStack {
            CanvasView(viewModel: boardVM)
                .navigationTitle("RoomBoard")
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button(action: boardVM.addStickyNote) {
                            Label("Note", systemImage: "note.text")
                        }
                        Button(action: boardVM.addTodoList) {
                            Label("To-Do", systemImage: "checklist")
                        }
                        Button(action: { isShowingImagePicker = true }) {
                            Label("Image", systemImage: "photo.on.rectangle")
                        }

                        Spacer()

                        Button(action: boardVM.zoomOut) {
                            Label("Zoom Out", systemImage: "minus.magnifyingglass")
                        }

                        Button(action: boardVM.zoomIn) {
                            Label("Zoom In", systemImage: "plus.magnifyingglass")
                        }
                    }
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            UIApplication.shared.endEditing()
                        }
                    }
                }
                .sheet(isPresented: $isShowingImagePicker) {
                    ImagePicker(image: $selectedUIImage)
                        .onDisappear {
                            if let img = selectedUIImage {
                                boardVM.addImage(img)
                                selectedUIImage = nil
                            }
                        }
                }
        }
    }
}

// MARK: - UIKit ImagePicker
import PhotosUI
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
            provider.loadObject(ofClass: UIImage.self) { image, _ in
                DispatchQueue.main.async {
                    self.parent.image = image as? UIImage
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
