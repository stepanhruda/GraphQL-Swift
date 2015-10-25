
enum VisitAction {
    case Continue
    case Stop
    /// Skip doesn't have any effect when returned from a "leave" closure.
    case SkipSubtree
    case ReplaceValue(Any)
    case RemoveValue
}

protocol Node {
    var type: NodeType { get }
}

enum NodeType {
    case Any
    case OperationDefinition
    case FragmentDefinition
    case FragmentSpread
}

enum Visitor {
    case OnEnter(NodeType, Node throws -> VisitAction)
    case OnEnterAndLeave(NodeType, Node throws -> VisitAction, Node throws -> VisitAction)
}

let queryDocumentKeys: [String:String] = [:]

func visit(node: Node, _ visitor: Visitor, keymap: [String:String] = queryDocumentKeys) -> Node {
//    let visitorKeys = keymap
//
    var keys: [Node] = [ node ]

    let edits: [Any] = []
    let resultNode = node
    var index = -1

    let stack: ([Any], Int, [String:String], Any)? = nil

    repeat {
        index++


    } while stack != nil

    if edits.count > 0 {
    }

    return resultNode
}