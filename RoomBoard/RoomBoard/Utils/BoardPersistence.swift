import SwiftUI

// Handles saving & loading board elements to Documents directory.
struct BoardPersistence {
    // MARK: - Nested Codable wrappers
    private struct PersistableTodoItem: Codable {
        var title: String
        var isDone: Bool
    }

    private struct PersistableElement: Codable {
        var id: UUID
        var kind: BoardElementKind

        var positionX: Double
        var positionY: Double
        var width: Double
        var height: Double
        var angleDegrees: Double

        // element specific
        var text: String?
        var items: [PersistableTodoItem]?
        var imageFilename: String?

        var title: String?
        var style: BoardColor?
    }

    // MARK: - Public API
    private let fileURL: URL = {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return url.appendingPathComponent("board.json")
    }()

    func save(elements: [any BoardElement]) {
        let persistables: [PersistableElement] = elements.map { element in
            var base = PersistableElement(id: element.id,
                                          kind: element.kind,
                                          positionX: element.position.x,
                                          positionY: element.position.y,
                                          width: element.size.width,
                                          height: element.size.height,
                                          angleDegrees: element.angle.degrees,
                                          text: nil,
                                          items: nil,
                                          imageFilename: nil,
                                          title: nil,
                                          style: nil)
            switch element.kind {
            case .stickyNote:
                if let note = element as? StickyNoteModel {
                    base.text = note.text
                    base.title = note.title
                    base.style = note.style
                }
            case .todoList:
                if let list = element as? TodoListModel {
                    base.items = list.items.map { PersistableTodoItem(title: $0.title, isDone: $0.isDone) }
                    base.title = list.title
                    base.style = list.style
                }
            case .image:
                if let imgModel = element as? ImageElementModel {
                    base.title = imgModel.title
                    if let uiImg = imgModel.uiImage {
                        let filename = imgModel.id.uuidString + ".png"
                        let imgURL = imageDirectory().appendingPathComponent(filename)
                        if !FileManager.default.fileExists(atPath: imgURL.path) {
                            if let data = uiImg.pngData() {
                                try? data.write(to: imgURL)
                            }
                        }
                        base.imageFilename = filename
                    }
                }
            }
            return base
        }

        let encoder = JSONEncoder()
        if let data = try? encoder.encode(persistables) {
            try? data.write(to: fileURL)
        }
    }

    func load() -> [any BoardElement] {
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        let decoder = JSONDecoder()
        guard let persistables = try? decoder.decode([PersistableElement].self, from: data) else { return [] }

        return persistables.compactMap { persistent in
            switch persistent.kind {
            case .stickyNote:
                var note = StickyNoteModel()
                note.id = persistent.id
                note.position = CGPoint(x: persistent.positionX, y: persistent.positionY)
                note.size = CGSize(width: persistent.width, height: persistent.height)
                note.angle = .degrees(persistent.angleDegrees)
                note.text = persistent.text ?? ""
                if let title = persistent.title { note.title = title }
                if let style = persistent.style { note.style = style }
                return note
            case .todoList:
                var list = TodoListModel()
                list.id = persistent.id
                list.position = CGPoint(x: persistent.positionX, y: persistent.positionY)
                list.size = CGSize(width: persistent.width, height: persistent.height)
                list.angle = .degrees(persistent.angleDegrees)
                if let items = persistent.items {
                    list.items = items.map { TodoItem(title: $0.title, isDone: $0.isDone) }
                }
                if let title = persistent.title { list.title = title }
                if let style = persistent.style { list.style = style }
                return list
            case .image:
                var img = ImageElementModel()
                img.id = persistent.id
                img.position = CGPoint(x: persistent.positionX, y: persistent.positionY)
                img.size = CGSize(width: persistent.width, height: persistent.height)
                img.angle = .degrees(persistent.angleDegrees)
                if let filename = persistent.imageFilename {
                    let path = imageDirectory().appendingPathComponent(filename)
                    if let data = try? Data(contentsOf: path), let uiImg = UIImage(data: data) {
                        img.uiImage = uiImg
                    }
                }
                if let title = persistent.title { img.title = title }
                return img
            }
        }
    }

    // Helper to get/create image directory inside documents
    private func imageDirectory() -> URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("images")
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }
} 