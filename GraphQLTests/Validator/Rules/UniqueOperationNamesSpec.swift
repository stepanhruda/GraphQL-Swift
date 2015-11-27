//@testable import GraphQL
//import Nimble
//import Quick
//
//
//class UniqueOperationNamesSpec: QuickSpec {
//
//    override func spec() {
//
//        context("with no operations in a request") {
//            let document = try! Parser.parse("fragment fragA on Type { field }")
//
//            it("passes validation") {
//                try! document.validateForSchema(tempSchema, ruleInitializers: [
//                    UniqueOperationNames.init
//                    ])
//            }
//        }
//
//        context("with one anonymous operation in a request") {
//            let document = try! Parser.parse("{ field }")
//
//            it("passes validation") {
//                try! document.validateForSchema(tempSchema, ruleInitializers: [
//                    UniqueOperationNames.init
//                    ])
//            }
//        }
//
//
//        context("with one named operation in a request") {
//            let document = try! Parser.parse("query Foo { field }")
//
//            it("passes validation") {
//                try! document.validateForSchema(tempSchema, ruleInitializers: [
//                    UniqueOperationNames.init
//                    ])
//            }
//        }
//
//        context("with multiple differently named operations of the same type in a request") {
//            let document = try! Parser.parse("query Foo { field } query Bar { field }")
//
//            it("passes validation") {
//                try! document.validateForSchema(tempSchema, ruleInitializers: [
//                    UniqueOperationNames.init
//                    ])
//            }
//        }
//
//        context("with multiple differently named operations of different types in a request") {
//            let document = try! Parser.parse("query Foo { field } mutation Bar { field }")
//
//            it("passes validation") {
//                try! document.validateForSchema(tempSchema, ruleInitializers: [
//                    UniqueOperationNames.init
//                    ])
//            }
//        }
//
//        context("with a fragment and an operation named the same in a request") {
//            let document = try! Parser.parse("query Foo { ...Foo } fragment Foo on Type { field }")
//
//            it("passes validation") {
//                try! document.validateForSchema(tempSchema, ruleInitializers: [
//                    UniqueOperationNames.init
//                    ])
//            }
//        }
//
//        context("with multiple same named operations of the same type in a request") {
//            let document = try! Parser.parse("query Foo { fieldA } query Foo { fieldB }")
//
//            it("fails validation") {
//                expect {
//                    try document.validateForSchema(tempSchema, ruleInitializers: [
//                        UniqueOperationNames.init
//                        ])
//                }.to(throwError(UniqueOperationNamesError.DuplicateOperationNames(Name(value: "Foo", location: nil))))
//            }
//        }
//
//
//        context("with multiple same named operations of different types in a request") {
//            let document = try! Parser.parse("query Foo { fieldA } mutation Foo { fieldB }")
//
//            it("fails validation") {
//                expect {
//                    try document.validateForSchema(tempSchema, ruleInitializers: [
//                        UniqueOperationNames.init
//                        ])
//                    }.to(throwError(UniqueOperationNamesError.DuplicateOperationNames(Name(value: "Foo", location: nil))))
//            }
//        }
//    }
//}