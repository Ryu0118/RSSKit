import Foundation
@testable import RSSKit
import Testing

struct RSSParserTests {
    let parser = RSSParser()

    private func loadFixture(_ name: String) throws -> Data {
        let fixturesURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("Fixtures")
            .appendingPathComponent(name)

        return try Data(contentsOf: fixturesURL)
    }

    struct FeedTestCase: Sendable {
        let fixture: String
        let expectedTitle: String
        let expectedLink: String
        let expectedDescription: String

        static let validFeeds: [FeedTestCase] = [
            FeedTestCase(
                fixture: "valid_feed.xml",
                expectedTitle: "Example RSS Feed",
                expectedLink: "https://example.com",
                expectedDescription: "An example RSS feed for testing"
            ),
            FeedTestCase(
                fixture: "minimal_feed.xml",
                expectedTitle: "Minimal Feed",
                expectedLink: "https://minimal.example.com",
                expectedDescription: "A minimal RSS feed with only required elements"
            ),
            FeedTestCase(
                fixture: "real_world_bbc.xml",
                expectedTitle: "BBC News - Technology",
                expectedLink: "https://www.bbc.co.uk/news/technology",
                expectedDescription: "BBC News - Technology"
            ),
            FeedTestCase(
                fixture: "podcast_feed.xml",
                expectedTitle: "Tech Talk Podcast",
                expectedLink: "https://podcast.example.com",
                expectedDescription: "Weekly discussions about the latest in technology"
            ),
        ]
    }

    struct ItemCountTestCase: Sendable {
        let fixture: String
        let expectedCount: Int

        static let rss2Feeds: [ItemCountTestCase] = [
            ItemCountTestCase(fixture: "valid_feed.xml", expectedCount: 3),
            ItemCountTestCase(fixture: "minimal_feed.xml", expectedCount: 0),
            ItemCountTestCase(fixture: "real_world_bbc.xml", expectedCount: 2),
            ItemCountTestCase(fixture: "podcast_feed.xml", expectedCount: 2),
            ItemCountTestCase(fixture: "japanese_feed.xml", expectedCount: 2),
        ]

        static let rss1Feeds: [ItemCountTestCase] = [
            ItemCountTestCase(fixture: "valid_rss1_feed.xml", expectedCount: 3),
            ItemCountTestCase(fixture: "minimal_rss1_feed.xml", expectedCount: 0),
            ItemCountTestCase(fixture: "japanese_rss1_feed.xml", expectedCount: 2),
        ]
    }

    struct GUIDTestCase: Sendable {
        let fixture: String
        let itemIndex: Int
        let expectedIsPermaLink: Bool

        static let cases: [GUIDTestCase] = [
            GUIDTestCase(fixture: "valid_feed.xml", itemIndex: 0, expectedIsPermaLink: true),
            GUIDTestCase(fixture: "valid_feed.xml", itemIndex: 1, expectedIsPermaLink: false),
            GUIDTestCase(fixture: "valid_feed.xml", itemIndex: 2, expectedIsPermaLink: true),
        ]
    }

    struct EnclosureTestCase: Sendable {
        let itemIndex: Int
        let expectedURL: String
        let expectedLength: Int
        let expectedType: String

        static let podcastEnclosures: [EnclosureTestCase] = [
            EnclosureTestCase(
                itemIndex: 0,
                expectedURL: "https://podcast.example.com/audio/ep100.mp3",
                expectedLength: 52_428_800,
                expectedType: "audio/mpeg"
            ),
            EnclosureTestCase(
                itemIndex: 1,
                expectedURL: "https://podcast.example.com/audio/ep99.mp3",
                expectedLength: 48_234_567,
                expectedType: "audio/mpeg"
            ),
        ]
    }

    struct VersionDetectionTestCase: Sendable {
        let fixture: String
        let expectedVersion: String
        let expectedTitle: String

        static let cases: [VersionDetectionTestCase] = [
            VersionDetectionTestCase(fixture: "valid_rss1_feed.xml", expectedVersion: "1.0", expectedTitle: "Example RSS 1.0 Feed"),
            VersionDetectionTestCase(fixture: "minimal_rss1_feed.xml", expectedVersion: "1.0", expectedTitle: "Minimal RSS 1.0 Feed"),
            VersionDetectionTestCase(fixture: "valid_feed.xml", expectedVersion: "2.0", expectedTitle: "Example RSS Feed"),
            VersionDetectionTestCase(fixture: "minimal_feed.xml", expectedVersion: "2.0", expectedTitle: "Minimal Feed"),
        ]
    }

    struct JapaneseFeedVersionTestCase: Sendable {
        let fixture: String
        let expectedVersion: String

        static let cases: [JapaneseFeedVersionTestCase] = [
            JapaneseFeedVersionTestCase(fixture: "japanese_rss1_feed.xml", expectedVersion: "1.0"),
            JapaneseFeedVersionTestCase(fixture: "japanese_feed.xml", expectedVersion: "2.0"),
        ]
    }

    struct XMLEntityTestCase: Sendable {
        let encoded: String
        let expected: String

        static let cases: [XMLEntityTestCase] = [
            XMLEntityTestCase(encoded: "Feed &amp; More", expected: "Feed & More"),
            XMLEntityTestCase(encoded: "Less &lt;than&gt; greater", expected: "Less <than> greater"),
            XMLEntityTestCase(encoded: "Quote &quot;test&quot;", expected: "Quote \"test\""),
            XMLEntityTestCase(encoded: "Apostrophe &apos;s", expected: "Apostrophe 's"),
        ]
    }

    @Test(arguments: FeedTestCase.validFeeds)
    func parsesValidFixtures(testCase: FeedTestCase) throws {
        let data = try loadFixture(testCase.fixture)
        let feed = try parser.parse(data)

        #expect(feed.version == "2.0")
        #expect(feed.channel.title == testCase.expectedTitle)
        #expect(feed.channel.link.absoluteString == testCase.expectedLink)
        #expect(feed.channel.description == testCase.expectedDescription)
    }

    @Test
    func parsesJapaneseFeed() throws {
        let data = try loadFixture("japanese_feed.xml")
        let feed = try parser.parse(data)

        #expect(feed.version == "2.0")
        #expect(feed.channel.title.isEmpty == false)
        #expect(feed.channel.link.absoluteString == "https://tech-news.example.jp")
        #expect(feed.channel.description.isEmpty == false)
    }

    @Test(arguments: [
        "invalid_no_channel.xml",
        "invalid_not_rss.xml",
    ])
    func throwsForInvalidFixtures(fixture: String) throws {
        let data = try loadFixture(fixture)

        #expect(throws: RSSError.invalidRSSStructure) {
            try parser.parse(data)
        }
    }

    @Test(arguments: [
        "This is not XML at all",
        "<broken><unclosed>",
        "<?xml version=\"1.0\"?><rss><channel><title>Unclosed",
        "",
    ])
    func throwsForInvalidXMLStrings(input: String) {
        #expect(throws: RSSError.self) {
            try parser.parse(input)
        }
    }

    @Test
    func parsesChannelMetadata() throws {
        let data = try loadFixture("valid_feed.xml")
        let channel = try parser.parse(data).channel

        #expect(channel.language == "en-us")
        #expect(channel.copyright == "Copyright 2024 Example Inc.")
        #expect(channel.managingEditor == "editor@example.com")
        #expect(channel.webMaster == "webmaster@example.com")
        #expect(channel.generator == "RSSKit Test Generator")
        #expect(channel.docs?.absoluteString == "https://www.rssboard.org/rss-specification")
        #expect(channel.ttl == 60)
        #expect(channel.pubDate != nil)
        #expect(channel.lastBuildDate != nil)
    }

    @Test
    func parsesChannelCategories() throws {
        let data = try loadFixture("valid_feed.xml")
        let categories = try parser.parse(data).channel.categories

        #expect(categories.count == 2)
        #expect(categories[0].value == "Technology")
        #expect(categories[0].domain == nil)
        #expect(categories[1].value == "Programming")
        #expect(categories[1].domain == "https://example.com/categories")
    }

    @Test
    func parsesChannelImage() throws {
        let data = try loadFixture("valid_feed.xml")
        let image = try parser.parse(data).channel.image

        #expect(image?.url.absoluteString == "https://example.com/logo.png")
        #expect(image?.title == "Example Logo")
        #expect(image?.link.absoluteString == "https://example.com")
        #expect(image?.width == 88)
        #expect(image?.height == 31)
        #expect(image?.description == "Site logo")
    }

    @Test(arguments: ItemCountTestCase.rss2Feeds)
    func parsesItemCount(testCase: ItemCountTestCase) throws {
        let data = try loadFixture(testCase.fixture)
        let feed = try parser.parse(data)

        #expect(feed.channel.items.count == testCase.expectedCount)
    }

    @Test
    func parsesFirstItemWithAllFields() throws {
        let data = try loadFixture("valid_feed.xml")
        let item = try parser.parse(data).channel.items[0]

        #expect(item.title == "First Article")
        #expect(item.link?.absoluteString == "https://example.com/articles/1")
        #expect(item.description == "This is the first article.")
        #expect(item.author == "author@example.com")
        #expect(item.comments?.absoluteString == "https://example.com/articles/1#comments")
        #expect(item.pubDate != nil)
        #expect(item.categories.count == 1)
        #expect(item.categories[0].value == "News")
        #expect(item.enclosure?.url.absoluteString == "https://example.com/audio/episode1.mp3")
        #expect(item.enclosure?.length == 12_345_678)
        #expect(item.enclosure?.type == "audio/mpeg")
        #expect(item.guid?.value == "https://example.com/articles/1")
        #expect(item.guid?.isPermaLink == true)
        #expect(item.source?.value == "Source Feed")
        #expect(item.source?.url.absoluteString == "https://source.com/feed.xml")
    }

    @Test(arguments: GUIDTestCase.cases)
    func parsesGUIDIsPermaLink(testCase: GUIDTestCase) throws {
        let data = try loadFixture(testCase.fixture)
        let items = try parser.parse(data).channel.items

        guard testCase.itemIndex < items.count, let guid = items[testCase.itemIndex].guid else {
            return // Skip if no GUID
        }
        #expect(guid.isPermaLink == testCase.expectedIsPermaLink)
    }

    @Test(arguments: EnclosureTestCase.podcastEnclosures)
    func parsesPodcastEnclosures(testCase: EnclosureTestCase) throws {
        let data = try loadFixture("podcast_feed.xml")
        let enclosure = try parser.parse(data).channel.items[testCase.itemIndex].enclosure

        #expect(enclosure?.url.absoluteString == testCase.expectedURL)
        #expect(enclosure?.length == testCase.expectedLength)
        #expect(enclosure?.type == testCase.expectedType)
    }

    @Test(arguments: [0, 1])
    func parsesJapaneseItems(itemIndex: Int) throws {
        let data = try loadFixture("japanese_feed.xml")
        let item = try parser.parse(data).channel.items[itemIndex]

        #expect(item.title?.isEmpty == false)
        #expect(item.categories.isEmpty == false)
    }

    @Test
    func parsesCDATAContent() throws {
        let data = try loadFixture("valid_feed.xml")
        let item = try parser.parse(data).channel.items[2]

        #expect(item.description == "<p>HTML content with <strong>formatting</strong>.</p>")
    }

    @Test
    func minimalFeedHasNilOptionalFields() throws {
        let data = try loadFixture("minimal_feed.xml")
        let channel = try parser.parse(data).channel

        #expect(channel.items.isEmpty)
        #expect(channel.image == nil)
        #expect(channel.categories.isEmpty)
        #expect(channel.language == nil)
        #expect(channel.copyright == nil)
        #expect(channel.managingEditor == nil)
        #expect(channel.webMaster == nil)
        #expect(channel.pubDate == nil)
        #expect(channel.lastBuildDate == nil)
        #expect(channel.generator == nil)
        #expect(channel.docs == nil)
        #expect(channel.ttl == nil)
    }

    @Test
    func parsesFromString() throws {
        let xmlString = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0">
          <channel>
            <title>String Feed</title>
            <link>https://string.example.com</link>
            <description>Parsed from string</description>
          </channel>
        </rss>
        """

        let feed = try parser.parse(xmlString)

        #expect(feed.channel.title == "String Feed")
        #expect(feed.channel.description == "Parsed from string")
    }

    @Test(arguments: XMLEntityTestCase.cases)
    func handlesXMLEntities(testCase: XMLEntityTestCase) throws {
        let xmlString = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0">
          <channel>
            <title>\(testCase.encoded)</title>
            <link>https://example.com</link>
            <description>Test</description>
          </channel>
        </rss>
        """

        let feed = try parser.parse(xmlString)
        #expect(feed.channel.title == testCase.expected)
    }

    @Test(arguments: [
        "language",
        "copyright",
        "managingEditor",
        "webMaster",
        "generator",
    ])
    func emptyOptionalElementsReturnNil(element: String) throws {
        let xmlString = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0">
          <channel>
            <title>Feed</title>
            <link>https://example.com</link>
            <description>Desc</description>
            <\(element)></\(element)>
          </channel>
        </rss>
        """

        let channel = try parser.parse(xmlString).channel

        switch element {
        case "language": #expect(channel.language == nil)
        case "copyright": #expect(channel.copyright == nil)
        case "managingEditor": #expect(channel.managingEditor == nil)
        case "webMaster": #expect(channel.webMaster == nil)
        case "generator": #expect(channel.generator == nil)
        default: break
        }
    }

    @Test(arguments: [
        "2.0",
        "2.0.1",
        "2.1",
    ])
    func parsesVersionAttribute(version: String) throws {
        let xmlString = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="\(version)">
          <channel>
            <title>Feed</title>
            <link>https://example.com</link>
            <description>Desc</description>
          </channel>
        </rss>
        """

        let feed = try parser.parse(xmlString)
        #expect(feed.version == version)
    }

    @Test
    func ignoresUnknownElements() throws {
        let xmlString = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0">
          <channel>
            <title>Feed</title>
            <link>https://example.com</link>
            <description>Desc</description>
            <customElement>Custom value</customElement>
            <anotherUnknown attr="value">Text</anotherUnknown>
          </channel>
        </rss>
        """

        let feed = try parser.parse(xmlString)
        #expect(feed.channel.title == "Feed")
    }

    @Test
    func ignoresNamespacedElements() throws {
        let xmlString = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
          <channel>
            <title>Podcast</title>
            <link>https://example.com</link>
            <description>A podcast</description>
            <itunes:author>John Doe</itunes:author>
            <itunes:summary>Podcast summary</itunes:summary>
          </channel>
        </rss>
        """

        let feed = try parser.parse(xmlString)
        #expect(feed.channel.title == "Podcast")
    }

    @Test
    func trimsWhitespaceFromElements() throws {
        let xmlString = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0">
          <channel>
            <title>  Whitespace Title  </title>
            <link>https://example.com</link>
            <description>
                Multiline
                description
            </description>
          </channel>
        </rss>
        """

        let feed = try parser.parse(xmlString)

        // XMLParser trims leading/trailing whitespace from text content
        #expect(feed.channel.title == "Whitespace Title")
        #expect(feed.channel.description.contains("Multiline"))
    }

    @Test(arguments: VersionDetectionTestCase.cases)
    func autoDetectsRSSVersion(testCase: VersionDetectionTestCase) throws {
        let data = try loadFixture(testCase.fixture)
        let feed = try parser.parse(data)

        #expect(feed.version == testCase.expectedVersion)
        #expect(feed.channel.title == testCase.expectedTitle)
    }

    @Test(arguments: JapaneseFeedVersionTestCase.cases)
    func autoDetectsJapaneseFeeds(testCase: JapaneseFeedVersionTestCase) throws {
        let data = try loadFixture(testCase.fixture)
        let feed = try parser.parse(data)

        #expect(feed.version == testCase.expectedVersion)
        #expect(feed.channel.title.isEmpty == false)
    }

    @Test(arguments: ItemCountTestCase.rss1Feeds)
    func parsesRSS1ItemCount(testCase: ItemCountTestCase) throws {
        let data = try loadFixture(testCase.fixture)
        let feed = try parser.parse(data)

        #expect(feed.version == "1.0")
        #expect(feed.channel.items.count == testCase.expectedCount)
    }

    @Test
    func parsesRSS1ChannelMetadata() throws {
        let data = try loadFixture("valid_rss1_feed.xml")
        let channel = try parser.parse(data).channel

        #expect(channel.language == "en-us")
        #expect(channel.copyright == "Copyright 2024 Example Inc.")
        #expect(channel.managingEditor == "editor@example.com")
        #expect(channel.pubDate != nil)
        #expect(channel.categories.count == 2)
    }

    @Test
    func parsesRSS1ItemWithDublinCore() throws {
        let data = try loadFixture("valid_rss1_feed.xml")
        let item = try parser.parse(data).channel.items[0]

        #expect(item.title == "First Article")
        #expect(item.author == "author@example.com")
        #expect(item.pubDate != nil)
        #expect(item.categories.count == 1)
        #expect(item.categories[0].value == "News")
        #expect(item.source?.url.absoluteString == "https://source.com/feed.xml")
    }

    @Test(arguments: [0, 1])
    func parsesJapaneseRSS1Items(itemIndex: Int) throws {
        let data = try loadFixture("japanese_rss1_feed.xml")
        let item = try parser.parse(data).channel.items[itemIndex]

        #expect(item.title?.isEmpty == false)
        #expect(item.author?.isEmpty == false)
    }
}
