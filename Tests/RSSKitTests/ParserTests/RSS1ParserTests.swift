import Foundation
@testable import RSS1Kit
@testable import RSSKit
import Testing

struct RSS1ParserTests {
    let parser = RSS1Parser()

    private func loadFixture(_ name: String) throws -> Data {
        let fixturesURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Fixtures")
            .appendingPathComponent(name)

        return try Data(contentsOf: fixturesURL)
    }

    // MARK: - Test Case Types

    struct FeedTestCase: Sendable {
        let fixture: String
        let expectedTitle: String
        let expectedLink: String

        static let validFeeds: [FeedTestCase] = [
            FeedTestCase(
                fixture: "valid_rss1_feed.xml",
                expectedTitle: "Example RSS 1.0 Feed",
                expectedLink: "https://example.com"
            ),
            FeedTestCase(
                fixture: "minimal_rss1_feed.xml",
                expectedTitle: "Minimal RSS 1.0 Feed",
                expectedLink: "https://minimal.example.com"
            ),
        ]
    }

    struct ItemCountTestCase: Sendable {
        let fixture: String
        let expectedCount: Int

        static let cases: [ItemCountTestCase] = [
            ItemCountTestCase(fixture: "valid_rss1_feed.xml", expectedCount: 3),
            ItemCountTestCase(fixture: "minimal_rss1_feed.xml", expectedCount: 0),
            ItemCountTestCase(fixture: "japanese_rss1_feed.xml", expectedCount: 2),
        ]
    }

    struct ItemTestCase: Sendable {
        let itemIndex: Int
        let expectedTitle: String
        let expectedLink: String

        static let validFeedItems: [ItemTestCase] = [
            ItemTestCase(itemIndex: 0, expectedTitle: "First Article", expectedLink: "https://example.com/articles/1"),
            ItemTestCase(itemIndex: 1, expectedTitle: "Second Article", expectedLink: "https://example.com/articles/2"),
            ItemTestCase(itemIndex: 2, expectedTitle: "Third Article", expectedLink: "https://example.com/articles/3"),
        ]
    }

    struct ItemCategoryTestCase: Sendable {
        let itemIndex: Int
        let expectedCategories: [String]

        static let cases: [ItemCategoryTestCase] = [
            ItemCategoryTestCase(itemIndex: 0, expectedCategories: ["News"]),
            ItemCategoryTestCase(itemIndex: 1, expectedCategories: []),
            ItemCategoryTestCase(itemIndex: 2, expectedCategories: ["Swift", "Tech"]),
        ]
    }

    struct XMLEntityTestCase: Sendable {
        let encoded: String
        let expected: String

        static let cases: [XMLEntityTestCase] = [
            XMLEntityTestCase(encoded: "Feed &amp; More", expected: "Feed & More"),
            XMLEntityTestCase(encoded: "Less &lt;than&gt; greater", expected: "Less <than> greater"),
            XMLEntityTestCase(encoded: "Quote &quot;test&quot;", expected: "Quote \"test\""),
        ]
    }

    // MARK: - Valid Feed Parsing

    @Test(arguments: FeedTestCase.validFeeds)
    func parsesValidFixtures(testCase: FeedTestCase) throws {
        let data = try loadFixture(testCase.fixture)
        let feed = try parser.parse(data)

        #expect(feed.version == "1.0")
        #expect(feed.channel.title == testCase.expectedTitle)
        #expect(feed.channel.link.absoluteString == testCase.expectedLink)
    }

    @Test
    func parsesJapaneseRSS1Feed() throws {
        let data = try loadFixture("japanese_rss1_feed.xml")
        let feed = try parser.parse(data)

        #expect(feed.version == "1.0")
        #expect(feed.channel.title.isEmpty == false)
        #expect(feed.channel.link.absoluteString == "https://tech-news.example.jp")
        #expect(feed.channel.items.count == 2)
    }

    @Test(arguments: ItemCountTestCase.cases)
    func parsesItemCount(testCase: ItemCountTestCase) throws {
        let data = try loadFixture(testCase.fixture)
        let feed = try parser.parse(data)

        #expect(feed.channel.items.count == testCase.expectedCount)
    }

    // MARK: - Channel Metadata

    @Test
    func parsesChannelMetadata() throws {
        let data = try loadFixture("valid_rss1_feed.xml")
        let channel = try parser.parse(data).channel

        #expect(channel.language == "en-us")
        #expect(channel.copyright == "Copyright 2024 Example Inc.")
        #expect(channel.managingEditor == "editor@example.com")
        #expect(channel.pubDate != nil)
    }

    @Test
    func parsesChannelCategories() throws {
        let data = try loadFixture("valid_rss1_feed.xml")
        let categories = try parser.parse(data).channel.categories

        #expect(categories.count == 2)
        #expect(categories.map(\.value).sorted() == ["Programming", "Technology"])
    }

    @Test
    func minimalFeedHasNilOptionalFields() throws {
        let data = try loadFixture("minimal_rss1_feed.xml")
        let channel = try parser.parse(data).channel

        #expect(channel.items.isEmpty)
        #expect(channel.image == nil)
        #expect(channel.categories.isEmpty)
        #expect(channel.language == nil)
        #expect(channel.copyright == nil)
        #expect(channel.managingEditor == nil)
        #expect(channel.pubDate == nil)
    }

    // MARK: - Item Parsing

    @Test(arguments: ItemTestCase.validFeedItems)
    func parsesItemTitleAndLink(testCase: ItemTestCase) throws {
        let data = try loadFixture("valid_rss1_feed.xml")
        let item = try parser.parse(data).channel.items[testCase.itemIndex]

        #expect(item.title == testCase.expectedTitle)
        #expect(item.link?.absoluteString == testCase.expectedLink)
    }

    @Test
    func parsesFirstItemWithAllFields() throws {
        let data = try loadFixture("valid_rss1_feed.xml")
        let item = try parser.parse(data).channel.items[0]

        #expect(item.title == "First Article")
        #expect(item.link?.absoluteString == "https://example.com/articles/1")
        #expect(item.description == "This is the first article in RSS 1.0 format.")
        #expect(item.author == "author@example.com")
        #expect(item.pubDate != nil)
        #expect(item.categories.count == 1)
        #expect(item.categories[0].value == "News")
        #expect(item.source?.url.absoluteString == "https://source.com/feed.xml")
    }

    @Test(arguments: ItemCategoryTestCase.cases)
    func parsesItemCategories(testCase: ItemCategoryTestCase) throws {
        let data = try loadFixture("valid_rss1_feed.xml")
        let item = try parser.parse(data).channel.items[testCase.itemIndex]

        #expect(item.categories.map(\.value).sorted() == testCase.expectedCategories.sorted())
    }

    // MARK: - Japanese Content

    @Test(arguments: [0, 1])
    func parsesJapaneseItems(itemIndex: Int) throws {
        let data = try loadFixture("japanese_rss1_feed.xml")
        let item = try parser.parse(data).channel.items[itemIndex]

        #expect(item.title?.isEmpty == false)
        #expect(item.author?.isEmpty == false)
        #expect(item.categories.isEmpty == false)
    }

    // MARK: - CDATA Content

    @Test
    func parsesCDATAContent() throws {
        let data = try loadFixture("valid_rss1_feed.xml")
        let item = try parser.parse(data).channel.items[2]

        #expect(item.description == "<p>HTML content with <strong>formatting</strong>.</p>")
    }

    // MARK: - Error Cases

    @Test(arguments: [
        "<rss version=\"2.0\"><channel><title>T</title><link>http://x.com</link><description>D</description></channel></rss>",
        "<html><body>Not RSS</body></html>",
        "<feed><title>Atom Feed</title></feed>",
    ])
    func throwsForNonRSS1Content(xmlString: String) {
        #expect(throws: RSSError.invalidRSSStructure) {
            try parser.parse(xmlString)
        }
    }

    @Test
    func throwsForMissingChannel() {
        let xml = """
        <?xml version="1.0"?>
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns="http://purl.org/rss/1.0/">
          <item rdf:about="http://example.com/1">
            <title>Orphan Item</title>
          </item>
        </rdf:RDF>
        """

        #expect(throws: RSSError.invalidRSSStructure) {
            try parser.parse(xml)
        }
    }

    @Test(arguments: ["title", "link", "description"])
    func throwsForMissingRequiredChannelElement(element: String) {
        var children = [
            "<title>Title</title>",
            "<link>https://example.com</link>",
            "<description>Desc</description>",
        ]

        // Remove the element we're testing
        children = children.filter { !$0.contains("<\(element)>") }

        let xml = """
        <?xml version="1.0"?>
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns="http://purl.org/rss/1.0/">
          <channel rdf:about="http://example.com/rss">
            \(children.joined(separator: "\n    "))
          </channel>
        </rdf:RDF>
        """

        #expect(throws: RSSError.missingRequiredElement(element)) {
            try parser.parse(xml)
        }
    }

    @Test(arguments: [
        "This is not XML at all",
        "<broken><unclosed>",
        "",
    ])
    func throwsForInvalidXML(input: String) {
        #expect(throws: RSSError.self) {
            try parser.parse(input)
        }
    }

    // MARK: - String Parsing

    @Test
    func parsesFromString() throws {
        let xmlString = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns="http://purl.org/rss/1.0/">
          <channel rdf:about="https://string.example.com/rss">
            <title>String Feed</title>
            <link>https://string.example.com</link>
            <description>Parsed from string</description>
          </channel>
        </rdf:RDF>
        """

        let feed = try parser.parse(xmlString)

        #expect(feed.version == "1.0")
        #expect(feed.channel.title == "String Feed")
        #expect(feed.channel.description == "Parsed from string")
    }

    // MARK: - XML Entities

    @Test(arguments: XMLEntityTestCase.cases)
    func handlesXMLEntities(testCase: XMLEntityTestCase) throws {
        let xmlString = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns="http://purl.org/rss/1.0/">
          <channel rdf:about="https://example.com/rss">
            <title>\(testCase.encoded)</title>
            <link>https://example.com</link>
            <description>Test</description>
          </channel>
        </rdf:RDF>
        """

        let feed = try parser.parse(xmlString)
        #expect(feed.channel.title == testCase.expected)
    }
}
