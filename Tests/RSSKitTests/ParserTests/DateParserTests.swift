@testable import RSSKit
import Foundation
import Testing

struct DateParserTests {
    let parser = DateParser()

    // MARK: - RFC 822 Formats

    @Test(arguments: [
        "Sat, 07 Sep 2002 09:42:31 GMT",
        "Sat, 07 Sep 2002 09:42:31 +0000",
        "Sat, 07 Sep 2002 00:00:31 -0942",
    ])
    func parsesRFC822WithSeconds(input: String) {
        #expect(parser.parse(input) != nil)
    }

    @Test(arguments: [
        "Sat, 07 Sep 2002 09:42 GMT",
        "Sat, 07 Sep 2002 09:42 +0000",
    ])
    func parsesRFC822WithoutSeconds(input: String) {
        #expect(parser.parse(input) != nil)
    }

    @Test(arguments: [
        "07 Sep 2002 09:42:31 GMT",
        "07 Sep 2002 09:42:31 +0000",
    ])
    func parsesRFC822WithoutWeekday(input: String) {
        #expect(parser.parse(input) != nil)
    }

    // MARK: - ISO 8601 Formats

    @Test(arguments: [
        "2002-09-07T09:42:31Z",
        "2002-09-07T09:42:31+0000",
        "2002-09-07T09:42:31.000Z",
    ])
    func parsesISO8601(input: String) {
        #expect(parser.parse(input) != nil)
    }

    @Test
    func parsesDateOnly() {
        #expect(parser.parse("2002-09-07") != nil)
    }

    // MARK: - Whitespace Handling

    @Test
    func trimsWhitespace() {
        let input = "  Sat, 07 Sep 2002 09:42:31 GMT  \n"
        #expect(parser.parse(input) != nil)
    }

    // MARK: - Invalid Input

    @Test(arguments: [
        "",
        "invalid",
        "07-09-2002",
        "September 7, 2002",
    ])
    func returnsNilForInvalidFormat(input: String) {
        #expect(parser.parse(input) == nil)
    }

    // MARK: - Date Value Verification

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
