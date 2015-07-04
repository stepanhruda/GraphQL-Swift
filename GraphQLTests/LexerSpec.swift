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

                expect(token.kind).to(equal(TokenKind.Name))
                expect(token.value as? String).to(equal("h"))
            }

            it("reads a single-character name terminated by a space") {
                let string = "h "
                let source = Source(body: string)
                let token = Lexer.readName(source: source, position: string.startIndex)

                expect(token.kind).to(equal(TokenKind.Name))
                expect(token.value as? String).to(equal("h"))
            }

            it("reads a multi-character name") {
                let string = "hello"
                let source = Source(body: string)
                let token = Lexer.readName(source: source, position: string.startIndex)

                expect(token.kind).to(equal(TokenKind.Name))
                expect(token.value as? String).to(equal("hello"))
            }

            it("reads a multi-character name terminated by a space") {
                let string = "hello dolly"
                let source = Source(body: string)
                let token = Lexer.readName(source: source, position: string.startIndex)

                expect(token.kind).to(equal(TokenKind.Name))
                expect(token.value as? String).to(equal("hello"))
            }
        }

        describe("readNumber") {

            it("reads a short integer") {
                let string = "5"
                let source = Source(body: string)
                let token = try! Lexer.readNumber(source: source, position: string.startIndex)

                expect(token.kind).to(equal(TokenKind.Int))
                expect(token.value as? Int).to(equal(5))
            }

            it("reads a longer integer") {
                let string = "535056544"
                let source = Source(body: string)
                let token = try! Lexer.readNumber(source: source, position: string.startIndex)

                expect(token.kind).to(equal(TokenKind.Int))
                expect(token.value as? Int).to(equal(535056544))
            }

            it("reads a short negative integer") {
                let string = "-5"
                let source = Source(body: string)
                let token = try! Lexer.readNumber(source: source, position: string.startIndex)

                expect(token.kind).to(equal(TokenKind.Int))
                expect(token.value as? Int).to(equal(-5))
            }

            it("reads a longer negative integer") {
                let string = "-535056544"
                let source = Source(body: string)
                let token = try! Lexer.readNumber(source: source, position: string.startIndex)

                expect(token.kind).to(equal(TokenKind.Int))
                expect(token.value as? Int).to(equal(-535056544))
            }

            it("reads a short float") {
                let string = "5.2"
                let source = Source(body: string)
                let token = try! Lexer.readNumber(source: source, position: string.startIndex)

                expect(token.kind).to(equal(TokenKind.Float))
                expect(token.value as? Float).to(equal(5.2))
            }

            it("reads a longer float") {
                let string = "5534653.22463"
                let source = Source(body: string)
                let token = try! Lexer.readNumber(source: source, position: string.startIndex)

                expect(token.kind).to(equal(TokenKind.Float))
                expect(token.value as? Float).to(equal(5534653.22463))
            }

            it("reads a short negative float") {
                let string = "-5.2"
                let source = Source(body: string)
                let token = try! Lexer.readNumber(source: source, position: string.startIndex)

                expect(token.kind).to(equal(TokenKind.Float))
                expect(token.value as? Float).to(equal(-5.2))
            }

            it("reads a longer negative float") {
                let string = "-5534653.22463"
                let source = Source(body: string)
                let token = try! Lexer.readNumber(source: source, position: string.startIndex)

                expect(token.kind).to(equal(TokenKind.Float))
                expect(token.value as? Float).to(equal(-5534653.22463))
            }

            it("reads an integer followed by non-numbers") {
                let string = "5andwemoveon"
                let source = Source(body: string)
                let token = try! Lexer.readNumber(source: source, position: string.startIndex)

                expect(token.kind).to(equal(TokenKind.Int))
                expect(token.value as? Int).to(equal(5))
            }

            it("reads a float followed by non-numbers") {
                let string = "5.3andwemoveon"
                let source = Source(body: string)
                let token = try! Lexer.readNumber(source: source, position: string.startIndex)

                expect(token.kind).to(equal(TokenKind.Float))
                expect(token.value as? Float).to(equal(5.3))
            }
        }

        describe("readString") {
            it("reads a simple string") {
                let string = "\"hello dolly\""
                let source = Source(body: string)
                let token = try! Lexer.readString(source: source, position: string.startIndex)

                expect(token.kind).to(equal(TokenKind.String))
                expect(token.value as? String).to(equal("hello dolly"))
            }

            it("reads escaped characters such as newline") {
                let string = "\"hello\\ndolly\""
                let source = Source(body: string)
                let token = try! Lexer.readString(source: source, position: string.startIndex)

                expect(token.kind).to(equal(TokenKind.String))
                expect(token.value as? String).to(equal("hello\\ndolly"))
            }

            it("reads unicode characters in \\u1234 format") {
                let string = "\"hello \\u0064olly\""
                let source = Source(body: string)
                let token = try! Lexer.readString(source: source, position: string.startIndex)

                expect(token.kind).to(equal(TokenKind.String))
                expect(token.value as? String).to(equal("hello dolly"))
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