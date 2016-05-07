public final class SchemaEnum<Enum: RawRepresentable where Enum.RawValue == String>: SchemaType, AllowedAsObjectField, AllowedAsInputValue, AllowedAsNonNull, AnySchemaEnum {
    public let name: ValidName
    let description: String?
    let values: IdentitySet<SchemaEnumValue<Enum>>

    public init(
        name: ValidName,
        description: String? = nil,
        values: IdentitySet<SchemaEnumValue<Enum>>) {
            self.name = name
            self.description = description
            self.values = values
    }

    public var allValues: [AnySchemaEnumValue] {
        return values.map { $0 as AnySchemaEnumValue }
    }

    public var nonDeprecatedValues: [AnySchemaEnumValue] {
        return allValues.filter { $0.deprecationReason == nil }
    }
}

public protocol AnySchemaEnum {
    var allValues: [AnySchemaEnumValue] { get }
    var nonDeprecatedValues: [AnySchemaEnumValue] { get }
}

public protocol AnySchemaEnumValue {
    var deprecationReason: String? { get }
}

public struct SchemaEnumValue<Enum: RawRepresentable where Enum.RawValue == String>: Identifiable, AnySchemaEnumValue {
    public let value: Enum
    public let description: String?
    public let deprecationReason: String?

    public init(
        value: Enum,
        description: String? = nil,
        deprecationReason: String? = nil) {
            self.value = value
            self.description = description
            self.deprecationReason = deprecationReason
    }

    public var identifier: String { return value.rawValue }
}

public protocol StringRepresentable {

}


