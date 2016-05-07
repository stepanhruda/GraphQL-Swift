public final class SchemaUnion: SchemaType {
    public let name: ValidName
    let description: String?
    let possibleTypes: IdentitySet<SchemaObject>
    let resolve: Any -> SchemaObject

    public init(
        name: ValidName,
        description: String? = nil,
        possibleTypes: IdentitySet<SchemaObject>,
        resolve: Any -> SchemaObject
        ) {
            self.name = name
            self.description = description
            self.possibleTypes = possibleTypes
            self.resolve = resolve
    }
    
}
