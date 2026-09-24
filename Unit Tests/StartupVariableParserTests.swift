import Testing

@testable import Bisquit_Host

struct StartupVariableParserTests {
    @Test func booleanRepresentationsRoundTrip() {
        for template in ["0", "1", "false", "true", " TRUE ", ""] {
            for value in [false, true] {
                let encoded = StartupVariableParser.booleanString(value, template: template)
                #expect(StartupVariableParser.booleanValue(encoded) == value)
            }
        }
        #expect(StartupVariableParser.booleanString(true, template: "0") == "1")
        #expect(StartupVariableParser.booleanString(false, template: "true") == "false")
    }

    @Test func booleanParsingNormalizesWhitespaceAndCase() {
        #expect(StartupVariableParser.booleanValue(" TRUE\n"))
        #expect(StartupVariableParser.booleanValue(" 1 "))
        #expect(!StartupVariableParser.booleanValue("false"))
        #expect(!StartupVariableParser.booleanValue("0"))
        #expect(!StartupVariableParser.booleanValue(""))
    }

    @Test func enumParsingHandlesBothPrefixes() {
        #expect(StartupVariableParser.enumOptions(["required", " in: alpha, beta, ,gamma "]) == ["alpha", "beta", "gamma"])
        #expect(StartupVariableParser.enumOptions(["ENUM:one,two"]) == ["one", "two"])
        #expect(StartupVariableParser.enumOptions(["string"]).isEmpty)
    }

    @Test func booleanRuleDoesNotMatchEnumValues() {
        #expect(StartupVariableParser.isBoolean(["required", " boolean "]))
        #expect(!StartupVariableParser.isBoolean(["in:boolean,string"]))
    }
}
