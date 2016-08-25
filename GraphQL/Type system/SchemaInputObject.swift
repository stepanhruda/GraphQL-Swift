public struct SchemaInputValue<Type>: Named {
    public let name: ValidName
    public let description: String?
    public let type: AllowedAsInputValue
    /// Perhaps it's possible to restrict the default based on type above?
    public let defaultValue: Any?
    public var value: Any?

    public init(
        name: ValidName,
        type: AllowedAsInputValue,
        description: String? = nil,
        defaultValue: Any? = nil) {
            self.name = name
            self.type = type
            self.description = description
            self.defaultValue = defaultValue
    }
}

public protocol AnySchemaInputValue {}
extension SchemaInputValue: AnySchemaInputValue {}

public protocol AllowedAsInputValue {
    func isEqualToType(otherType: AllowedAsInputValue) -> Bool
}

extension AllowedAsInputValue {
    public func isEqualToType(otherType: AllowedAsInputValue) -> Bool { return false }
}

public struct SchemaInputObject: AllowedAsInputValue, AllowedAsNonNull {
    var fields: IdentitySet<SchemaInputValue<Any>>!
}
