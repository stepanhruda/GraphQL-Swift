public struct SchemaValidName: StringLiteralConvertible {
    public let string: String

    public init(string: String) {
        self.string = string
    }

    public typealias ExtendedGraphemeClusterLiteralType = String
    public typealias UnicodeScalarLiteralType = String

    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.init(string: value)
    }

    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init(string: value)
    }

    public init(stringLiteral value: StringLiteralType) {
        self.init(string: value)
    }
}

extension SchemaValidName: CustomStringConvertible {
    public var description: String {
        return string
    }
}

public protocol SchemaNameable: Identifiable {
    var name: SchemaValidName { get }
}

extension SchemaNameable {
    public var identifier: String { return name.string }
}
