func undefined<T>(hint:String="", file:StaticString=__FILE__, line:UWord=__LINE__) -> T {
    let message = hint == "" ? "" : ": \(hint)"
    fatalError("undefined \(T.self)\(message)", file:file, line:line)
}
