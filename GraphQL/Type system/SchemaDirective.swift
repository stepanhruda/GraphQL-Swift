public struct SchemaDirective: Named {
    public let name: ValidName
    let description: String?
    let arguments: IdentitySet<SchemaInputValue<Any>>
    let onOperation: Bool
    let onFragment: Bool
    let onField: Bool

    public init(
        name: ValidName,
        description: String? = nil,
        arguments: IdentitySet<SchemaInputValue<Any>>,
        onOperation: Bool = false,
        onFragment: Bool = false,
        onField: Bool = false) {
            self.name = name
            self.description = description
            self.arguments = arguments
            self.onOperation = onOperation
            self.onFragment = onFragment
            self.onField = onField
    }
}

