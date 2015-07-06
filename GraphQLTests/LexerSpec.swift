@testable import GraphQL
import Nimble
import Quick

class LexerSpec: QuickSpec {

    override func spec() {

        describe("functionForSource") {
            func lex(string: String) throws -> (Token, String.Index) {
                let source = Source(body: string)
                let lexer = Lexer.functionForSource(source)
                return (try lexer(nil), source.body.startIndex)
            }

            it("skips whitespace") {
                let (token, startIndex) = try! lex("   \n  \t   foo   \n   \t    ")
                expect(token.kind) == TokenKind.Name
                expect(token.start) == startIndex + 10
                expect(token.end) == startIndex + 13
                expect(token.value as? String) == "foo"
            }

            it("skips comments") {
                let (token, startIndex) = try! lex("  \n#comment\nfoo#comment\n\n")
                expect(token.kind) == TokenKind.Name
                expect(token.start) == startIndex + 12
                expect(token.end) == startIndex + 15
                expect(token.value as? String) == "foo"
            }

            it("skips commas") {
                let (token, startIndex) = try! lex(",,,foo,,,")
                expect(token.kind) == TokenKind.Name
                expect(token.start) == startIndex + 3
                expect(token.end) == startIndex + 6
                expect(token.value as? String) == "foo"
            }

            it("throws errors in correct position") {
                var (_, _): (Token, String.Index)
                var error: ErrorType? = nil
                do { (_, _) = try lex("      ?     ") }
                catch let thrownError {
                    error = thrownError
                }
                // TODO: Add tighter expectations for errors
                expect(error).toNot(beNil())
            }

            it("lexes strings") {
                let (token, startIndex) = try! lex("\"simple\"")
                expect(token.kind) == TokenKind.String
                expect(token.start) == startIndex
                expect(token.end) == startIndex + 7
                expect(token.value as? String) == "simple"
            }

            it("lexes spreads") {
                let (token, startIndex) = try! lex("...")
                expect(token.kind) == TokenKind.Spread
                expect(token.start) == startIndex
                expect(token.end) == startIndex + 3
            }

            it("lexes two tokens") {
                let source = Source(body: "foo bar")
                let lexer = Lexer.functionForSource(source)
                var token = try! lexer(nil)
                token = try! lexer(token.end)
                expect(token.kind) == TokenKind.Name
                expect(token.start) == source.body.startIndex + 4
                expect(token.end) == source.body.endIndex
            }
        }

        describe("readName") {

            it("reads a single-character name") {
                let source = Source(body: "h")
                let token = Lexer.readName(source: source, position: source.body.startIndex)

                expect(token.kind) == TokenKind.Name
                expect(token.value as? String) == "h"
            }

            it("reads a single-character name terminated by a space") {
                let source = Source(body: "h ")
                let token = Lexer.readName(source: source, position: source.body.startIndex)

                expect(token.kind) == TokenKind.Name
                expect(token.value as? String) == "h"
            }

            it("reads a multi-character name") {
                let source = Source(body: "hello")
                let token = Lexer.readName(source: source, position: source.body.startIndex)

                expect(token.kind) == TokenKind.Name
                expect(token.value as? String) == "hello"
            }

            it("reads a multi-character name terminated by a space") {
                let source = Source(body: "hello dolly")
                let token = Lexer.readName(source: source, position: source.body.startIndex)

                expect(token.kind) == TokenKind.Name
                expect(token.value as? String) == "hello"
            }
        }

        describe("readNumber") {

            it("reads a short integer") {
                let source = Source(body: "5")
                let token = try! Lexer.readNumber(source: source, position: source.body.startIndex)

                expect(token.kind) == TokenKind.Int
                expect(token.value as? Int) == 5
            }

            it("reads a longer integer") {
                let source = Source(body: "535056544")
                let token = try! Lexer.readNumber(source: source, position: source.body.startIndex)

                expect(token.kind) == TokenKind.Int
                expect(token.value as? Int) == 535056544
            }

            it("reads a short negative integer") {
                let source = Source(body: "-5")
                let token = try! Lexer.readNumber(source: source, position: source.body.startIndex)

                expect(token.kind) == TokenKind.Int
                expect(token.value as? Int) == -5
            }

            it("reads a longer negative integer") {
                let source = Source(body: "-535056544")
                let token = try! Lexer.readNumber(source: source, position: source.body.startIndex)

                expect(token.kind) == TokenKind.Int
                expect(token.value as? Int) == -535056544
            }

            it("reads a short float") {
                let source = Source(body: "5.2")
                let token = try! Lexer.readNumber(source: source, position: source.body.startIndex)

                expect(token.kind) == TokenKind.Float
                expect(token.value as? Float) == 5.2
            }

            it("reads a longer float") {
                let source = Source(body: "5534653.22463")
                let token = try! Lexer.readNumber(source: source, position: source.body.startIndex)

                expect(token.kind) == TokenKind.Float
                expect(token.value as? Float) == 5534653.22463
            }

            it("reads a short negative float") {
                let source = Source(body: "-5.2")
                let token = try! Lexer.readNumber(source: source, position: source.body.startIndex)

                expect(token.kind) == TokenKind.Float
                expect(token.value as? Float) == -5.2
            }

            it("reads a longer negative float") {
                let source = Source(body: "-5534653.22463")
                let token = try! Lexer.readNumber(source: source, position: source.body.startIndex)

                expect(token.kind) == TokenKind.Float
                expect(token.value as? Float) == -5534653.22463
            }

            // TODO: Figure out this syntax in Swift
            it("reads numbers with short exponent notation") {
                let source = Source(body: "-1.123e4")
                let token = try! Lexer.readNumber(source: source, position: source.body.startIndex)

                expect(token.kind) == TokenKind.Float
                expect(token.value as? Float) == -1.123e4
            }

            it("reads numbers with short negative exponent notation") {
                let source = Source(body: "-1.123e-4")
                let token = try! Lexer.readNumber(source: source, position: source.body.startIndex)

                expect(token.kind) == TokenKind.Float
                expect(token.value as? Float) == -1.123e-4
            }


            it("reads numbers with longer exponent notation") {
                let source = Source(body: "-1.123e23")
                let token = try! Lexer.readNumber(source: source, position: source.body.startIndex)

                expect(token.kind) == TokenKind.Float
                expect(token.value as? Float) == -1.123e23
            }

            it("reads numbers with longer negative exponent notation") {
                let source = Source(body: "-1.123e-23")
                let token = try! Lexer.readNumber(source: source, position: source.body.startIndex)

                expect(token.kind) == TokenKind.Float
                expect(token.value as? Float) == -1.123e-23
            }

            it("reads an integer followed by non-numbers") {
                let source = Source(body: "5andwemoveon")
                let token = try! Lexer.readNumber(source: source, position: source.body.startIndex)

                expect(token.kind) == TokenKind.Int
                expect(token.value as? Int) == 5
            }

            it("reads a float followed by non-numbers") {
                let source = Source(body: "5.3andwemoveon")
                let token = try! Lexer.readNumber(source: source, position: source.body.startIndex)

                expect(token.kind) == TokenKind.Float
                expect(token.value as? Float) == 5.3
            }

            it ("reads 00 as 0") {
                let source = Source(body: "00")
                let token = try! Lexer.readNumber(source: source, position: source.body.startIndex)

                expect(token.kind) == TokenKind.Int
                expect(token.value as? Int) == 0
                expect(token.end) == source.body.startIndex + 2
            }
        }

        describe("readString") {
            it("reads a simple string") {
                let string = "\"hello dolly\""
                let source = Source(body: string)
                let token = try! Lexer.readString(source: source, position: source.body.startIndex)

                expect(token.kind) == TokenKind.String
                expect(token.value as? String) == "hello dolly"
            }

            it("reads escaped characters such as newline") {
                let string = "\"hello\\ndolly\""
                let source = Source(body: string)
                let token = try! Lexer.readString(source: source, position: source.body.startIndex)

                expect(token.kind) == TokenKind.String
                expect(token.value as? String) == "hello\\ndolly"
            }

            it("reads unicode characters in \\u1234 format") {
                let string = "\"hello \\u0064olly\""
                let source = Source(body: string)
                let token = try! Lexer.readString(source: source, position: source.body.startIndex)

                expect(token.kind) == TokenKind.String
                expect(token.value as? String) == "hello dolly"
            }

            // TODO: Add string error handling
        }

        describe("positionAfterWhitespace") {
            it("ignores spaces, commas, U+2028, U+2029, U+0008 through U+000E") {
                let string = " ,\u{2028}\u{2029}\u{9}\u{A}\u{B}\u{C}\u{D}h"
                let position = Lexer.positionAfterWhitespace(body: string, position: string.startIndex)

                expect(string[position]) == "h"
            }

            it("ignores comments started by #") {
                let string = "# whatever you wanna say\ng"
                let position = Lexer.positionAfterWhitespace(body: string, position: string.startIndex)

                expect(string[position]) == "g"
            }
        }
    }
}