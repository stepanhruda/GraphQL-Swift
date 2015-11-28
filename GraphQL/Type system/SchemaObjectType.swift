/// Note that object is a reference type, because fields can be self-referential etc.
public class SchemaObjectType: SchemaNameable {
    public let name: SchemaValidName
    let description: String?

    lazy var fields: IdentitySet<SchemaObjectField> = self.lazyFields()
    let interfaces: [SchemaInterface]

    private let lazyFields: () -> IdentitySet<SchemaObjectField>

    public init(
        name: SchemaValidName,
        description: String? = nil,
        fields: () -> IdentitySet<SchemaObjectField>,
        interfaces: [SchemaInterface] = []) {
            self.name = name
            self.description = description
            self.lazyFields = fields
            self.interfaces = interfaces
    }
}

public indirect enum SchemaObjectFieldType {
    case Scalar(SchemaScalarType)
    case Object(SchemaObjectType)
    case Interface(SchemaInterface)
    case Union(SchemaUnion)
    case Enum(SchemaEnum)
    case List(SchemaObjectFieldType)
    case NonNull(SchemaObjectFieldType)
}

public struct SchemaObjectField: SchemaNameable {
    public let name: SchemaValidName
    let type: SchemaObjectFieldType
    let description: String?
    let arguments: IdentitySet<SchemaInputValue>
    let resolve: (Any -> Any?)?
    let deprecationReason: String?

    public init(
        name: SchemaValidName,
        type: SchemaObjectFieldType,
        description: String? = nil,
        arguments: IdentitySet<SchemaInputValue> = [],
        resolve: (Any -> Any?)? = nil,
        deprecationReason: String? = nil) {
            self.name = name
            self.type = type
            self.description = description
            self.arguments = arguments
            self.resolve = resolve
            self.deprecationReason = deprecationReason
    }
}
