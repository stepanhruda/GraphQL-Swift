@testable import GraphQL
import Nimble
import Quick

class ParserSpec: QuickSpec {

    override func spec() {

        describe("parse") {
            it("parses a string into an AST") {
                let string =
                "{\n" +
                    "  node(id: 4) {\n" +
                    "    id,\n" +
                    "    name\n" +
                    "  }\n" +
                "}\n"
                let ast = try! parse(Source(body: string))
                expect(ast).toNot(beNil())
            }
        }

    }
}