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

protocol Definition: Node {
}

struct OperationDefinition: Definition, Subtree {
    let operation: String
    let name: Name?
    let variableDefinitions: [VariableDefinition]?
    let directives: [Directive]
    let selectionSet: SelectionSet
    let location: Location?

    var type: NodeType { return .OperationDefinition }

    var children: [Node] { return directives.map { $0 as Node } + selectionSet.children }
}

struct Directive: Node {
    let name: Name
    let value: Value?
    let location: Location?

    var type: NodeType { return .Directive }
}

struct FragmentDefinition: Definition, Subtree {
    let name: Name
    let typeCondition: Name
    let directives: [Directive]
    let selectionSet: SelectionSet
    let location: Location?

    var children: [Node] { return directives.map { $0 as Node } }
}

struct VariableDefinition: Definition {
    let variable: Variable
    let type: Any
    let defaultValue: Value?
    let location: Location?
}

public struct Name: Node, Identifiable {
    let value: String
    let location: Location?

    public var identifier: String { return value }
}

public func ==(a: Name, b: Name) -> Bool {
    return a.value == b.value
}

extension Name: Hashable {
    public var hashValue: Int { return value.hashValue }
}

protocol Value: Node {
    
}

protocol Selection: Node {

}

protocol Fragment: Selection {

}

struct SelectionSet: Subtree {
    let selections: [Selection]
    let location: Location?

    var children: [Node] { return selections.map { $0 as Node } }
}

struct Array: Value, Subtree {
    let values: [Value]
    let location: Location?

    var children: [Node] { return values.map { $0 as Node } }
}

struct Object: Value {
    let fields: [ObjectField]
    let location: Location?

    var children: [Node] { return fields.map { $0 as Node } }
}

struct ObjectField: Value {
    let name: Name
    let value: Value
    let location: Location?
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

struct Variable: Value {
    let value: Name
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

struct Field: Selection, Subtree {
    let alias: Name?
    let name: Name
    let arguments: [Argument]
    let directives: [Directive]
    let selectionSet: SelectionSet?
    let location: Location?

    var children: [Node] { return directives.map { $0 as Node } + arguments.map { $0 as Node } }

    var type: NodeType { return .Field }
}

struct FragmentSpread: Fragment, Subtree {
    let name: Name
    let directives: [Directive]
    let location: Location?

    var children: [Node] { return directives.map { $0 as Node } }
}

struct InlineFragment: Fragment, Subtree {
    let typeCondition: Name
    let directives: [Directive]
    let selectionSet: SelectionSet
    let location: Location?

    // TODO: Should SelectionSet be included?
    var children: [Node] { return directives.map { $0 as Node } }
}

struct Argument: Node {
    let name: Name
    let value: Value
    let location: Location?

    var type: NodeType { return .Argument }
}

protocol Type: Node { }

struct NamedType: Type {
    let value: String
    let location: Location?
}

struct NonNullType: Type {
    let type: Type
    let location: Location?
}

struct ListType: Type {
    let type: Type
    let location: Location?
}
