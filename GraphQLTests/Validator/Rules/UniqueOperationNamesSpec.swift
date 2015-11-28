@testable import GraphQL
import Nimble
import Quick

class UniqueOperationNamesSpec: QuickSpec {

    override func spec() {
        let rule: [ValidationContext -> Rule] = [UniqueOperationNames.init]
        let schema = starWarsSchema

        context("with no operations in a request") {
            let string =
            "fragment fragA on Type {" ¶
            "  field" ¶
            "}"

            it("passes validation") {
                expect(string).to(passValidationForSchema(schema, ruleInitializers: rule))
            }
        }

        context("with one anonymous operation in a request") {
            let string =
            "{" ¶
            "  field" ¶
            "}"

            it("passes validation") {
                expect(string).to(passValidationForSchema(schema, ruleInitializers: rule))

            }
        }

        context("with one named operation in a request") {
            let string =
            "query Foo {" ¶
            "  field" ¶
            "}"

            it("passes validation") {
                expect(string).to(passValidationForSchema(schema, ruleInitializers: rule))
            }
        }

        context("with multiple differently named operations of the same type in a request") {
            let string =
            "query Foo {" ¶
            "  field" ¶
            "}" ¶
            "" ¶
            "query Bar {" ¶
            "  field" ¶
            "}"

            it("passes validation") {
                expect(string).to(passValidationForSchema(schema, ruleInitializers: rule))
            }
        }

        context("with multiple differently named operations of different types in a request") {
            let string =
            "query Foo {" ¶
            "  field" ¶
            "}" ¶
            "" ¶
            "mutation Bar {" ¶
            "  field" ¶
            "}"

            it("passes validation") {
                expect(string).to(passValidationForSchema(schema, ruleInitializers: rule))
            }
        }

        context("with a fragment and an operation named the same in a request") {
            let string =
            "query Foo {" ¶
            "  ...Foo" ¶
            "}" ¶
            "" ¶
            "fragment Foo on Type {" ¶
            "  field" ¶
            "}"

            it("passes validation") {
                expect(string).to(passValidationForSchema(schema, ruleInitializers: rule))
            }
        }

        context("with multiple same named operations of the same type in a request") {
            let string =
            "query Foo {" ¶
            "  fieldA" ¶
            "}" ¶
            "" ¶
            "query Foo {" ¶
            "  fieldB" ¶
            "}"

            it("fails validation") {
                expect(string).to(failValidationForSchema(schema, ruleInitializers: rule) { error in
                    switch error {
                    case .DuplicateOperationNames(let name1, let name2):
                        return name1.value == "Foo" && name2.value == "Foo"
                    default: return false
                    }
                    })
            }
        }


        context("with multiple same named operations of different types in a request") {
            let string =
            "query Foo {" ¶
            "  fieldA" ¶
            "}" ¶
            "" ¶
            "mutation Foo {" ¶
            "  fieldB" ¶
            "}"

            it("fails validation") {
                expect(string).to(failValidationForSchema(schema, ruleInitializers: rule) { error in
                    switch error {
                    case .DuplicateOperationNames(let name1, let name2):
                        return name1.value == "Foo" && name2.value == "Foo"
                    default: return false
                    }
                    })
            }
        }
    }
}