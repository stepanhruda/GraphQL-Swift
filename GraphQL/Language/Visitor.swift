
enum VisitAction {
    case Continue
    case Stop
    /// Skip doesn't make sense when returned from a "leave" closure and causes a fatal error.
    case SkipHasSubtree
    case ReplaceValue(Node)
    case RemoveValue
}

enum NodeType: String {
    case Any
    case Document
    case OperationDefinition
    case FragmentDefinition
    case FragmentSpread
    case Field
    case Directive
    case Argument
    case VariableDefinition
    case SelectionSet
    case InlineFragment
    case IntValue
    case FloatValue
    case StringValue
    case BoolValue
    case EnumValue
    case ListValue
    case InputObjectValue
    case InputObjectField
    case Variable
    case NamedType
    case NonNullType
    case ListType


    var identifier: String { return rawValue }
}

enum VisitError: ErrorType {
    case SkipHasSubtree
    case Stop
}

struct Visitor: Identifiable {
    let nodeType: NodeType
    let enter: (Node throws -> VisitAction)?
    let leave: (Node throws -> VisitAction)?

    init(nodeType: NodeType, enter: (Node throws -> VisitAction)? = nil, leave: (Node throws -> VisitAction)? = nil) {
        self.nodeType = nodeType
        self.enter = enter
        self.leave = leave
    }

    var identifier: String {
        return nodeType.identifier
    }
}

extension Node {
    func visit(visitor: Visitor) throws -> Node? {

        guard var afterEntering = try enter(visitor) else { return nil }

        if var tree = afterEntering as? HasSubtree {
            try tree.visitChildren(visitor)
            afterEntering = tree
        }

        guard let afterLeaving = try afterEntering.leave(visitor) else { return nil }

        return afterLeaving
    }

    private func enter(visitor: Visitor) throws -> Node? {
        guard let enter = visitor.enter else { return self }

        switch try enter(self) {
        case .Continue: return self
        case .Stop: throw VisitError.Stop
        case .SkipHasSubtree: throw VisitError.SkipHasSubtree
        case .ReplaceValue(let newValue): return newValue
        case .RemoveValue: return nil
        }
    }

    private func leave(visitor: Visitor) throws -> Node? {
        guard let leave = visitor.leave else { return self }

        switch try leave(self) {
        case .Continue: return self
        case .Stop: throw VisitError.Stop
        case .SkipHasSubtree: fatalError("Developer error: there is no point in skipping a subtree after it has been visited")
        case .ReplaceValue(let newValue): return newValue
        case .RemoveValue: return nil
        }
    }
}

extension HasSubtree {

    private mutating func visitChildren(visitor: Visitor) throws {
        var currentIndex = 0
        while currentIndex < children.count {
            let child = children[currentIndex]
            let childModifiedByVisit = try child.visit(visitor)

            if let childModifiedByVisit = childModifiedByVisit {
                replaceChildAtIndex(currentIndex, newValue: childModifiedByVisit)
                currentIndex++
            } else {
                removeChildAtIndex(currentIndex)
                // Do not increase current index, everything has shifted down by one because the child was removed.
                // Keeping the same index will in fact visit the next child (or break the loop if it was the last child).
            }
        }
    }
}
