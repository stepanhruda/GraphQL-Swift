class Introspection {

    static let schema = SchemaObjectType(
            name: "__Schema",
            description: "A GraphQL schema defines the capabilities of a GraphQL server. It exposes all available types and directives on the server, as well as the entry points for query, mutation, and subscription operations.",
            fields: { [
                SchemaObjectField(
                    name: "types",
                    type: .NonNull(.List(.NonNull(.Object(type)))),
                    description: "A list of all types supported by this server.",
                    resolve: { toResolve in
                        let schema = toResolve as! Schema
                        return schema.types }),
                SchemaObjectField(
                    name: "queryType",
                    type: .NonNull(.Object(type)),
                    description: "The type that query operations will be rooted at.",
                    resolve: { toResolve in
                        let schema = toResolve as! Schema
                        return schema.queryType }),
                SchemaObjectField(
                    name: "mutationType",
                    type: .Object(type),
                    description: "If this server support mutation, the type that subscription operations will be rooted at.",
                    resolve: { toResolve in
                        let schema = toResolve as! Schema
                        return schema.mutationType }),
                SchemaObjectField(
                    name: "subscriptionType",
                    type: .Object(type),
                    description: "If this server support subscription, the type that subscription operations will be rooted at.",
                    resolve: { toResolve in
                        let schema = toResolve as! Schema
                        return schema.subscriptionType }),
                SchemaObjectField(
                    name: "directives",
                    type: .NonNull(.List(.NonNull(.Object(directive)))),
                    description: "",
                    resolve: { toResolve in
                        let schema = toResolve as! Schema
                        return schema.directives }),
                ] }
        )

    static let directive = SchemaObjectType(
        name: "__Directive",
        description: "A directive provides a way to describe alternate runtime execution and type validation behavior in a GraphQL document. \n\nIn some cases, you need to provide options to alter GraphQL’s execution behavior in ways field arguments will not suffice, such as conditionally including or skipping a field. Directives provide this by describing additional information to the executor.",
        fields: { [
            SchemaObjectField(name: "name", type: .NonNull(.Scalar(.String))),
            SchemaObjectField(name: "description", type: .Scalar(.String)),
            SchemaObjectField(
                name: "arguments",
                type: .NonNull(.List(.NonNull(.Object(inputValue)))),
                resolve: { toResolve in
                    let directive = toResolve as! SchemaDirective
                    return directive.arguments }),
            SchemaObjectField(name: "onOperation", type: .Scalar(.Boolean)),
            SchemaObjectField(name: "onFragment", type: .Scalar(.Boolean)),
            SchemaObjectField(name: "onField", type: .Scalar(.Boolean)),
            ] })

    // Defined twice for recursive purposes
    static let type: SchemaObjectType = typeDefinition
    static let typeDefinition = SchemaObjectType(
        name: "__Type",
        description: "The fundamental unit of any GraphQL schema is the type. There are many kinds of types in GraphQL as represented by the `__TypeKind` enum.\n\nDepending on the kind of a type, certain fields describe information about that type. Scalar types provide no information beyond a name and description, while Enum types provide their values. Object and Interface types provide the fields they describe. Abstract types, Union and Interface, provide the Object types possible at runtime. List and NonNull types compose other types.",
        fields: { [
            SchemaObjectField(
                name: "kind",
                type: .NonNull(.Enum(typeKind)),
                resolve: { toResolve in
                    let fieldType = toResolve as! SchemaObjectFieldType
                    switch fieldType {
                    case .Scalar(_): return TypeKind.Scalar
                    case .Object(_): return TypeKind.Object
                    case .Interface(_): return TypeKind.Interface
                    case .Union(_): return TypeKind.Union
                    case .Enum(_): return TypeKind.Enum
                    //TODO case .InputObject(_): return TypeKind.InputObject
                    case .List(_): return TypeKind.List
                    case .NonNull(_): return TypeKind.NonNull
                    } }),
            SchemaObjectField(name: "name", type: .NonNull(.Scalar(.String))),
            SchemaObjectField(name: "description", type: .Scalar(.String)),
            SchemaObjectField(
                name: "fields",
                type: .List(.NonNull(.Object(field))),
                arguments: [
                    SchemaInputValue(
                        name: "includeDeprecated",
                        type: .Scalar(.Boolean),
                        defaultValue: false)
                ],
                resolve: { toResolve in
                    let arguments = toResolve as! (type: SchemaObjectFieldType, includeDeprecated: Bool)
                    let fields: IdentitySet<SchemaObjectField>
                    switch arguments.type {
                    case .Object(let object):
                        fields = object.fields
                    case .Interface(let interface):
                        fields = interface.fields
                    default: return nil
                    }
                    switch arguments.includeDeprecated {
                    case true: return fields
                    case false: return fields.filter { $0.deprecationReason == nil }
                    } }),
            SchemaObjectField(
                name: "interfaces",
                type: .List(.NonNull(.Object(type))),
                resolve: { toResolve in
                    let fieldType = toResolve as! SchemaObjectFieldType
                    switch fieldType {
                    case .Object(let object): return object.interfaces
                    default: return nil
                    } }),
            SchemaObjectField(
                name: "possibleTypes",
                type: .List(.NonNull(.Object(type))),
                resolve: { toResolve in
                    let fieldType = toResolve as! SchemaObjectFieldType
                    switch fieldType {
                    case .Interface(let interface): return interface.possibleTypes
                    case .Union(let union): return union.possibleTypes
                    default: return nil
                    }
                }),
            SchemaObjectField(
                name: "enumValues",
                type: .List(.NonNull(.Object(enumValue))),
                arguments: [
                    SchemaInputValue(
                        name: "includeDeprecated",
                        type: .Scalar(.Boolean),
                        defaultValue: false)
                ],
                resolve: { toResolve in
                    let arguments = toResolve as! (type: SchemaObjectFieldType, includeDeprecated: Bool)
                    let values: IdentitySet<SchemaEnumValue>
                    switch arguments.type {
                    case .Enum(let enumType): values = enumType.values
                    default: return nil
                    }
                    switch arguments.includeDeprecated {
                    case true: return values
                    case false: return values.filter { $0.deprecationReason == nil }
                    } }),
            SchemaObjectField(
                name: "inputFields",
                type: .List(.NonNull(.Object(inputValue))),
                resolve: { toResolve in
                    let fieldType = toResolve as! SchemaObjectFieldType
                    switch fieldType {
                    //TODO: case .InputObject(let inputObject): return inputObject.fields
                    default: return nil
                    } }),
            SchemaObjectField(name: "ofType", type: .Object(type)),
            ] })

    static let field = SchemaObjectType(
        name: "__Field",
        description: "Object and interface types are described by a list of Fields, each of which has a name, potentially a list of arguments, and a return type.",
        fields: { [
            SchemaObjectField(name: "name", type: .NonNull(.Scalar(.String))),
            SchemaObjectField(name: "description", type: .Scalar(.String)),
            SchemaObjectField(
                name: "arguments",
                type: .NonNull(.List(.NonNull(.Object(inputValue)))),
                resolve: { toResolve in
                    let field = toResolve as! SchemaObjectField
                    return field.arguments } ),
            SchemaObjectField(name: "type", type: .NonNull(.Object(type))),
            SchemaObjectField(
                name: "isDeprecated",
                type: .NonNull(.Scalar(.Boolean)),
                resolve: { toResolve in
                    let field = toResolve as! SchemaObjectField
                    return field.deprecationReason != nil } ),
            SchemaObjectField(name: "deprecationReason", type: .Scalar(.String)),
            ] })


    static let inputValue = SchemaObjectType(
        name: "__InputValue",
        description: "Arguments provided to Fields or Directives and the input fields of an input object are represented as input values which describe their type and optionally a default value.",
        fields: { [
            SchemaObjectField(name: "name", type: .NonNull(.Scalar(.String))),
            SchemaObjectField(name: "description", type: .Scalar(.String)),
            SchemaObjectField(name: "type", type: .NonNull(.Object(type))),
            SchemaObjectField(
                name: "defaultValue",
                type: .Scalar(.String), // Why is this a string?
                description: "A GraphQL-formatted string representing the default value for this input value.",
                resolve: { toResolve in
                    let inputValue = toResolve as! SchemaInputValue
                    // TODO: Reference implementation converts this to a GraphQL valid object
                    return inputValue.defaultValue } ),
            ] })

    static let enumValue = SchemaObjectType(
        name: "__EnumValue",
        description: "One possible value for a given enum. Enum values are unique values, not a placeholder for a string or numeric value. However an enum value is returned in a JSON response as a string.",
        fields: { [
            SchemaObjectField(name: "name", type: .NonNull(.Scalar(.String))),
            SchemaObjectField(name: "description", type: .Scalar(.String)),
            SchemaObjectField(
                name: "isDeprecated",
                type: .NonNull(.Scalar(.Boolean)),
                resolve: { toResolve in
                    let enumValue = toResolve as! SchemaEnumValue
                    return enumValue.deprecationReason != nil } ),
            SchemaObjectField(name: "deprecationReason", type: .Scalar(.String)),
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

    static let typeKind = SchemaEnum(
        name: "__TypeKind",
        description: "An enum describing what kind of type a given `__Type` is.",
        values: [
            SchemaEnumValue(
                value: TypeKind.Scalar.rawValue,
                description: "Indicates this type is a scalar."),
            SchemaEnumValue(
                value: TypeKind.Object.rawValue,
                description: "Indicates this type is an object. `fields` and `interfaces` are valid fields."),
            SchemaEnumValue(
                value: TypeKind.Interface.rawValue,
                description: "Indicates this type is an interface. `fields` and `possibleTypes` are valid fields."),
            SchemaEnumValue(
                value: TypeKind.Union.rawValue,
                description: "Indicates this type is a union. `possibleTypes` is a valid field."),
            SchemaEnumValue(
                value: TypeKind.Enum.rawValue,
                description: "Indicates this type is an enum. `enumValues` is a valid field."),
            SchemaEnumValue(
                value: TypeKind.InputObject.rawValue,
                description: "Indicates this type is an input object. `inputFields` is a valid field."),
            SchemaEnumValue(
                value: TypeKind.List.rawValue,
                description: "Indicates this type is a list. `ofType` is a valid field."),
            SchemaEnumValue(
                value: TypeKind.NonNull.rawValue,
                description: "Indicates this type is a non-null. `ofType` is a valid field."),
        ])

    static let schemaMetaField = SchemaObjectField(
        name: "__schema",
        type: .NonNull(.Object(schema)),
        description: "Access the current type schema of this server.",
        arguments: [],
        resolve: { toResolve in
            let input = toResolve as! (source: Source, arguments: IdentitySet<SchemaInputValue>, userSchema: Schema)
            return input.userSchema } )

    static let typeMetaField = SchemaObjectField(
        name: "__type",
        type: .Object(type),
        description: "Request the type information of a single type.",
        arguments: [
            SchemaInputValue(name: "name", type: .NonNull(.Scalar(.String))),
        ],
        resolve: { toResolve in
            let input = toResolve as! (source: Source, arguments: IdentitySet<SchemaInputValue>, userSchema: Schema)
            let name = input.arguments["name"]!.value as! String
            return input.userSchema.types[name] } )

    static let typeNameMetaField = SchemaObjectField(
        name: "__typename",
        type: .NonNull(.Scalar(.String)),
        description: "The name of the current Object type at runtime.",
        arguments: [],
        resolve: { toResolve in
            let input = toResolve as! (source: Source, arguments: IdentitySet<SchemaInputValue>, parentType: SchemaObjectType)
            return input.parentType.name } )
}
