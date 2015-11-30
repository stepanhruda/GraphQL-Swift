public let includeDirective = SchemaDirective(
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

public let skipDirective = SchemaDirective(
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
