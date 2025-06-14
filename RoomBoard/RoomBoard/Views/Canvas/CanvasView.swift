import SwiftUI
// ResizeHandle is declared in same module

struct CanvasView: View {
    @ObservedObject var viewModel: BoardViewModel

    // Gesture state
    @GestureState private var magnifyBy: CGFloat = 1.0
    @GestureState private var dragBy: CGSize = .zero

    // Keeps track of last drag translation per element so we can apply only the delta each update.
    @State private var lastDragTranslation: [UUID: CGSize] = [:]

    let handleSize: CGFloat = 14

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background grid or plain color
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()

                ForEach(Array(viewModel.elements.enumerated()), id: \.offset) { index, element in
                    let isSelected = viewModel.selectedElementID == element.id
                    elementView(for: element)
                        .frame(width: element.size.width, height: element.size.height)
                        .gesture(elementGesture(element))
                        .onTapGesture {
                            viewModel.selectedElementID = element.id
                        }
                        .if(isSelected) { view in
                            view
                                .overlay(
                                    ResizeHandle(size: handleSize, anchor: .topLeft) { delta in
                                        viewModel.resizeElement(id: element.id, by: delta, anchor: .topLeft)
                                    }, alignment: .topLeading)
                                .overlay(
                                    ResizeHandle(size: handleSize, anchor: .topRight) { delta in
                                        viewModel.resizeElement(id: element.id, by: delta, anchor: .topRight)
                                    }, alignment: .topTrailing)
                                .overlay(
                                    ResizeHandle(size: handleSize, anchor: .bottomLeft) { delta in
                                        viewModel.resizeElement(id: element.id, by: delta, anchor: .bottomLeft)
                                    }, alignment: .bottomLeading)
                                .overlay(
                                    ResizeHandle(size: handleSize, anchor: .bottomRight) { delta in
                                        viewModel.resizeElement(id: element.id, by: delta, anchor: .bottomRight)
                                    }, alignment: .bottomTrailing)
                        }
                        .rotationEffect(element.angle)
                        .position(element.position)
                }
            }
            .scaleEffect(viewModel.canvasScale * magnifyBy)
            .offset(x: viewModel.canvasOffset.width + dragBy.width,
                    y: viewModel.canvasOffset.height + dragBy.height)
            .gesture(canvasGestures())
            .animation(.spring(), value: viewModel.canvasScale)
        }
    }

    // MARK: - Per element gesture
    private func elementGesture(_ element: any BoardElement) -> some Gesture {
        let drag = DragGesture()
            .onChanged { value in
                let previous = lastDragTranslation[element.id] ?? .zero
                let delta = CGSize(width: value.translation.width - previous.width,
                                   height: value.translation.height - previous.height)
                lastDragTranslation[element.id] = value.translation
                viewModel.moveElement(id: element.id, by: delta)
            }
            .onEnded { _ in
                lastDragTranslation[element.id] = nil
            }

        let rotate = RotationGesture()
            .onChanged { angle in
                viewModel.rotateElement(id: element.id, to: angle)
            }

        let pinch = MagnificationGesture()
            .onChanged { scale in
                viewModel.scaleElement(id: element.id, by: scale)
            }

        return SimultaneousGesture(drag, SimultaneousGesture(rotate, pinch))
    }

    // MARK: - Canvas gesture (pan & zoom)
    private func canvasGestures() -> some Gesture {
        let drag = DragGesture()
            .updating($dragBy) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                viewModel.canvasOffset.width += value.translation.width
                viewModel.canvasOffset.height += value.translation.height
            }

        let zoom = MagnificationGesture()
            .updating($magnifyBy) { value, state, _ in
                state = value
            }
            .onEnded { value in
                viewModel.canvasScale *= value
            }

        return SimultaneousGesture(drag, zoom)
    }

    @ViewBuilder
    private func elementView(for element: any BoardElement) -> some View {
        switch element.kind {
        case .stickyNote:
            if let note = element as? StickyNoteModel {
                StickyNoteView(note: note)
                    .environmentObject(viewModel)
            }
        case .todoList:
            if let list = element as? TodoListModel {
                TodoListView(list: list)
                    .environmentObject(viewModel)
            }
        case .image:
            if let img = element as? ImageElementModel {
                ImageElementView(model: img)
            }
        }
    }
}

private extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
} 