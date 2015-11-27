indirect enum SchemaFieldType {
    case NonNull(SchemaFieldType)
    case String
    case List(SchemaFieldType)
    case Enum(SchemaEnum)
    case Interface(SchemaInterface)
    case Object(SchemaObjectType)
}

struct SchemaDirective {

}

struct SchemaField {
    let type: SchemaFieldType
    let description: String?
    let arguments: [String: (type: SchemaFieldType, description: String)]?
    let resolve: (Any -> Any)?

    init(type: SchemaFieldType,
        description: String? = nil,
        arguments: [String: (type: SchemaFieldType, description: String)]? = nil,
        resolve: (Any -> Any)? = nil) {
        self.type = type
        self.description = description
        self.arguments = arguments
        self.resolve = resolve
    }
}

struct SchemaEnum {
    let name: String
    let description: String?
    let values: [String: SchemaEnumValue]
}

struct SchemaEnumValue {
    let value: Int
    let description: String?
}

struct SchemaInterface {
    let name: String
    let description: String?
    let fields: () -> [String: SchemaField]
    let resolveType: Any -> SchemaObjectType

    init(
        name: String,
        description: String? = nil,
        fields: () -> [String: SchemaField],
        resolveType: Any -> SchemaObjectType) {
            self.name = name
            self.description = description
            self.fields = fields
            self.resolveType = resolveType
    }
}

struct SchemaObjectType {
    let name: String
    let description: String?
    let fields: () -> [String: SchemaField]
    let interfaces: [SchemaInterface]

    init(
        name: String,
        description: String? = nil,
        fields: () -> [String: SchemaField],
        interfaces: [SchemaInterface] = []) {
            self.name = name
            self.description = description
            self.fields = fields
            self.interfaces = interfaces
    }
}

public struct Schema {
    let queryType: SchemaObjectType
    let mutationType: SchemaObjectType?
    let subscriptionType: SchemaObjectType?
    let directives: [SchemaDirective]
    let typeMap: Any

    init(
        queryType: SchemaObjectType,
        mutationType: SchemaObjectType? = nil,
        subscriptionType: SchemaObjectType? = nil,
        directives: [SchemaDirective] = [includeDirective, skipDirective]
        ) {
            self.queryType = queryType
            self.mutationType = mutationType
            self.subscriptionType = subscriptionType
            self.directives = directives
            self.typeMap = "" // build typeMap
    }
}

let includeDirective = SchemaDirective()
let skipDirective = SchemaDirective()