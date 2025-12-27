@testable import RSSKit
import Foundation
import Testing

struct RSSParserTests {
    let parser = RSSParser()

    // MARK: - Test Helpers

    private func loadFixture(_ name: String) throws -> Data {
        let fixturesURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("Fixtures")
            .appendingPathComponent(name)

        return try Data(contentsOf: fixturesURL)
    }

    // MARK: - Valid Feed Parsing

    @Test
    func parsesValidFeed() throws {
        let data = try loadFixture("valid_feed.xml")
        let feed = try parser.parse(data)

        #expect(feed.version == "2.0")
        #expect(feed.channel.title == "Example RSS Feed")
        #expect(feed.channel.link.absoluteString == "https://example.com")
        #expect(feed.channel.description == "An example RSS feed for testing")
    }

    @Test
    func parsesChannelMetadata() throws {
        let data = try loadFixture("valid_feed.xml")
        let feed = try parser.parse(data)
        let channel = feed.channel

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
        let feed = try parser.parse(data)

        #expect(feed.channel.categories.count == 2)
        #expect(feed.channel.categories[0].value == "Technology")
        #expect(feed.channel.categories[0].domain == nil)
        #expect(feed.channel.categories[1].value == "Programming")
        #expect(feed.channel.categories[1].domain == "https://example.com/categories")
    }

    @Test
    func parsesChannelImage() throws {
        let data = try loadFixture("valid_feed.xml")
        let feed = try parser.parse(data)
        let image = feed.channel.image

        #expect(image?.url.absoluteString == "https://example.com/logo.png")
        #expect(image?.title == "Example Logo")
        #expect(image?.link.absoluteString == "https://example.com")
        #expect(image?.width == 88)
        #expect(image?.height == 31)
        #expect(image?.description == "Site logo")
    }

    @Test
    func parsesItems() throws {
        let data = try loadFixture("valid_feed.xml")
        let feed = try parser.parse(data)

        #expect(feed.channel.items.count == 3)
    }

    @Test
    func parsesFirstItemWithAllFields() throws {
        let data = try loadFixture("valid_feed.xml")
        let feed = try parser.parse(data)
        let item = feed.channel.items[0]

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

    @Test
    func parsesGUIDWithPermaLinkFalse() throws {
        let data = try loadFixture("valid_feed.xml")
        let feed = try parser.parse(data)
        let item = feed.channel.items[1]

        #expect(item.guid?.value == "article-2-unique-id")
        #expect(item.guid?.isPermaLink == false)
    }

    @Test
    func parsesItemWithMultipleCategories() throws {
        let data = try loadFixture("valid_feed.xml")
        let feed = try parser.parse(data)
        let item = feed.channel.items[2]

        #expect(item.categories.count == 2)
        #expect(item.categories.map(\.value) == ["Tech", "Swift"])
    }

    @Test
    func parsesCDATAContent() throws {
        let data = try loadFixture("valid_feed.xml")
        let feed = try parser.parse(data)
        let item = feed.channel.items[2]

        #expect(item.description == "<p>HTML content with <strong>formatting</strong>.</p>")
    }

    // MARK: - Minimal Feed

    @Test
    func parsesMinimalFeed() throws {
        let data = try loadFixture("minimal_feed.xml")
        let feed = try parser.parse(data)

        #expect(feed.version == "2.0")
        #expect(feed.channel.title == "Minimal Feed")
        #expect(feed.channel.link.absoluteString == "https://minimal.example.com")
        #expect(feed.channel.description == "A minimal RSS feed with only required elements")

        #expect(feed.channel.items.isEmpty)
        #expect(feed.channel.image == nil)
        #expect(feed.channel.categories.isEmpty)
        #expect(feed.channel.language == nil)
        #expect(feed.channel.ttl == nil)
    }

    // MARK: - Invalid Feeds

    @Test
    func throwsForMissingChannel() throws {
        let data = try loadFixture("invalid_no_channel.xml")

        #expect(throws: RSSError.invalidRSSStructure) {
            try parser.parse(data)
        }
    }

    @Test
    func throwsForNonRSSDocument() throws {
        let data = try loadFixture("invalid_not_rss.xml")

        #expect(throws: RSSError.invalidRSSStructure) {
            try parser.parse(data)
        }
    }

    @Test
    func throwsForInvalidXML() {
        let invalidXML = "This is not XML at all"
        let data = invalidXML.data(using: .utf8)!

        #expect(throws: RSSError.self) {
            try parser.parse(data)
        }
    }

    @Test
    func throwsForMalformedXML() {
        let malformedXML = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
              <channel>
                <title>Unclosed
            """
        let data = malformedXML.data(using: .utf8)!

        #expect(throws: RSSError.self) {
            try parser.parse(data)
        }
    }

    // MARK: - String Parsing

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

    // MARK: - Real-World Feed Simulation

    @Test
    func parsesBBCStyleFeed() throws {
        let data = try loadFixture("real_world_bbc.xml")
        let feed = try parser.parse(data)

        #expect(feed.channel.title == "BBC News - Technology")
        #expect(feed.channel.language == "en-gb")
        #expect(feed.channel.copyright == "Copyright: (C) British Broadcasting Corporation")
        #expect(feed.channel.items.count == 2)

        let firstItem = feed.channel.items[0]
        #expect(firstItem.title == "Tech giants face new regulations")
        #expect(firstItem.guid?.isPermaLink == false)
    }

    @Test
    func parsesPodcastFeed() throws {
        let data = try loadFixture("podcast_feed.xml")
        let feed = try parser.parse(data)

        #expect(feed.channel.title == "Tech Talk Podcast")
        #expect(feed.channel.generator == "Podcast Generator 1.0")
        #expect(feed.channel.items.count == 2)

        let episode = feed.channel.items[0]
        #expect(episode.title == "Episode 100: The Future of AI")
        #expect(episode.enclosure?.url.absoluteString == "https://podcast.example.com/audio/ep100.mp3")
        #expect(episode.enclosure?.length == 52_428_800)
        #expect(episode.enclosure?.type == "audio/mpeg")
    }

    @Test
    func parsesJapaneseFeed() throws {
        let data = try loadFixture("japanese_feed.xml")
        let feed = try parser.parse(data)

        #expect(feed.channel.title == "テック最新ニュース")
        #expect(feed.channel.language == "ja")
        #expect(feed.channel.description == "日本語のテクノロジーニュースフィード")
        #expect(feed.channel.items.count == 2)

        let firstItem = feed.channel.items[0]
        #expect(firstItem.title == "Swift 6の新機能を解説")
        #expect(firstItem.categories.first?.value == "プログラミング")

        let secondItem = feed.channel.items[1]
        #expect(secondItem.categories.count == 2)
        #expect(secondItem.categories.map(\.value) == ["AI", "ビジネス"])
    }

    // MARK: - Edge Cases

    @Test
    func handlesWhitespaceInElements() throws {
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

    @Test
    func handlesEmptyElements() throws {
        let xmlString = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
              <channel>
                <title>Feed</title>
                <link>https://example.com</link>
                <description>Desc</description>
                <language></language>
                <copyright></copyright>
              </channel>
            </rss>
            """

        let feed = try parser.parse(xmlString)

        #expect(feed.channel.language == nil)
        #expect(feed.channel.copyright == nil)
    }

    @Test
    func handlesSpecialCharacters() throws {
        let xmlString = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
              <channel>
                <title>Feed &amp; More</title>
                <link>https://example.com</link>
                <description>Less &lt;than&gt; greater</description>
              </channel>
            </rss>
            """

        let feed = try parser.parse(xmlString)

        #expect(feed.channel.title == "Feed & More")
        #expect(feed.channel.description == "Less <than> greater")
    }

    @Test
    func handlesVersionAttribute() throws {
        let xmlString = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0.1">
              <channel>
                <title>Feed</title>
                <link>https://example.com</link>
                <description>Desc</description>
              </channel>
            </rss>
            """

        let feed = try parser.parse(xmlString)

        #expect(feed.version == "2.0.1")
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
}
