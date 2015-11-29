
enum VisitAction {
    case Continue
    case Stop
    /// Skip doesn't make sense when returned from a "leave" closure and causes a fatal error.
    case SkipSubtree
    case ReplaceValue(Node)
    case RemoveValue
}

enum NodeType: String {
    case Any = "Any"
    case Document = "Document"
    case OperationDefinition = "OperationDefinition"
    case FragmentDefinition = "FragmentDefinition"
    case FragmentSpread = "FragmentSpread"
    case Field = "Field"
    case Directive = "Directive"
    case Argument = "Argument"
    case VariableDefinition = "VariableDefinition"

    var identifier: String {
        return rawValue
    }
}

enum VisitError: ErrorType {
    case SkipSubtree
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

        if var tree = afterEntering as? Subtree {
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
        case .SkipSubtree: throw VisitError.SkipSubtree
        case .ReplaceValue(let newValue): return newValue
        case .RemoveValue: return nil
        }
    }

    private func leave(visitor: Visitor) throws -> Node? {
        guard let leave = visitor.leave else { return self }

        switch try leave(self) {
        case .Continue: return self
        case .Stop: throw VisitError.Stop
        case .SkipSubtree: fatalError("Developer error: there is no point in skipping a subtree after it has been visited")
        case .ReplaceValue(let newValue): return newValue
        case .RemoveValue: return nil
        }
    }
}

extension Subtree {

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
