public struct Source {
    public let body: String
    public let name: String

    public init(body: String, name: String = "GraphQL") {
        self.body = body
        self.name = name
    }
}

extension Source: StringLiteralConvertible {
    public typealias ExtendedGraphemeClusterLiteralType = String
    public typealias UnicodeScalarLiteralType = String

    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.init(body: value)
    }

    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init(body: value)
    }

    public init(stringLiteral value: StringLiteralType) {
        self.init(body: value)
    }
}