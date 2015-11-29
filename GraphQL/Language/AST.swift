protocol Node {
    var type: NodeType { get }
    var location: Location? { get }
}

protocol HasSubtree: Node {
    var children: [Node] { get }

    // Possibly remove this if we don't allow editing the AST through a visitor
    mutating func removeChildAtIndex(index: Int)
    mutating func replaceChildAtIndex(index: Int, newValue: Node)
}

struct Document: HasSubtree {
    var definitions: [Definition]
    let location: Location?

    var type: NodeType { return .Document }

    var children: [Node] { return definitions.map { $0 as Node } }

    mutating func removeChildAtIndex(index: Int) {
        definitions.removeAtIndex(index)
    }
    mutating func replaceChildAtIndex(index: Int, newValue: Node) {
        definitions[index] = newValue as! Definition
    }
}

protocol Definition: Node {}

struct OperationDefinition: Definition, HasSubtree {
    let operationType: OperationType
    let name: ValidName?
    let variableDefinitions: [VariableDefinition]
    let directives: [Directive]
    let selectionSet: SelectionSet
    let location: Location?

    var type: NodeType { return .OperationDefinition }

    var children: [Node] { return variableDefinitions.map { $0 as Node } + directives.map { $0 as Node } + [selectionSet] }
}

enum OperationType {
    case Query
    case Mutation
}

protocol Selection: Node {}

struct SelectionSet: HasSubtree {
    let selections: [Selection]
    let location: Location?

    var type: NodeType { return .SelectionSet }

    var children: [Node] { return selections.map { $0 as Node } }
}

struct Field: Selection, HasSubtree, Named {
    let alias: ValidName?
    let name: ValidName
    // Arguments are unordered, so this could be IdentitySet<Argument> if we enforce the language rule during parsing.
    let arguments: [Argument]
    let directives: [Directive]
    let selectionSet: SelectionSet?
    let location: Location?

    var children: [Node] {
        var children = arguments.map { $0 as Node } + directives.map { $0 as Node }
        if let selectionSet = selectionSet {
            children.append(selectionSet)
        }
        return children
    }

    var type: NodeType { return .Field }
}

struct Argument: Node, Named {
    let name: ValidName
    let value: Value
    let location: Location?

    var type: NodeType { return .Argument }
}

struct FragmentDefinition: Definition, HasSubtree, Named {
    let name: ValidName
    let typeCondition: NamedType
    let directives: [Directive]
    let selectionSet: SelectionSet
    let location: Location?

    var type: NodeType { return .FragmentDefinition }

    var children: [Node] { return directives.map { $0 as Node } + [selectionSet] }
}

protocol Fragment: Selection {}

struct FragmentSpread: Fragment, HasSubtree, Named {
    let name: ValidName
    let directives: [Directive]
    let location: Location?

    var type: NodeType { return .FragmentSpread }

    var children: [Node] { return directives.map { $0 as Node } }
}

struct InlineFragment: Fragment, HasSubtree {
    let typeCondition: NamedType?
    let directives: [Directive]
    let selectionSet: SelectionSet
    let location: Location?

    var type: NodeType { return .InlineFragment }

    var children: [Node] { return directives.map { $0 as Node } + [selectionSet] }
}

protocol Value: Node {
}

struct IntValue: Value {
    let value: Int
    let location: Location?

    var type: NodeType { return .IntValue }
}

struct FloatValue: Value {
    let value: Float
    let location: Location?

    var type: NodeType { return .FloatValue }
}

struct StringValue: Value {
    let value: String
    let location: Location?

    var type: NodeType { return .StringValue }
}

struct BoolValue: Value {
    let value: Bool
    let location: Location?

    var type: NodeType { return .BoolValue }
}

struct EnumValue: Value {
    let value: String
    let location: Location?

    var type: NodeType { return .EnumValue }
}

struct ListValue: Value, HasSubtree {
    let values: [Value]
    let location: Location?

    var type: NodeType { return .ListValue }

    var children: [Node] { return values.map { $0 as Node } }
}

struct InputObjectValue: Value {
    // Arguments are unordered, so this could be IdentitySet<InputObjectField> if we enforce the language rule during parsing.
    let fields: [InputObjectField]
    let location: Location?

    var type: NodeType { return .InputObjectValue }

    var children: [Node] { return fields.map { $0 as Node } }
}

struct InputObjectField: Value, Named {
    let name: ValidName
    let value: Value
    let location: Location?

    var type: NodeType { return .InputObjectField }
}

struct VariableDefinition: Definition {
    let variable: Variable
    let inputType: InputType
    let defaultValue: Value?
    let location: Location?

    var type: NodeType { return .VariableDefinition }
}

struct Variable: Value, Named {
    let name: ValidName
    let location: Location?

    var type: NodeType { return .Variable }
}

protocol InputType: Node { }

struct NamedType: InputType {
    let value: String
    let location: Location?

    var type: NodeType { return .NamedType }
}

struct NonNullType: InputType {
    let inputType: InputType
    let location: Location?

    var type: NodeType { return .NonNullType }
}

struct ListType: InputType {
    let inputType: InputType
    let location: Location?

    var type: NodeType { return .ListType }
}

struct Directive: Node, Named {
    let name: ValidName
    let arguments: [Argument]
    let location: Location?

    var type: NodeType { return .Directive }
}

extension HasSubtree {
    mutating func removeChildAtIndex(index: Int) {}
    mutating func replaceChildAtIndex(index: Int, newValue: Node) {}
}

public struct Location {
    let start: String.Index
    let end: String.Index
    let source: Source?
}
