public final class SchemaEnum: Named {
    public let name: ValidName
    let description: String?
    let values: IdentitySet<SchemaEnumValue>

    public init(
        name: ValidName,
        description: String? = nil,
        values: IdentitySet<SchemaEnumValue>) {
            self.name = name
            self.description = description
            self.values = values
    }
}

public struct SchemaEnumValue: Identifiable {
    let value: String
    let description: String?
    let deprecationReason: String?

    public init(
        value: String,
        description: String? = nil,
        deprecationReason: String? = nil) {
            self.value = value
            self.description = description
            self.deprecationReason = deprecationReason
    }

    public var identifier: String { return value }
}
