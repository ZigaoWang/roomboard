import SwiftUI

struct StickyNoteView: View {
    @State var model: StickyNoteModel

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.yellow.opacity(0.9))
                .shadow(radius: 4)

            TextEditor(text: $model.text)
                .padding(8)
                .background(Color.clear)
                .font(.system(size: 16, weight: .regular, design: .rounded))
        }
    }
} 