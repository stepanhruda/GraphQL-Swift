indirect enum GraphQLFieldType {
    case NonNull(GraphQLFieldType)
    case String
    case List(GraphQLFieldType)
    case Enum(GraphQLEnum)
    case Interface(GraphQLInterface)
    case Object(GraphQLObjectType)
}

struct GraphQLDirective {

}

struct GraphQLField {
    let type: GraphQLFieldType
    let description: String?
    let arguments: [String: (type: GraphQLFieldType, description: String)]?
    let resolve: (Any -> Any)?

    init(type: GraphQLFieldType,
        description: String? = nil,
        arguments: [String: (type: GraphQLFieldType, description: String)]? = nil,
        resolve: (Any -> Any)? = nil) {
        self.type = type
        self.description = description
        self.arguments = arguments
        self.resolve = resolve
    }
}

struct GraphQLEnum {
    let name: String
    let description: String?
    let values: [String: GraphQLEnumValue]
}

struct GraphQLEnumValue {
    let value: Int
    let description: String?
}

struct GraphQLInterface {
    let name: String
    let description: String?
    let fields: () -> [String: GraphQLField]
    let resolveType: Any -> GraphQLObjectType

    init(
        name: String,
        description: String? = nil,
        fields: () -> [String: GraphQLField],
        resolveType: Any -> GraphQLObjectType) {
            self.name = name
            self.description = description
            self.fields = fields
            self.resolveType = resolveType
    }
}

struct GraphQLObjectType {
    let name: String
    let description: String?
    let fields: () -> [String: GraphQLField]
    let interfaces: [GraphQLInterface]

    init(
        name: String,
        description: String? = nil,
        fields: () -> [String: GraphQLField],
        interfaces: [GraphQLInterface] = []) {
            self.name = name
            self.description = description
            self.fields = fields
            self.interfaces = interfaces
    }
}

public struct Schema {
    let queryType: GraphQLObjectType
    let mutationType: GraphQLObjectType?
    let subscriptionType: GraphQLObjectType?
    let directives: [GraphQLDirective]
    let typeMap: Any

    init(
        queryType: GraphQLObjectType,
        mutationType: GraphQLObjectType? = nil,
        subscriptionType: GraphQLObjectType? = nil,
        directives: [GraphQLDirective] = [includeDirective, skipDirective]
        ) {
            self.queryType = queryType
            self.mutationType = mutationType
            self.subscriptionType = subscriptionType
            self.directives = directives
            self.typeMap = "" // build typeMap
    }
}

let includeDirective = GraphQLDirective()
let skipDirective = GraphQLDirective()