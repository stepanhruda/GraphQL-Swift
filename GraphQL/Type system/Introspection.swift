class Introspection {

    static let schema = SchemaObjectType(
            name: "__Schema",
            description: "A GraphQL schema defines the capabilities of a GraphQL server. It exposes all available types and directives on the server, as well as the entry points for query, mutation, and subscription operations.",
            fields: { [
                "types": SchemaField(
                    type: .NonNull(.List(.NonNull(.Object(type)))),
                    description: "A list of all types supported by this server.",
                    resolve: { toResolve in
                        let schema = toResolve as! Schema
                        return schema.types }),
                "queryType": SchemaField(
                    type: .NonNull(.Object(type)),
                    description: "The type that query operations will be rooted at.",
                    resolve: { toResolve in
                        let schema = toResolve as! Schema
                        return schema.queryType }),
                "mutationType": SchemaField(
                    type: .Object(type),
                    description: "If this server support mutation, the type that subscription operations will be rooted at.",
                    resolve: { toResolve in
                        let schema = toResolve as! Schema
                        return schema.mutationType }),
                "subscriptionType": SchemaField(
                    type: .Object(type),
                    description: "If this server support subscription, the type that subscription operations will be rooted at.",
                    resolve: { toResolve in
                        let schema = toResolve as! Schema
                        return schema.subscriptionType }),
                "directives": SchemaField(
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
            "name": SchemaField(type: .NonNull(.Scalar(.String))),
            "description": SchemaField(type: .Scalar(.String)),
            "arguments": SchemaField(
                type: .NonNull(.List(.NonNull(.Object(inputValue)))),
                resolve: { toResolve in
                    let directive = toResolve as! SchemaDirective
                    return directive.arguments }),
            "onOperation": SchemaField(type: .Scalar(.Boolean)),
            "onFragment": SchemaField(type: .Scalar(.Boolean)),
            "onField": SchemaField(type: .Scalar(.Boolean)),
            ] })

    // Defined twice for recursive purposes
    static let type: SchemaObjectType = typeDefinition
    static let typeDefinition = SchemaObjectType(
        name: "__Type",
        description: "The fundamental unit of any GraphQL schema is the type. There are many kinds of types in GraphQL as represented by the `__TypeKind` enum.\n\nDepending on the kind of a type, certain fields describe information about that type. Scalar types provide no information beyond a name and description, while Enum types provide their values. Object and Interface types provide the fields they describe. Abstract types, Union and Interface, provide the Object types possible at runtime. List and NonNull types compose other types.",
        fields: { [
            "kind": SchemaField(
                type: .NonNull(.Enum(typeKind)),
                resolve: { toResolve in
                    let fieldType = toResolve as! SchemaFieldType
                    switch fieldType {
                    case .Scalar(_): return TypeKind.Scalar
                    case .Object(_): return TypeKind.Object
                    case .Interface(_): return TypeKind.Interface
                    case .Union(_): return TypeKind.Union
                    case .Enum(_): return TypeKind.Enum
                    case .InputObject(_): return TypeKind.InputObject
                    case .List(_): return TypeKind.List
                    case .NonNull(_): return TypeKind.NonNull
                    } }),
            "name": SchemaField(type: .NonNull(.Scalar(.String))),
            "description": SchemaField(type: .Scalar(.String)),
            "fields": SchemaField(
                type: .List(.NonNull(.Object(field))),
                arguments: [
                    "includeDeprecated": SchemaInputValue(
                        type: .Scalar(.Boolean),
                        defaultValue: false)
                ],
                resolve: { toResolve in
                    let arguments = toResolve as! (type: SchemaFieldType, includeDeprecated: Bool)
                    let fields: [SchemaField]
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
            "interfaces": SchemaField(
                type: .List(.NonNull(.Object(type))),
                resolve: { toResolve in
                    let fieldType = toResolve as! SchemaFieldType
                    switch fieldType {
                    case .Object(let object): return object.interfaces
                    default: return nil
                    } }),
            "possibleTypes": SchemaField(
                type: .List(.NonNull(.Object(type))),
                resolve: { toResolve in
                    let fieldType = toResolve as! SchemaFieldType
                    switch fieldType {
                    case .Interface(let interface): return interface.possibleTypes
                    case .Union(let union): return union.possibleTypes
                    default: return nil
                    }
                }),
            "enumValues": SchemaField(
                type: .List(.NonNull(.Object(enumValue))),
                arguments: [
                    "includeDeprecated": SchemaInputValue(
                        type: .Scalar(.Boolean),
                        defaultValue: false)
                ],
                resolve: { toResolve in
                    let arguments = toResolve as! (type: SchemaFieldType, includeDeprecated: Bool)
                    let values: [SchemaEnumValue]
                    switch arguments.type {
                    case .Enum(let enumType): values = enumType.values
                    default: return nil
                    }
                    switch arguments.includeDeprecated {
                    case true: return values
                    case false: return values.filter { $0.deprecationReason == nil }
                    } }),
            "inputFields": SchemaField(
                type: .List(.NonNull(.Object(inputValue))),
                resolve: { toResolve in
                    let fieldType = toResolve as! SchemaFieldType
                    switch fieldType {
                    case .InputObject(let inputObject): return inputObject.fields
                    default: return nil
                    } }),
            "ofType": SchemaField(type: .Object(type)),
            ] })

    static let field = SchemaObjectType(
        name: "__Field",
        description: "Object and interface types are described by a list of Fields, each of which has a name, potentially a list of arguments, and a return type.",
        fields: { [
            "name": SchemaField(type: .NonNull(.Scalar(.String))),
            "description": SchemaField(type: .Scalar(.String)),
            "arguments": SchemaField(
                type: .NonNull(.List(.NonNull(.Object(inputValue)))),
                resolve: { toResolve in
                    let field = toResolve as! SchemaField
                    return field.arguments } ),
            "type": SchemaField(type: .NonNull(.Object(type))),
            "isDeprecated": SchemaField(
                type: .NonNull(.Scalar(.Boolean)),
                resolve: { toResolve in
                    let field = toResolve as! SchemaField
                    return field.deprecationReason != nil } ),
            "deprecationReason": SchemaField(type: .Scalar(.String)),
            ] })


    static let inputValue = SchemaObjectType(
        name: "__InputValue",
        description: "Arguments provided to Fields or Directives and the input fields of an input object are represented as input values which describe their type and optionally a default value.",
        fields: { [
            "name": SchemaField(type: .NonNull(.Scalar(.String))),
            "description": SchemaField(type: .Scalar(.String)),
            "type": SchemaField(type: .NonNull(.Object(type))),
            "defaultValue": SchemaField(
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
            "name": SchemaField(type: .NonNull(.Scalar(.String))),
            "description": SchemaField(type: .Scalar(.String)),
            "isDeprecated": SchemaField(
                type: .NonNull(.Scalar(.Boolean)),
                resolve: { toResolve in
                    let enumValue = toResolve as! SchemaEnumValue
                    return enumValue.deprecationReason != nil } ),
            "deprecationReason": SchemaField(type: .Scalar(.String)),
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
            TypeKind.Scalar.rawValue: SchemaEnumValue(
                value: TypeKind.Scalar.rawValue,
                description: "Indicates this type is a scalar."),
            TypeKind.Object.rawValue: SchemaEnumValue(
                value: TypeKind.Object.rawValue,
                description: "Indicates this type is an object. `fields` and `interfaces` are valid fields."),
            TypeKind.Interface.rawValue: SchemaEnumValue(
                value: TypeKind.Interface.rawValue,
                description: "Indicates this type is an interface. `fields` and `possibleTypes` are valid fields."),
            TypeKind.Union.rawValue: SchemaEnumValue(
                value: TypeKind.Union.rawValue,
                description: "Indicates this type is a union. `possibleTypes` is a valid field."),
            TypeKind.Enum.rawValue: SchemaEnumValue(
                value: TypeKind.Enum.rawValue,
                description: "Indicates this type is an enum. `enumValues` is a valid field."),
            TypeKind.InputObject.rawValue: SchemaEnumValue(
                value: TypeKind.InputObject.rawValue,
                description: "Indicates this type is an input object. `inputFields` is a valid field."),
            TypeKind.List.rawValue: SchemaEnumValue(
                value: TypeKind.List.rawValue,
                description: "Indicates this type is a list. `ofType` is a valid field."),
            TypeKind.NonNull.rawValue: SchemaEnumValue(
                value: TypeKind.NonNull.rawValue,
                description: "Indicates this type is a non-null. `ofType` is a valid field."),
        ])

    // TODO: name: "__schema"
    static let schemaMetaField = SchemaField(
        type: .NonNull(.Object(schema)),
        description: "Access the current type schema of this server.",
        arguments: [:],
        resolve: { toResolve in
            let input = toResolve as! (source: Source, arguments: [String: SchemaInputValue], userSchema: Schema)
            return input.userSchema } )

    // TODO: name: "__type"
    static let typeMetaField = SchemaField(
        type: .Object(type),
        description: "Request the type information of a single type.",
        arguments: [
            "name": SchemaInputValue(type: .NonNull(.Scalar(.String))),
        ],
        resolve: { toResolve in
            let input = toResolve as! (source: Source, arguments: [String: SchemaInputValue], userSchema: Schema)
            let name = input.arguments["name"]!.value as! String
            return input.userSchema.typesForNames[name] } )

    // TODO: name: "__typename"
    static let typeNameMetaField = SchemaField(
        type: .NonNull(.Scalar(.String)),
        description: "The name of the current Object type at runtime.",
        arguments: [:],
        resolve: { toResolve in
            let input = toResolve as! (source: Source, arguments: [String: SchemaInputValue], parentType: SchemaObjectType)
            return input.parentType.name } )
}
