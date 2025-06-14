import SwiftUI

struct TodoListView: View {
    @EnvironmentObject private var viewModel: BoardViewModel
    let list: TodoListModel
    @State private var items: [TodoItem]
    @State private var showRenameAlert = false
    @State private var newTitle: String = ""

    init(list: TodoListModel) {
        self.list = list
        _items = State(initialValue: list.items)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(list.title)
                .font(.headline)
            Divider()
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(list.style.swiftUIColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 4)
        .onChange(of: items) { newItems in
            viewModel.setTodoItems(id: list.id, items: newItems)
        }
        .contextMenu {
            Button("Delete", role: .destructive) {
                viewModel.deleteElement(id: list.id)
            }
            Button("Rename") {
                newTitle = list.title
                showRenameAlert = true
            }
            Menu("Color") {
                ForEach(BoardColor.allCases, id: \ .self) { color in
                    Button(action: { viewModel.setStyle(id: list.id, style: color) }) {
                        Label(color.rawValue.capitalized, systemImage: "paintpalette")
                    }
                }
            }
        }
        .alert("Rename", isPresented: $showRenameAlert, actions: {
            TextField("Title", text: $newTitle)
            Button("OK") { viewModel.setTitle(id: list.id, title: newTitle) }
            Button("Cancel", role: .cancel) {}
        }) { Text("Enter new title") }
    }

    private func addItem() {
        items.append(TodoItem(title: "New Item"))
    }
} 
