import Nimble
import Quick
@testable import GraphQL

func passValidationForSchema(schema: Schema, ruleInitializers: [ValidationContext -> Rule]) -> NonNilMatcherFunc<String> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        guard let source = try actualExpression.evaluate() else {
            failureMessage.actualValue = nil
            failureMessage.postfixMessage = "receive string"
            return false
        }

        failureMessage.actualValue = nil
        failureMessage.postfixMessage = "pass validation"
        let document = try Parser.parse(Source(body: source))
        try document.validateForSchema(schema, ruleInitializers: ruleInitializers)

        return true
    }
}

func failValidationForSchema(schema: Schema, ruleInitializers: [ValidationContext -> Rule], withExpectedError: DocumentValidationError -> Bool) -> NonNilMatcherFunc<String> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        guard let source = try actualExpression.evaluate() else {
            failureMessage.actualValue = nil
            failureMessage.postfixMessage = "receive string"
            return false
        }

        let document = try Parser.parse(Source(body: source))
        do {
            failureMessage.actualValue = nil
            failureMessage.postfixMessage = "fail during validation"
            try document.validateForSchema(schema, ruleInitializers: ruleInitializers)
        } catch let error as DocumentValidationError {
            return withExpectedError(error)
        }

        return false
    }
}
