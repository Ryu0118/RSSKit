import Foundation

/// Parses XML data into an ``RSSXMLNode`` tree.
///
/// This struct wraps Foundation's `XMLParser` and builds
/// a simple tree structure for easier traversal.
struct XMLDocumentParser: Sendable {
    /// Parses XML data into a root ``RSSXMLNode``.
    ///
    /// - Parameter data: The XML data to parse.
    /// - Returns: The root node of the parsed XML tree.
    /// - Throws: ``RSSError/invalidXML(underlying:)`` if parsing fails.
    func parse(_ data: Data) throws -> RSSXMLNode {
        let delegate = ParserDelegate()
        let parser = XMLParser(data: data)
        parser.delegate = delegate

        guard parser.parse() else {
            let errorMessage = parser.parserError?.localizedDescription ?? "Unknown error"
            throw RSSError.invalidXML(underlying: errorMessage)
        }

        guard let root = delegate.rootNode else {
            throw RSSError.invalidXML(underlying: "No root element found")
        }

        return root
    }
}

private final class ParserDelegate: NSObject, XMLParserDelegate {
    private var nodeStack: [NodeBuilder] = []
    private(set) var rootNode: RSSXMLNode?

    private struct NodeBuilder {
        let name: String
        let attributes: [String: String]
        var text: String = ""
        var children: [RSSXMLNode] = []

        func build() -> RSSXMLNode {
            RSSXMLNode(
                name: name,
                text: text.isEmpty ? nil : text,
                attributes: attributes,
                children: children
            )
        }
    }

    func parser(
        _: XMLParser,
        didStartElement elementName: String,
        namespaceURI _: String?,
        qualifiedName _: String?,
        attributes attributeDict: [String: String]
    ) {
        let builder = NodeBuilder(name: elementName, attributes: attributeDict)
        nodeStack.append(builder)
    }

    func parser(
        _: XMLParser,
        didEndElement _: String,
        namespaceURI _: String?,
        qualifiedName _: String?
    ) {
        guard let completedBuilder = nodeStack.popLast() else { return }
        let node = completedBuilder.build()

        if nodeStack.isEmpty {
            rootNode = node
        } else {
            nodeStack[nodeStack.count - 1].children.append(node)
        }
    }

    func parser(_: XMLParser, foundCharacters string: String) {
        guard !nodeStack.isEmpty else { return }
        nodeStack[nodeStack.count - 1].text += string
    }

    func parser(_: XMLParser, foundCDATA CDATABlock: Data) {
        guard !nodeStack.isEmpty,
              let string = String(data: CDATABlock, encoding: .utf8) else { return }
        nodeStack[nodeStack.count - 1].text += string
    }
}
