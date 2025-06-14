import SwiftUI

struct StickyNoteView: View {
    @EnvironmentObject private var viewModel: BoardViewModel
    let note: StickyNoteModel
    @State private var text: String
    @State private var showRenameAlert = false
    @State private var newTitle: String = ""

    init(note: StickyNoteModel) {
        self.note = note
        _text = State(initialValue: note.text)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(note.title)
                .font(.headline)
                .padding(.horizontal, 4)
                .padding(.top, 4)
            Divider()
            TextEditor(text: $text)
                .padding(4)
                .background(Color.clear)
                .font(.system(size: 16, weight: .regular, design: .rounded))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(note.style.swiftUIColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 4)
        .onChange(of: text) { newVal in
            viewModel.setNoteText(id: note.id, text: newVal)
        }
        .contextMenu {
            Button("Delete", role: .destructive) {
                viewModel.deleteElement(id: note.id)
            }
            Button("Rename") {
                newTitle = note.title
                showRenameAlert = true
            }
            Menu("Color") {
                ForEach(BoardColor.allCases, id: \ .self) { color in
                    Button(action: { viewModel.setStyle(id: note.id, style: color) }) {
                        Label(color.rawValue.capitalized, systemImage: "paintpalette")
                    }
                }
            }
        }
        .alert("Rename", isPresented: $showRenameAlert, actions: {
            TextField("Title", text: $newTitle)
            Button("OK") {
                viewModel.setTitle(id: note.id, title: newTitle)
            }
            Button("Cancel", role: .cancel) {}
        }) {
            Text("Enter new title")
        }
    }
} 