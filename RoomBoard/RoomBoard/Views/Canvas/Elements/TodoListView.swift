import SwiftUI

struct TodoListView: View {
    @EnvironmentObject private var viewModel: BoardViewModel
    let list: TodoListModel
    @State private var items: [TodoItem]

    init(list: TodoListModel) {
        self.list = list
        _items = State(initialValue: list.items)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach($items) { $item in
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
        .onChange(of: items) { newItems in
            viewModel.setTodoItems(id: list.id, items: newItems)
        }
    }

    private func addItem() {
        items.append(TodoItem(title: "New Item"))
    }
} 
