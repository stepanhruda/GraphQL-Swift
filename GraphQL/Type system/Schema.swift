public indirect enum SchemaFieldType {
    case Scalar(SchemaScalarType)
    case Object(SchemaObjectType)
    case Interface(SchemaInterface)
    case Union(SchemaUnion)
    case Enum(SchemaEnum)
    case InputObject(SchemaInputObjectType)
    case List(SchemaFieldType)
    case NonNull(SchemaFieldType)
}

public enum SchemaScalarType {
    case String
    case Boolean
}

public indirect enum SchemaInputType {
    case Scalar(SchemaScalarType)
    case Enum(SchemaEnum)
    case InputObject(SchemaInputObjectType)
    case List(SchemaInputType)
    case NonNull(SchemaInputType)
}

public struct SchemaUnion {
    var possibleTypes: [SchemaObjectType] {
        return undefined()
    }
}

public struct SchemaDirective {
    let name: String
    let description: String?
    let arguments: [String: SchemaInputValue]
    let onOperation: Bool
    let onFragment: Bool
    let onField: Bool

    public init(
        name: String,
        description: String? = nil,
        arguments: [String: SchemaInputValue],
        onOperation: Bool = false,
        onFragment: Bool = false,
        onField: Bool = false) {
            self.name = name
            self.description = description
            self.arguments = arguments
            self.onOperation = onOperation
            self.onFragment = onFragment
            self.onField = onField
    }
}

public struct SchemaResolver<DomainLogicType, ReturnType> {
    let resolve: DomainLogicType -> ReturnType
}

public struct SchemaInputValue {
    let description: String?
    let type: SchemaInputType
    /// Perhaps it's possible to restrict the default based on type above?
    let defaultValue: Any?
    var value: Any?

    init(
        type: SchemaInputType,
        description: String? = nil,
        defaultValue: Any? = nil) {
            self.type = type
            self.description = description
            self.defaultValue = defaultValue
    }
}

public struct SchemaField {
    let type: SchemaFieldType
    let description: String?
    let arguments: [String: SchemaInputValue] // identity set would be choice
    let resolve: (Any -> Any?)?
    let deprecationReason: String?

    public init(
        type: SchemaFieldType,
        description: String? = nil,
        arguments: [String: SchemaInputValue] = [:],
        resolve: (Any -> Any?)? = nil,
        deprecationReason: String? = nil) {
            self.type = type
            self.description = description
            self.arguments = arguments
            self.resolve = resolve
            self.deprecationReason = deprecationReason
    }
}

public struct SchemaEnum {
    var values: [SchemaEnumValue] {
        return undefined()
    }
    let name: String
    let description: String?
    let valuesForNames: [String: SchemaEnumValue] // identity set would be choice

    public init(name: String, description: String? = nil, values: [String: SchemaEnumValue]) {
        self.name = name
        self.description = description
        self.valuesForNames = values
    }
}

public struct SchemaEnumValue {
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
}

/// Note that interface is a reference type, because fields can be self-referential etc.
public class SchemaInterface {

    var possibleTypes: [SchemaObjectType] {
        return undefined()
    }

    let name: String
    let description: String?
    var fields: [SchemaField] {
        return undefined()
    }

    lazy var fieldsForNames: [String: SchemaField] = self.lazyFieldsForNames()
    let resolveType: Any -> SchemaObjectType
    private let lazyFieldsForNames: () -> [String: SchemaField] // identity set would be choice

    public init(
        name: String,
        description: String? = nil,
        fields: () -> [String: SchemaField],
        resolveType: Any -> SchemaObjectType) {
            self.name = name
            self.description = description
            self.lazyFieldsForNames = fields
            self.resolveType = resolveType
    }
}

public struct SchemaInputObjectType {
    var fields: [String: SchemaInputValue] {
        return undefined()
    }
}

/// Note that object is a reference type, because fields can be self-referential etc.
public class SchemaObjectType {
    let name: String
    let description: String?
    var fields: [SchemaField] {
        return undefined()
    }

    lazy var fieldsForNames: [String: SchemaField] = self.lazyFieldsForNames()
    let interfaces: [SchemaInterface]

    private let lazyFieldsForNames: () -> [String: SchemaField] // identity set would be choice

    public init(
        name: String,
        description: String? = nil,
        fields: () -> [String: SchemaField],
        interfaces: [SchemaInterface] = []) {
            self.name = name
            self.description = description
            self.lazyFieldsForNames = fields
            self.interfaces = interfaces
    }
}

public struct Schema {
    var types: [SchemaObjectType] {
        return undefined()
        //        return typesForNames.values
    }
    let queryType: SchemaObjectType
    let mutationType: SchemaObjectType?
    let subscriptionType: SchemaObjectType?
    let directives: [SchemaDirective]

    let typesForNames: [String: SchemaObjectType] // identity set would be choice

    public init(
        queryType: SchemaObjectType,
        mutationType: SchemaObjectType? = nil,
        subscriptionType: SchemaObjectType? = nil,
        directives: [SchemaDirective] = [includeDirective, skipDirective]
        ) {
            self.queryType = queryType
            self.mutationType = mutationType
            self.subscriptionType = subscriptionType
            self.directives = directives
            self.typesForNames = undefined() // TODO
    }
}

private let includeDirective: SchemaDirective = undefined()
private let skipDirective: SchemaDirective = undefined()