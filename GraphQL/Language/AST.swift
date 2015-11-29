struct Document: Subtree {
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

struct OperationDefinition: Definition, Subtree {
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

struct SelectionSet: Subtree {
    let selections: [Selection]
    let location: Location?

    var children: [Node] { return selections.map { $0 as Node } }
}

struct Field: Selection, Subtree, Named {
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

struct FragmentSpread: Fragment, Subtree, Named {
    let name: ValidName
    let directives: [Directive]
    let location: Location?

    var children: [Node] { return directives.map { $0 as Node } }
}

struct FragmentDefinition: Definition, Subtree, Named {
    let name: ValidName
    let typeCondition: NamedType
    let directives: [Directive]
    let selectionSet: SelectionSet
    let location: Location?

    var children: [Node] { return directives.map { $0 as Node } }
}

protocol Value: Node {
}

struct IntValue: Value {
    let value: Int
    let location: Location?
}

struct FloatValue: Value {
    let value: Float
    let location: Location?
}

struct StringValue: Value {
    let value: String
    let location: Location?
}

struct BoolValue: Value {
    let value: Bool
    let location: Location?
}

struct EnumValue: Value {
    let value: String
    let location: Location?
}

struct ArrayValue: Value, Subtree {
    let values: [Value]
    let location: Location?

    var children: [Node] { return values.map { $0 as Node } }
}

struct InputObjectValue: Value {
    // Arguments are unordered, so this could be IdentitySet<InputObjectField> if we enforce the language rule during parsing.
    let fields: [InputObjectField]
    let location: Location?

    var children: [Node] { return fields.map { $0 as Node } }
}

struct InputObjectField: Value, Named {
    let name: ValidName
    let value: Value
    let location: Location?
}

struct VariableDefinition: Definition {
    let variable: Variable
    let type: InputType
    let defaultValue: Value?
    let location: Location?
}

struct Variable: Value, Named {
    let name: ValidName
    let location: Location?
}

protocol InputType: Node { }

struct NamedType: InputType {
    let value: String
    let location: Location?
}

struct NonNullType: InputType {
    let type: InputType
    let location: Location?
}

struct ListType: InputType {
    let type: InputType
    let location: Location?
}

struct Directive: Node, Named {
    let name: ValidName
    let value: Value?
    let location: Location?

    var type: NodeType { return .Directive }
}

protocol Selection: Node {}

protocol Fragment: Selection {}

struct InlineFragment: Fragment, Subtree {
    let typeCondition: NamedType
    let directives: [Directive]
    let selectionSet: SelectionSet
    let location: Location?

    // TODO: Should SelectionSet be included?
    var children: [Node] { return directives.map { $0 as Node } }
}

protocol Node {
    var type: NodeType { get }
}

// TODO: remove this
extension Node {
    var type: NodeType { return .Any }
}

protocol Subtree: Node {
    var children: [Node] { get }
    mutating func removeChildAtIndex(index: Int)
    mutating func replaceChildAtIndex(index: Int, newValue: Node)
}

extension Subtree {
    mutating func removeChildAtIndex(index: Int) {}
    mutating func replaceChildAtIndex(index: Int, newValue: Node) {}
}

public struct Location {
    let start: String.Index
    let end: String.Index
    let source: Source?
}
