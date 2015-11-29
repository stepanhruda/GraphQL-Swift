public final class SchemaInputObjectType {
    var fields: IdentitySet<SchemaInputValue> {
        return undefined()
    }
}

public indirect enum SchemaInputValueType {
    case Scalar(SchemaScalarType)
    case Enum(SchemaEnum)
    case InputObject(SchemaInputObjectType)
    case List(SchemaInputValueType)
    case NonNull(SchemaInputValueType)
}


public struct SchemaInputValue: Named {
    public let name: ValidName
    public let description: String?
    public let type: SchemaInputValueType
    /// Perhaps it's possible to restrict the default based on type above?
    public let defaultValue: Any?
    public var value: Any?

    public init(
        name: ValidName,
        type: SchemaInputValueType,
        description: String? = nil,
        defaultValue: Any? = nil) {
            self.name = name
            self.type = type
            self.description = description
            self.defaultValue = defaultValue
    }
}
