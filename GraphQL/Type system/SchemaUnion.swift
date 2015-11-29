public final class SchemaUnion: Named {
    public let name: ValidName
    let description: String?
    let possibleTypes: IdentitySet<SchemaObjectType>
    let resolve: Any -> SchemaObjectType

    public init(
        name: ValidName,
        description: String? = nil,
        possibleTypes: IdentitySet<SchemaObjectType>,
        resolve: Any -> SchemaObjectType
        ) {
            self.name = name
            self.description = description
            self.possibleTypes = possibleTypes
            self.resolve = resolve
    }
    
}
