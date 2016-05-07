//@testable import GraphQL
//import Nimble
//import Quick
//
//final class UniqueArgumentNamesSpec: QuickSpec {
//
//    override func spec() {
//        let rule: [ValidationContext -> Rule] = [UniqueArgumentNames.init]
//        let schema = starWarsSchema
//
//        context("no arguments on field") {
//            let string =
//            "{" ¶
//            "  field" ¶
//            "}"
//
//            it("passes validation") {
//                expect(string).to(passValidationForSchema(schema, ruleInitializers: rule))
//            }
//        }
//
//        context("an argument on field") {
//            let string =
//            "{" ¶
//            "  field(arg: \"value\")" ¶
//            "}"
//
//            it("passes validation") {
//                expect(string).to(passValidationForSchema(schema, ruleInitializers: rule))
//            }
//        }
//
//        context("same argument on two fields") {
//            let string =
//            "{" ¶
//            "  one: field(arg: \"value\")" ¶
//            "  two: field(arg: \"value\")" ¶
//            "}"
//
//            it("passes validation") {
//                expect(string).to(passValidationForSchema(schema, ruleInitializers: rule))
//            }
//        }
//
//        context("multiple field arguments") {
//            let string =
//            "{" ¶
//            "  field(arg1: \"value\", arg2: \"value\", arg3: \"value\")" ¶
//            "}"
//
//            it("passes validation") {
//                expect(string).to(passValidationForSchema(schema, ruleInitializers: rule))
//            }
//        }
//
//        context("duplicate field arguments") {
//            let string =
//            "{" ¶
//            "  field(arg1: \"value\", arg1: \"value\")" ¶
//            "}"
//
//            it("fails validation") {
//                expect(string).to(failValidationForSchema(schema, ruleInitializers: rule) { error in
//                    switch error {
//                    case .DuplicateArgumentNames(let name):
//                        return name == "arg1"
//                    default: return false
//                    }
//                    })
//            }
//        }
//
//        context("many duplicate field arguments") {
//            let string =
//            "{" ¶
//            "  field(arg1: \"value\", arg1: \"value\", arg1: \"value\")" ¶
//            "}"
//
//            it("fails validation") {
//                expect(string).to(failValidationForSchema(schema, ruleInitializers: rule) { error in
//                    switch error {
//                    case .DuplicateArgumentNames(let name):
//                        return name == "arg1"
//                    default: return false
//                    }
//                    })
//            }
//        }
//    }
//}