public enum SchemaScalarType {
    case Int
    case Float
    case String
    case Boolean
    case ID
}

public func ==(left: SchemaScalarType, right: SchemaScalarType) -> Bool {
    switch (left, right) {
    case (.Int, .Int): return true
    case (.Float, .Float): return true
    case (.String, .String): return true
    case (.Boolean, .Boolean): return true
    case (.ID, .ID): return true
    default: return false
    }
}
