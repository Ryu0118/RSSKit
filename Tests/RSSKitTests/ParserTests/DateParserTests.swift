import Foundation
@testable import RSSCore
import Testing

struct DateParserTests {
    let parser = DateParser()

    struct RFC822WithSecondsTestCase: Sendable {
        let input: String

        static let cases: [RFC822WithSecondsTestCase] = [
            RFC822WithSecondsTestCase(input: "Sat, 07 Sep 2002 09:42:31 GMT"),
            RFC822WithSecondsTestCase(input: "Sat, 07 Sep 2002 09:42:31 +0000"),
            RFC822WithSecondsTestCase(input: "Sat, 07 Sep 2002 00:00:31 -0942"),
        ]
    }

    struct RFC822WithoutSecondsTestCase: Sendable {
        let input: String

        static let cases: [RFC822WithoutSecondsTestCase] = [
            RFC822WithoutSecondsTestCase(input: "Sat, 07 Sep 2002 09:42 GMT"),
            RFC822WithoutSecondsTestCase(input: "Sat, 07 Sep 2002 09:42 +0000"),
        ]
    }

    struct RFC822WithoutWeekdayTestCase: Sendable {
        let input: String

        static let cases: [RFC822WithoutWeekdayTestCase] = [
            RFC822WithoutWeekdayTestCase(input: "07 Sep 2002 09:42:31 GMT"),
            RFC822WithoutWeekdayTestCase(input: "07 Sep 2002 09:42:31 +0000"),
        ]
    }

    struct ISO8601TestCase: Sendable {
        let input: String

        static let cases: [ISO8601TestCase] = [
            ISO8601TestCase(input: "2002-09-07T09:42:31Z"),
            ISO8601TestCase(input: "2002-09-07T09:42:31+0000"),
            ISO8601TestCase(input: "2002-09-07T09:42:31.000Z"),
        ]
    }

    struct InvalidFormatTestCase: Sendable {
        let input: String

        static let cases: [InvalidFormatTestCase] = [
            InvalidFormatTestCase(input: ""),
            InvalidFormatTestCase(input: "invalid"),
            InvalidFormatTestCase(input: "07-09-2002"),
            InvalidFormatTestCase(input: "September 7, 2002"),
        ]
    }

    @Test(arguments: RFC822WithSecondsTestCase.cases)
    func parsesRFC822WithSeconds(testCase: RFC822WithSecondsTestCase) {
        #expect(parser.parse(testCase.input) != nil)
    }

    @Test(arguments: RFC822WithoutSecondsTestCase.cases)
    func parsesRFC822WithoutSeconds(testCase: RFC822WithoutSecondsTestCase) {
        #expect(parser.parse(testCase.input) != nil)
    }

    @Test(arguments: RFC822WithoutWeekdayTestCase.cases)
    func parsesRFC822WithoutWeekday(testCase: RFC822WithoutWeekdayTestCase) {
        #expect(parser.parse(testCase.input) != nil)
    }

    @Test(arguments: ISO8601TestCase.cases)
    func parsesISO8601(testCase: ISO8601TestCase) {
        #expect(parser.parse(testCase.input) != nil)
    }

    @Test
    func parsesDateOnly() {
        #expect(parser.parse("2002-09-07") != nil)
    }

    @Test
    func trimsWhitespace() {
        let input = "  Sat, 07 Sep 2002 09:42:31 GMT  \n"
        #expect(parser.parse(input) != nil)
    }

    @Test(arguments: InvalidFormatTestCase.cases)
    func returnsNilForInvalidFormat(testCase: InvalidFormatTestCase) {
        #expect(parser.parse(testCase.input) == nil)
    }

    @Test
    func parsesCorrectDateComponents() throws {
        let date = try #require(parser.parse("Sat, 07 Sep 2002 09:42:31 GMT"))
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: TimeZone(identifier: "UTC")!, from: date)

        #expect(components.year == 2002)
        #expect(components.month == 9)
        #expect(components.day == 7)
        #expect(components.hour == 9)
        #expect(components.minute == 42)
        #expect(components.second == 31)
    }
}
