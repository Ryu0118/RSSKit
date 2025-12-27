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

    @Test(arguments: [
        ("valid_feed.xml", "Example RSS Feed", "https://example.com", "An example RSS feed for testing"),
        ("minimal_feed.xml", "Minimal Feed", "https://minimal.example.com", "A minimal RSS feed with only required elements"),
        ("real_world_bbc.xml", "BBC News - Technology", "https://www.bbc.co.uk/news/technology", "BBC News - Technology"),
        ("podcast_feed.xml", "Tech Talk Podcast", "https://podcast.example.com", "Weekly discussions about the latest in technology"),
        ("japanese_feed.xml", "テック最新ニュース", "https://tech-news.example.jp", "日本語のテクノロジーニュースフィード"),
    ])
    func parsesValidFixtures(fixture: String, expectedTitle: String, expectedLink: String, expectedDescription: String) throws {
        let data = try loadFixture(fixture)
        let feed = try parser.parse(data)

        #expect(feed.version == "2.0")
        #expect(feed.channel.title == expectedTitle)
        #expect(feed.channel.link.absoluteString == expectedLink)
        #expect(feed.channel.description == expectedDescription)
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

    @Test(arguments: [
        ("valid_feed.xml", 3),
        ("minimal_feed.xml", 0),
        ("real_world_bbc.xml", 2),
        ("podcast_feed.xml", 2),
        ("japanese_feed.xml", 2),
    ])
    func parsesItemCount(fixture: String, expectedCount: Int) throws {
        let data = try loadFixture(fixture)
        let feed = try parser.parse(data)

        #expect(feed.channel.items.count == expectedCount)
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

    @Test(arguments: [
        ("valid_feed.xml", 0, true), // First item: isPermaLink="true"
        ("valid_feed.xml", 1, false), // Second item: isPermaLink="false"
        ("valid_feed.xml", 2, true), // Third item: default (true)
    ])
    func parsesGUIDIsPermaLink(fixture: String, itemIndex: Int, expected: Bool) throws {
        let data = try loadFixture(fixture)
        let items = try parser.parse(data).channel.items

        guard itemIndex < items.count, let guid = items[itemIndex].guid else {
            return // Skip if no GUID
        }
        #expect(guid.isPermaLink == expected)
    }

    @Test(arguments: [
        (0, "https://podcast.example.com/audio/ep100.mp3", 52_428_800, "audio/mpeg"),
        (1, "https://podcast.example.com/audio/ep99.mp3", 48_234_567, "audio/mpeg"),
    ])
    func parsesPodcastEnclosures(itemIndex: Int, expectedURL: String, expectedLength: Int, expectedType: String) throws {
        let data = try loadFixture("podcast_feed.xml")
        let enclosure = try parser.parse(data).channel.items[itemIndex].enclosure

        #expect(enclosure?.url.absoluteString == expectedURL)
        #expect(enclosure?.length == expectedLength)
        #expect(enclosure?.type == expectedType)
    }

    @Test(arguments: [
        (0, "Swift 6の新機能を解説", ["プログラミング"]),
        (1, "AIが変える未来の働き方", ["AI", "ビジネス"]),
    ])
    func parsesJapaneseItems(itemIndex: Int, expectedTitle: String, expectedCategories: [String]) throws {
        let data = try loadFixture("japanese_feed.xml")
        let item = try parser.parse(data).channel.items[itemIndex]

        #expect(item.title == expectedTitle)
        #expect(item.categories.map(\.value) == expectedCategories)
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

    @Test(arguments: [
        ("Feed &amp; More", "Feed & More"),
        ("Less &lt;than&gt; greater", "Less <than> greater"),
        ("Quote &quot;test&quot;", "Quote \"test\""),
        ("Apostrophe &apos;s", "Apostrophe 's"),
    ])
    func handlesXMLEntities(encoded: String, expected: String) throws {
        let xmlString = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0">
          <channel>
            <title>\(encoded)</title>
            <link>https://example.com</link>
            <description>Test</description>
          </channel>
        </rss>
        """

        let feed = try parser.parse(xmlString)
        #expect(feed.channel.title == expected)
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
}
