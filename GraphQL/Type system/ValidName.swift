public struct ValidName: StringLiteralConvertible, Hashable {
    public let string: String
    public let location: Location?

    public init(string: String, location: Location? = nil) {
        self.string = string
        self.location = location
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

    public var hashValue: Int { return string.hashValue }
}

public func == (left: ValidName, right: ValidName) -> Bool {
    return left.string == right.string
}

extension ValidName: CustomStringConvertible {
    public var description: String {
        return string
    }
}

public protocol Named: Identifiable {
    var name: ValidName { get }
}

extension Named {
    public var identifier: String { return name.string }
}
