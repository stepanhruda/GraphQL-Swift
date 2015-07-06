public struct Source {
    public let body: String
    public let name: String

    public init(body: String, name: String = "GraphQL") {
        self.body = body
        self.name = name
    }
}
