import SwiftUI

struct ImageElementView: View {
    @EnvironmentObject private var viewModel: BoardViewModel
    @State private var showRenameAlert = false
    @State private var newTitle: String = ""

    let model: ImageElementModel

    var body: some View {
        ZStack(alignment: .topLeading) {
            Group {
                if let img = model.uiImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .clipped()
                } else {
                    Color.gray.opacity(0.2)
                    VStack {
                        Image(systemName: "photo")
                        Text("Image")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(model.title)
                .font(.subheadline).bold()
                .padding(4)
                .background(Color.black.opacity(0.4))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .padding(6)
        }
        .shadow(radius: 4)
        .contextMenu {
            Button("Delete", role: .destructive) {
                viewModel.deleteElement(id: model.id)
            }
            Button("Rename") {
                newTitle = model.title
                showRenameAlert = true
            }
        }
        .alert("Rename", isPresented: $showRenameAlert, actions: {
            TextField("Title", text: $newTitle)
            Button("OK") { viewModel.setTitle(id: model.id, title: newTitle) }
            Button("Cancel", role: .cancel) {}
        }) { Text("Enter new title") }
    }
} 