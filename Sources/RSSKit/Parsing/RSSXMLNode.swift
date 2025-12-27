import Foundation

/// A lightweight wrapper around parsed XML elements.
///
/// Provides a simple interface for traversing and extracting
/// values from XML documents without exposing XMLParser internals.
struct RSSXMLNode: Sendable, Equatable {
    /// The element name (e.g., "channel", "item").
    let name: String

    /// The text content of the element.
    let text: String?

    /// Attributes of the element.
    let attributes: [String: String]

    /// Child elements.
    let children: [RSSXMLNode]

    init(
        name: String,
        text: String? = nil,
        attributes: [String: String] = [:],
        children: [RSSXMLNode] = []
    ) {
        self.name = name
        self.text = text
        self.attributes = attributes
        self.children = children
    }
}

extension RSSXMLNode {
    /// Returns the first child element with the given name.
    func child(named name: String) -> RSSXMLNode? {
        children.first { $0.name == name }
    }

    /// Returns the first child element with the given RSS element type.
    func child(_ element: RSSElement) -> RSSXMLNode? {
        child(named: element.rawValue)
    }

    /// Returns all child elements with the given name.
    func children(named name: String) -> [RSSXMLNode] {
        children.filter { $0.name == name }
    }

    /// Returns all child elements with the given RSS element type.
    func children(_ element: RSSElement) -> [RSSXMLNode] {
        children(named: element.rawValue)
    }
}

extension RSSXMLNode {
    /// Returns the trimmed text content, or nil if empty.
    var trimmedText: String? {
        guard let text = text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty
        else {
            return nil
        }
        return text
    }

    /// Returns the text content of a child element.
    func text(for element: RSSElement) -> String? {
        child(element)?.trimmedText
    }

    /// Returns an attribute value.
    func attribute(_ name: String) -> String? {
        attributes[name]
    }

    /// Returns an attribute value for an RSS element.
    func attribute(_ element: RSSElement) -> String? {
        attribute(element.rawValue)
    }
}
