import SwiftUI

struct StickyNoteView: View {
    @EnvironmentObject private var viewModel: BoardViewModel
    let note: StickyNoteModel
    @State private var text: String

    init(note: StickyNoteModel) {
        self.note = note
        _text = State(initialValue: note.text)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.yellow.opacity(0.9))
                .shadow(radius: 4)

            TextEditor(text: $text)
                .padding(8)
                .background(Color.clear)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .onChange(of: text) { newVal in
                    viewModel.setNoteText(id: note.id, text: newVal)
                }
        }
    }
} 