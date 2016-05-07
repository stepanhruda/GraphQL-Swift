final class Introspection {

    static let schema = SchemaObject(
            name: "__Schema",
            description: "A GraphQL schema defines the capabilities of a GraphQL server. It exposes all available types and directives on the server, as well as the entry points for query, mutation, and subscription operations.",
            fields: { [
                SchemaObjectField(
                    name: "types",
                    type: NonNull(List(NonNull(type))),
                    description: "A list of all types supported by this server.",
                    resolve: { toResolve in
                        let schema = toResolve as! Schema
                        return schema.types }),
                SchemaObjectField(
                    name: "queryType",
                    type: NonNull(type),
                    description: "The type that query operations will be rooted at.",
                    resolve: { toResolve in
                        let schema = toResolve as! Schema
                        return schema.queryType }),
                SchemaObjectField(
                    name: "mutationType",
                    type: type,
                    description: "If this server support mutation, the type that subscription operations will be rooted at.",
                    resolve: { toResolve in
                        let schema = toResolve as! Schema
                        return schema.mutationType }),
                SchemaObjectField(
                    name: "subscriptionType",
                    type: type,
                    description: "If this server support subscription, the type that subscription operations will be rooted at.",
                    resolve: { toResolve in
                        let schema = toResolve as! Schema
                        return schema.subscriptionType }),
                SchemaObjectField(
                    name: "directives",
                    type: NonNull(List(NonNull(directive))),
                    description: "A list of all directives supported by this server.",
                    resolve: { toResolve in
                        let schema = toResolve as! Schema
                        return schema.directives }),
                ] }
        )

    static let directive = SchemaObject(
        name: "__Directive",
        description: "A directive provides a way to describe alternate runtime execution and type validation behavior in a GraphQL document. \n\nIn some cases, you need to provide options to alter GraphQL’s execution behavior in ways field arguments will not suffice, such as conditionally including or skipping a field. Directives provide this by describing additional information to the executor.",
        fields: { [
            SchemaObjectField(name: "name", type: NonNull(StringType())),
            SchemaObjectField(name: "description", type: StringType()),
            SchemaObjectField(
                name: "arguments",
                type: NonNull(List(NonNull(inputValue))),
                resolve: { toResolve in
                    let directive = toResolve as! SchemaDirective
                    return directive.arguments }),
            SchemaObjectField(name: "onOperation", type: Boolean()),
            SchemaObjectField(name: "onFragment", type: Boolean()),
            SchemaObjectField(name: "onField", type: Boolean()),
            ] })

    // Defined twice for recursive purposes
    static let type: SchemaObject = typeDefinition
    static let typeDefinition = SchemaObject(
        name: "__Type",
        description: "The fundamental unit of any GraphQL schema is the type. There are many kinds of types in GraphQL as represented by the `__TypeKind` enum.\n\nDepending on the kind of a type, certain fields describe information about that type. Scalar types provide no information beyond a name and description, while Enum types provide their values. Object and Interface types provide the fields they describe. Abstract types, Union and Interface, provide the Object types possible at runtime. List and NonNull types compose other types.",
        fields: { [
            SchemaObjectField(
                name: "kind",
                type: NonNull(typeKind),
                resolve: { toResolve -> TypeKind in
                    switch toResolve {
                    case is SchemaScalar: return .Scalar
                    case is SchemaObject: return .Object
                    case is SchemaInterface: return .Interface
                    case is SchemaUnion: return .Union
                    case is AnySchemaEnum: return .Enum
                    case is SchemaInputObject: return .InputObject
                    case is List: return .List
                    case is NonNull: return .NonNull
                    default: fatalError("type of unknown kind")
                    } }),
            SchemaObjectField(name: "name", type: NonNull(StringType())),
            SchemaObjectField(name: "description", type: StringType()),
            SchemaObjectField(
                name: "fields",
                type: List(NonNull(field)),
                arguments: [
                    SchemaInputValue(
                        name: "includeDeprecated",
                        type: Boolean(),
                        defaultValue: false)
                ],
                resolve: { toResolve in
                    let arguments = toResolve as! (type: SchemaType, includeDeprecated: Bool)
                    let fields: IdentitySet<SchemaObjectField>
                    switch arguments.type {
                    case let object as SchemaObject: fields = object.fields
                    case let interface as SchemaInterface: fields = interface.fields
                    default: return nil
                    }
                    switch arguments.includeDeprecated {
                    case true: return fields
                    case false: return fields.filter { $0.deprecationReason == nil }
                    } }),
            SchemaObjectField(
                name: "interfaces",
                type: List(NonNull(type)),
                resolve: { toResolve in
                    let object = toResolve as? SchemaObject
                    return object?.interfaces
                    }),
            SchemaObjectField(
                name: "possibleTypes",
                type: List(NonNull(type)),
                resolve: { toResolve in
                    switch toResolve {
                    case let interface as SchemaInterface: return interface.possibleTypes
                    case let union as SchemaUnion: return union.possibleTypes
                    default: return nil
                    }
                }),
            SchemaObjectField(
                name: "enumValues",
                type: List(NonNull(enumValue)),
                arguments: [
                    SchemaInputValue(
                        name: "includeDeprecated",
                        type: Boolean(),
                        defaultValue: false)
                ],
                resolve: { toResolve in
                    let arguments = toResolve as! (type: SchemaType, includeDeprecated: Bool)
                    guard let schemaEnum = arguments.type as? AnySchemaEnum else { return nil }
                    switch arguments.includeDeprecated {
                    case true: return schemaEnum.allValues
                    case false: return schemaEnum.nonDeprecatedValues
                    } }),
            SchemaObjectField(
                name: "inputFields",
                type: List(NonNull(inputValue)),
                resolve: { toResolve in
                    let inputObject = toResolve as? SchemaInputObject
                    return inputObject?.fields
                }),
            SchemaObjectField(name: "ofType", type: type),
            ] })

    static let field = SchemaObject(
        name: "__Field",
        description: "Object and interface types are described by a list of Fields, each of which has a name, potentially a list of arguments, and a return type.",
        fields: { [
            SchemaObjectField(name: "name", type: NonNull(StringType())),
            SchemaObjectField(name: "description", type: StringType()),
            SchemaObjectField(
                name: "arguments",
                type: NonNull(List(NonNull(inputValue))),
                resolve: { toResolve in
                    let field = toResolve as! SchemaObjectField
                    return field.arguments } ),
            SchemaObjectField(name: "type", type: NonNull(type)),
            SchemaObjectField(
                name: "isDeprecated",
                type: NonNull(Boolean()),
                resolve: { toResolve in
                    let field = toResolve as! SchemaObjectField
                    return field.deprecationReason != nil } ),
            SchemaObjectField(name: "deprecationReason", type: StringType()),
            ] })


    static let inputValue = SchemaObject(
        name: "__InputValue",
        description: "Arguments provided to Fields or Directives and the input fields of an input object are represented as input values which describe their type and optionally a default value.",
        fields: { [
            SchemaObjectField(name: "name", type: NonNull(StringType())),
            SchemaObjectField(name: "description", type: StringType()),
            SchemaObjectField(name: "type", type: NonNull(type)),
            SchemaObjectField(
                name: "defaultValue",
                type: StringType(), // Why is this a string?
                description: "A GraphQL-formatted string representing the default value for this input value.",
                resolve: { toResolve in
                    let inputValue = toResolve as! SchemaInputValue
                    // TODO: Reference implementation converts this to a GraphQL valid object
                    return inputValue.defaultValue } ),
            ] })

    static let enumValue = SchemaObject(
        name: "__EnumValue",
        description: "One possible value for a given enum. Enum values are unique values, not a placeholder for a string or numeric value. However an enum value is returned in a JSON response as a string.",
        fields: { [
            SchemaObjectField(name: "name", type: NonNull(StringType())),
            SchemaObjectField(name: "description", type: StringType()),
            SchemaObjectField(
                name: "isDeprecated",
                type: NonNull(Boolean()),
                resolve: { toResolve in
                    let enumValue = toResolve as! AnySchemaEnumValue
                    return enumValue.deprecationReason != nil } ),
            SchemaObjectField(name: "deprecationReason", type: StringType()),
            ] })

    enum TypeKind: String {
        case Scalar = "SCALAR"
        case Object = "OBJECT"
        case Interface = "INTERFACE"
        case Union = "UNION"
        case Enum = "ENUM"
        case InputObject = "INPUT_OBJECT"
        case List = "LIST"
        case NonNull = "NON_NULL"
    }

    static let typeKind = SchemaEnum<TypeKind>(
        name: "__TypeKind",
        description: "An enum describing what kind of type a given `__Type` is.",
        values: [
            SchemaEnumValue(
                value: .Scalar,
                description: "Indicates this type is a scalar."),
            SchemaEnumValue(
                value: .Object,
                description: "Indicates this type is an object. `fields` and `interfaces` are valid fields."),
            SchemaEnumValue(
                value: .Interface,
                description: "Indicates this type is an interface. `fields` and `possibleTypes` are valid fields."),
            SchemaEnumValue(
                value: .Union,
                description: "Indicates this type is a union. `possibleTypes` is a valid field."),
            SchemaEnumValue(
                value: .Enum,
                description: "Indicates this type is an enum. `enumValues` is a valid field."),
            SchemaEnumValue(
                value: .InputObject,
                description: "Indicates this type is an input object. `inputFields` is a valid field."),
            SchemaEnumValue(
                value: .List,
                description: "Indicates this type is a list. `ofType` is a valid field."),
            SchemaEnumValue(
                value: .NonNull,
                description: "Indicates this type is a non-null. `ofType` is a valid field."),
        ])

    static let schemaMetaField = SchemaObjectField(
        name: "__schema",
        type: NonNull(schema),
        description: "Access the current type schema of this server.",
        arguments: [],
        resolve: { toResolve in
            let input = toResolve as! (source: Source, arguments: IdentitySet<SchemaInputValue>, userSchema: Schema)
            return input.userSchema } )

    static let typeMetaField = SchemaObjectField(
        name: "__type",
        type: type,
        description: "Request the type information of a single type.",
        arguments: [
            SchemaInputValue(name: "name", type: NonNull(StringType())),
        ],
        resolve: { toResolve in
            let input = toResolve as! (source: Source, arguments: IdentitySet<SchemaInputValue>, userSchema: Schema)
            let name = input.arguments["name"]!.value as! String
            return input.userSchema.types[name] } )

    static let typeNameMetaField = SchemaObjectField(
        name: "__typename",
        type: NonNull(StringType()),
        description: "The name of the current Object type at runtime.",
        arguments: [],
        resolve: { toResolve in
            let input = toResolve as! (source: Source, arguments: IdentitySet<SchemaInputValue>, parentType: SchemaObject)
            return input.parentType.name } )
}
