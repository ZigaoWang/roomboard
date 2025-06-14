import SwiftUI

struct TodoListView: View {
    @State var model: TodoListModel

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach($model.items) { $item in
                HStack {
                    Button(action: { item.isDone.toggle() }) {
                        Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(item.isDone ? .green : .secondary)
                    }
                    TextField("Item", text: $item.title)
                        .textFieldStyle(.plain)
                }
            }
            Button(action: addItem) {
                Label("Add", systemImage: "plus")
                    .font(.caption)
            }
            .padding(.top, 4)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .shadow(radius: 4)
    }

    private func addItem() {
        model.items.append(TodoItem(title: "New Item"))
    }
} 
