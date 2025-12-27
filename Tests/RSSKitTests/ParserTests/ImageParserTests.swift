@testable import RSSKit
import Testing

struct ImageParserTests {
    let parser = ImageParser()

    // MARK: - Valid Image

    @Test
    func parsesRequiredFields() throws {
        let node = RSSXMLNode(
            name: "image",
            children: [
                RSSXMLNode(name: "url", text: "https://example.com/image.png"),
                RSSXMLNode(name: "title", text: "Logo"),
                RSSXMLNode(name: "link", text: "https://example.com"),
            ]
        )

        let image = try #require(parser.parse(node))

        #expect(image.url.absoluteString == "https://example.com/image.png")
        #expect(image.title == "Logo")
        #expect(image.link.absoluteString == "https://example.com")
    }

    @Test
    func parsesOptionalFields() throws {
        let node = RSSXMLNode(
            name: "image",
            children: [
                RSSXMLNode(name: "url", text: "https://example.com/image.png"),
                RSSXMLNode(name: "title", text: "Logo"),
                RSSXMLNode(name: "link", text: "https://example.com"),
                RSSXMLNode(name: "width", text: "88"),
                RSSXMLNode(name: "height", text: "31"),
                RSSXMLNode(name: "description", text: "Site logo"),
            ]
        )

        let image = try #require(parser.parse(node))

        #expect(image.width == 88)
        #expect(image.height == 31)
        #expect(image.description == "Site logo")
    }

    @Test
    func returnsNilForOptionalFieldsWhenMissing() throws {
        let node = RSSXMLNode(
            name: "image",
            children: [
                RSSXMLNode(name: "url", text: "https://example.com/image.png"),
                RSSXMLNode(name: "title", text: "Logo"),
                RSSXMLNode(name: "link", text: "https://example.com"),
            ]
        )

        let image = try #require(parser.parse(node))

        #expect(image.width == nil)
        #expect(image.height == nil)
        #expect(image.description == nil)
    }

    // MARK: - Missing Required Fields

    @Test
    func returnsNilWhenURLMissing() {
        let node = RSSXMLNode(
            name: "image",
            children: [
                RSSXMLNode(name: "title", text: "Logo"),
                RSSXMLNode(name: "link", text: "https://example.com"),
            ]
        )

        #expect(parser.parse(node) == nil)
    }

    @Test
    func returnsNilWhenTitleMissing() {
        let node = RSSXMLNode(
            name: "image",
            children: [
                RSSXMLNode(name: "url", text: "https://example.com/image.png"),
                RSSXMLNode(name: "link", text: "https://example.com"),
            ]
        )

        #expect(parser.parse(node) == nil)
    }

    @Test
    func returnsNilWhenLinkMissing() {
        let node = RSSXMLNode(
            name: "image",
            children: [
                RSSXMLNode(name: "url", text: "https://example.com/image.png"),
                RSSXMLNode(name: "title", text: "Logo"),
            ]
        )

        #expect(parser.parse(node) == nil)
    }

    // MARK: - Invalid URLs

    @Test
    func returnsNilForEmptyImageURL() {
        let node = RSSXMLNode(
            name: "image",
            children: [
                RSSXMLNode(name: "url", text: ""),
                RSSXMLNode(name: "title", text: "Logo"),
                RSSXMLNode(name: "link", text: "https://example.com"),
            ]
        )

        #expect(parser.parse(node) == nil)
    }

    @Test
    func returnsNilForEmptyLinkURL() {
        let node = RSSXMLNode(
            name: "image",
            children: [
                RSSXMLNode(name: "url", text: "https://example.com/image.png"),
                RSSXMLNode(name: "title", text: "Logo"),
                RSSXMLNode(name: "link", text: ""),
            ]
        )

        #expect(parser.parse(node) == nil)
    }

    // MARK: - Invalid Dimensions

    @Test
    func ignoresInvalidWidth() throws {
        let node = RSSXMLNode(
            name: "image",
            children: [
                RSSXMLNode(name: "url", text: "https://example.com/image.png"),
                RSSXMLNode(name: "title", text: "Logo"),
                RSSXMLNode(name: "link", text: "https://example.com"),
                RSSXMLNode(name: "width", text: "invalid"),
            ]
        )

        let image = try #require(parser.parse(node))
        #expect(image.width == nil)
    }

    @Test
    func ignoresInvalidHeight() throws {
        let node = RSSXMLNode(
            name: "image",
            children: [
                RSSXMLNode(name: "url", text: "https://example.com/image.png"),
                RSSXMLNode(name: "title", text: "Logo"),
                RSSXMLNode(name: "link", text: "https://example.com"),
                RSSXMLNode(name: "height", text: "abc"),
            ]
        )

        let image = try #require(parser.parse(node))
        #expect(image.height == nil)
    }
}
