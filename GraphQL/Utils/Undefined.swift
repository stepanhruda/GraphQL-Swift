public func undefined<T>(hint:String="", file:StaticString=#file, line:UInt=#line) -> T {
    let message = hint == "" ? "" : ": \(hint)"
    fatalError("undefined \(T.self)\(message)", file:file, line:line)
}
