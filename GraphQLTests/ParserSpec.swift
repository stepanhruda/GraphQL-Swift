@testable import GraphQL
import Nimble
import Quick

class ParserSpec: QuickSpec {

    override func spec() {

        describe("parse") {
            it("parses a basic document") {
                let string =
                "{\n" +
                    "  node(id: 4) {\n" +
                    "    id,\n" +
                    "    name\n" +
                    "  }\n" +
                "}\n"
                let document = try! parse(Source(body: string))

                expect(document.definitions.count) == 1
                expect(document.definitions.first is OperationDefinition).to(beTrue())
                let operationDefinition = document.definitions.first as! OperationDefinition
                expect(operationDefinition.selectionSet.selections.count) == 1

                expect(operationDefinition.selectionSet.selections.first is Field).to(beTrue())
                let nodeSelectionField = operationDefinition.selectionSet.selections.first as! Field
                expect(nodeSelectionField.name.value) == "node"
                expect(nodeSelectionField.selectionSet?.selections.count) == 2
                expect(nodeSelectionField.arguments.count) == 1

                let idArgument = nodeSelectionField.arguments.first!
                expect(idArgument.name.value) == "id"
                expect(idArgument.value is IntValue).to(beTrue())
                let idArgumentValue = idArgument.value as! IntValue
                expect(idArgumentValue.value) == 4

                expect(nodeSelectionField.selectionSet?.selections.first is Field).to(beTrue())
                let idSelectionField = nodeSelectionField.selectionSet?.selections.first as! Field
                expect(idSelectionField.name.value) == "id"

                expect(nodeSelectionField.selectionSet?.selections.last is Field).to(beTrue())
                let nameSelectionField = nodeSelectionField.selectionSet?.selections.last as! Field
                expect(nameSelectionField.name.value) == "name"
            }

            it("parses the kitchen-sink example") {
                let path = NSBundle(forClass: self.dynamicType).pathForResource("kitchen-sink", ofType: "graphql")
                let kitchenSink = try! NSString(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
                let document = try! parse(Source(body: kitchenSink as String))
                expect(document).toNot(beNil())
            }
        }

    }
}