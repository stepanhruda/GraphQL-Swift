public final class SchemaUnion: SchemaType {
    public let name: ValidName
    let description: String?
    let possibleTypes: [AnySchemaObject]
    let resolve: Any -> AnySchemaObject

    public init(
        name: ValidName,
        description: String? = nil,
        possibleTypes: [AnySchemaObject],
        resolve: Any -> AnySchemaObject
        ) {
            self.name = name
            self.description = description
            self.possibleTypes = possibleTypes
            self.resolve = resolve
    }
    
}
