public struct SchemaDirective: SchemaNameable {
    public let name: SchemaValidName
    let description: String?
    let arguments: IdentitySet<SchemaInputValue>
    let onOperation: Bool
    let onFragment: Bool
    let onField: Bool

    public init(
        name: SchemaValidName,
        description: String? = nil,
        arguments: IdentitySet<SchemaInputValue>,
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

let includeDirective = SchemaDirective(
    name: "include",
    description: "Directs the executor to include this field or fragment only when the `if` argument is true.",
    arguments: [
        SchemaInputValue(
            name: "if",
            type: .NonNull(.Scalar(.Boolean)),
            description: "Included when true."),
    ],
    onFragment: true,
    onField: true)

let skipDirective = SchemaDirective(
    name: "skip",
    description: "Directs the executor to skip this field or fragment when the `if` argument is true.",
    arguments: [
        SchemaInputValue(
            name: "if",
            type: .NonNull(.Scalar(.Boolean)),
            description: "Skipped when true."),
    ],
    onFragment: true,
    onField: true)
