import SwiftUI

// MARK: - Canvas Element Protocol & Types

/// A common protocol adopted by every element that can live on the board.
///
/// Each element keeps track of its position, size and rotation in the two–
/// dimensional board coordinate-space. All units are expressed in points.
protocol BoardElement: Identifiable, Hashable {
    /// Unique identifier used by SwiftUI diffing.
    var id: UUID { get }

    /// The centre position of the element in board coordinate-space.
    var position: CGPoint { get set }

    /// The size of the element measured at a scale factor of `1`.
    var size: CGSize { get set }

    /// Rotation angle applied (in radians) clockwise.
    var angle: Angle { get set }

    /// A convenience describing the concrete element kind. Useful in `switch`-statements.
    var kind: BoardElementKind { get }
}

/// Enumerates the concrete element kinds that can be placed on the board.
enum BoardElementKind: String, CaseIterable, Codable, Hashable {
    case stickyNote
    case todoList
    case image
}

// Board-wide color palette for sticky notes & lists
enum BoardColor: String, CaseIterable, Codable, Hashable {
    case yellow, orange, pink, blue, green

    var swiftUIColor: Color {
        switch self {
        case .yellow: return Color.yellow.opacity(0.9)
        case .orange: return Color.orange.opacity(0.9)
        case .pink: return Color.pink.opacity(0.9)
        case .blue: return Color.blue.opacity(0.9)
        case .green: return Color.green.opacity(0.9)
        }
    }
}

// MARK: - Concrete Models

struct StickyNoteModel: BoardElement {
    var id: UUID = UUID()
    var position: CGPoint = .zero
    var size: CGSize = CGSize(width: 160, height: 160)
    var angle: Angle = .degrees(0)

    var title: String = "Note"
    var text: String = "New Note"
    var style: BoardColor = .yellow

    var kind: BoardElementKind { .stickyNote }
}

struct TodoItem: Identifiable, Hashable {
    var id: UUID = UUID()
    var title: String
    var isDone: Bool = false
}

struct TodoListModel: BoardElement {
    var id: UUID = UUID()
    var position: CGPoint = .zero
    var size: CGSize = CGSize(width: 200, height: 220)
    var angle: Angle = .degrees(0)

    var title: String = "List"
    var items: [TodoItem] = [TodoItem(title: "New Item")]
    var style: BoardColor = .yellow

    var kind: BoardElementKind { .todoList }
}

/// The image element only stores a reference to an identifer that can be resolved to underlying data.
/// For prototype, we store the actual `UIImage` in-memory – in a real app you would persist on-disk.
struct ImageElementModel: BoardElement, Hashable {
    var id: UUID = UUID()
    var position: CGPoint = .zero
    var size: CGSize = CGSize(width: 240, height: 240)
    var angle: Angle = .degrees(0)

    var title: String = "Image"

    // Because `UIImage` does not conform to `Codable`, we do not encode it.
    // In a shipping app, persist to file and store URL or AssetIdentifier.
    var uiImage: UIImage?

    var kind: BoardElementKind { .image }

    static func == (lhs: ImageElementModel, rhs: ImageElementModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
} 