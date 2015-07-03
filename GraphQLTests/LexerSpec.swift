@testable import GraphQL
import Nimble
import Quick

class LexerSpec: QuickSpec {

    override func spec() {

        describe("readName") {

            it("reads a single-character name") {
                let string = "h"
                let source = Source(body: string)
                let token = Lexer.readName(source: source, position: string.startIndex)

                switch token.kind {
                case .Name(let value): expect(value).to(equal("h"))
                default: fail()
                }
            }

            it("reads a single-character name terminated by a space") {
                let string = "h "
                let source = Source(body: string)
                let token = Lexer.readName(source: source, position: string.startIndex)

                switch token.kind {
                case .Name(let value): expect(value).to(equal("h"))
                default: fail()
                }
            }

            it("reads a multi-character name") {
                let string = "hello"
                let source = Source(body: string)
                let token = Lexer.readName(source: source, position: string.startIndex)

                switch token.kind {
                case .Name(let value): expect(value).to(equal("hello"))
                default: fail()
                }
            }

            it("reads a multi-character name terminated by a space") {
                let string = "hello dolly"
                let source = Source(body: string)
                let token = Lexer.readName(source: source, position: string.startIndex)

                switch token.kind {
                case .Name(let value): expect(value).to(equal("hello"))
                default: fail()
                }
            }

        }

        describe("readNumber") {

            it("reads a short integer") {
                let string = "5"
                let source = Source(body: string)
                let token = try! Lexer.readNumber(source: source, position: string.startIndex)

                switch token.kind {
                case .IntValue(let value): expect(value).to(equal(5))
                default: fail()
                }
            }

            it("reads a longer integer") {
                let string = "535056544"
                let source = Source(body: string)
                let token = try! Lexer.readNumber(source: source, position: string.startIndex)

                switch token.kind {
                case .IntValue(let value): expect(value).to(equal(535056544))
                default: fail()
                }
            }

            it("reads a short negative integer") {
                let string = "-5"
                let source = Source(body: string)
                let token = try! Lexer.readNumber(source: source, position: string.startIndex)

                switch token.kind {
                case .IntValue(let value): expect(value).to(equal(-5))
                default: fail()
                }
            }

            it("reads a longer negative integer") {
                let string = "-535056544"
                let source = Source(body: string)
                let token = try! Lexer.readNumber(source: source, position: string.startIndex)

                switch token.kind {
                case .IntValue(let value): expect(value).to(equal(-535056544))
                default: fail()
                }
            }

            it("reads a short float") {
                let string = "5.2"
                let source = Source(body: string)
                let token = try! Lexer.readNumber(source: source, position: string.startIndex)

                switch token.kind {
                case .FloatValue(let value): expect(value).to(equal(5.2))
                default: fail()
                }
            }

            it("reads a longer float") {
                let string = "5534653.22463"
                let source = Source(body: string)
                let token = try! Lexer.readNumber(source: source, position: string.startIndex)

                switch token.kind {
                case .FloatValue(let value): expect(value).to(equal(5534653.22463))
                default: fail()
                }
            }

            it("reads a short negative float") {
                let string = "-5.22"
                let source = Source(body: string)
                let token = try! Lexer.readNumber(source: source, position: string.startIndex)

                switch token.kind {
                case .FloatValue(let value): expect(value).to(equal(-5.22))
                default: fail()
                }
            }

            it("reads a longer negative float") {
                let string = "-5534653.22463"
                let source = Source(body: string)
                let token = try! Lexer.readNumber(source: source, position: string.startIndex)

                switch token.kind {
                case .FloatValue(let value): expect(value).to(equal(-5534653.22463))
                default: fail()
                }
            }

            it("reads an integer followed by non-numbers") {
                let string = "5andwemoveon"
                let source = Source(body: string)
                let token = try! Lexer.readNumber(source: source, position: string.startIndex)

                switch token.kind {
                case .IntValue(let value): expect(value).to(equal(5))
                default: fail()
                }
            }

            it("reads a float followed by non-numbers") {
                let string = "5.3andwemoveon"
                let source = Source(body: string)
                let token = try! Lexer.readNumber(source: source, position: string.startIndex)

                switch token.kind {
                case .FloatValue(let value): expect(value).to(equal(5.3))
                default: fail()
                }
            }
        }

        describe("readString") {
            it("reads a simple string") {
                let string = "\"hello dolly\""
                let source = Source(body: string)
                let token = try! Lexer.readString(source: source, position: string.startIndex)

                switch token.kind {
                case .StringValue(let value): expect(value).to(equal("hello dolly"))
                default: fail()
                }
            }

            it("reads escaped characters such as newline") {
                let string = "\"hello\\ndolly\""
                let source = Source(body: string)
                let token = try! Lexer.readString(source: source, position: string.startIndex)

                switch token.kind {
                case .StringValue(let value): expect(value).to(equal("hello\\ndolly"))
                default: fail()
                }
            }

            it("reads unicode characters in \\u1234 format") {
                let string = "\"hello \\u0064olly\""
                let source = Source(body: string)
                let token = try! Lexer.readString(source: source, position: string.startIndex)

                switch token.kind {
                case .StringValue(let value): expect(value).to(equal("hello dolly"))
                default: fail()
                }
            }
        }

        describe("positionAfterWhitespace") {
            it("ignores spaces, commas, U+2028, U+2029, U+0008 through U+000E") {
                let string = " ,\u{2028}\u{2029}\u{9}\u{A}\u{B}\u{C}\u{D}h"
                let position = Lexer.positionAfterWhitespace(body: string, position: string.startIndex)

                expect(string[position]).to(equal("h"))
            }

            it("ignores comments started by #") {
                let string = "# whatever you wanna say\ng"
                let position = Lexer.positionAfterWhitespace(body: string, position: string.startIndex)

                expect(string[position]).to(equal("g"))
            }
        }
    }
}