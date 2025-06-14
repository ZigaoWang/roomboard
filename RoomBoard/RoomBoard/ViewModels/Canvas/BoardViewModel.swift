import SwiftUI
import Combine

final class BoardViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published private(set) var elements: [any BoardElement] = [] {
        didSet {
            persistence.save(elements: elements)
        }
    }

    // Canvas transform – allows panning and zooming on the board level
    @Published var canvasScale: CGFloat = 1.0 {
        didSet { persistence.save(elements: elements) }
    }
    @Published var canvasOffset: CGSize = .zero {
        didSet { persistence.save(elements: elements) }
    }

    // Selected element for showing resize handles etc.
    @Published var selectedElementID: UUID?

    private let persistence = BoardPersistence()

    init() {
        elements = persistence.load()
    }

    // MARK: - Intents
    func addStickyNote() {
        let note = StickyNoteModel()
        elements.append(note)
    }

    func addTodoList() {
        let list = TodoListModel()
        elements.append(list)
    }

    func addImage(_ image: UIImage) {
        var imageModel = ImageElementModel()
        imageModel.uiImage = image
        elements.append(imageModel)
    }

    func index(for element: any BoardElement) -> Int? {
        elements.firstIndex { $0.id == element.id }
    }

    func updateElement(_ updated: any BoardElement) {
        guard let idx = index(for: updated) else { return }
        elements[idx] = updated
    }

    // MARK: - Element Mutations
    func moveElement(id: UUID, by translation: CGSize) {
        guard let idx = elements.firstIndex(where: { $0.id == id }) else { return }
        switch elements[idx] {
        case var note as StickyNoteModel:
            note.position.x += translation.width
            note.position.y += translation.height
            elements[idx] = note
        case var list as TodoListModel:
            list.position.x += translation.width
            list.position.y += translation.height
            elements[idx] = list
        case var img as ImageElementModel:
            img.position.x += translation.width
            img.position.y += translation.height
            elements[idx] = img
        default: break
        }
    }

    func rotateElement(id: UUID, to angle: Angle) {
        guard let idx = elements.firstIndex(where: { $0.id == id }) else { return }
        switch elements[idx] {
        case var note as StickyNoteModel:
            note.angle = angle
            elements[idx] = note
        case var list as TodoListModel:
            list.angle = angle
            elements[idx] = list
        case var img as ImageElementModel:
            img.angle = angle
            elements[idx] = img
        default: break
        }
    }

    func scaleElement(id: UUID, by scale: CGFloat) {
        guard let idx = elements.firstIndex(where: { $0.id == id }) else { return }
        switch elements[idx] {
        case var note as StickyNoteModel:
            note.size.width *= scale
            note.size.height *= scale
            elements[idx] = note
        case var list as TodoListModel:
            list.size.width *= scale
            list.size.height *= scale
            elements[idx] = list
        case var img as ImageElementModel:
            img.size.width *= scale
            img.size.height *= scale
            elements[idx] = img
        default: break
        }
    }

    // Resize by delta keeping top-left fixed
    func resizeElement(id: UUID, by delta: CGSize, anchor: ResizeAnchor) {
        guard let idx = elements.firstIndex(where: { $0.id == id }) else { return }
        func applyResize(size: inout CGSize, position: inout CGPoint) {
            var dWidth: CGFloat = 0
            var dHeight: CGFloat = 0
            switch anchor {
            case .bottomRight:
                dWidth = delta.width; dHeight = delta.height
                // center shift
                position.x += delta.width/2; position.y += delta.height/2
            case .topLeft:
                dWidth = -delta.width; dHeight = -delta.height
                position.x += delta.width/2; position.y += delta.height/2
            case .topRight:
                dWidth = delta.width; dHeight = -delta.height
                position.x += delta.width/2; position.y += delta.height/2
            case .bottomLeft:
                dWidth = -delta.width; dHeight = delta.height
                position.x += delta.width/2; position.y += delta.height/2
            }
            size.width = max(60, size.width + dWidth)
            size.height = max(60, size.height + dHeight)
        }

        switch elements[idx] {
        case var note as StickyNoteModel:
            var pos = note.position; var sz = note.size
            applyResize(size: &sz, position: &pos)
            note.size = sz; note.position = pos
            elements[idx] = note
        case var list as TodoListModel:
            var pos = list.position; var sz = list.size
            applyResize(size: &sz, position: &pos)
            list.size = sz; list.position = pos
            elements[idx] = list
        case var img as ImageElementModel:
            var pos = img.position; var sz = img.size
            applyResize(size: &sz, position: &pos)
            img.size = sz; img.position = pos
            elements[idx] = img
        default:
            break
        }
    }

    // MARK: - Canvas Zoom helpers
    func zoomIn() {
        canvasScale *= 1.2
    }

    func zoomOut() {
        canvasScale /= 1.2
    }

    // MARK: - Content Updates
    func setNoteText(id: UUID, text: String) {
        guard let idx = elements.firstIndex(where: { $0.id == id }) else { return }
        guard var note = elements[idx] as? StickyNoteModel else { return }
        note.text = text
        elements[idx] = note
    }

    func setTodoItems(id: UUID, items: [TodoItem]) {
        guard let idx = elements.firstIndex(where: { $0.id == id }) else { return }
        guard var list = elements[idx] as? TodoListModel else { return }
        list.items = items
        elements[idx] = list
    }
} 