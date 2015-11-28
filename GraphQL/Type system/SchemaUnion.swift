public class SchemaUnion: SchemaNameable {
    public let name: SchemaValidName
    let description: String?
    let possibleTypes: IdentitySet<SchemaObjectType>
    let resolve: Any -> SchemaObjectType

    public init(
        name: SchemaValidName,
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
