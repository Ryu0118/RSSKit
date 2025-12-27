# RSSKit

A lightweight Swift library for parsing RSS 2.0 feeds.

## Features

- RSS 2.0 compliant parsing
- Fully type-safe with Swift's strong typing
- `Sendable` conformance for safe concurrency
- Zero external dependencies (uses only Foundation)
- Comprehensive error handling

## Requirements

- Swift 6.2+
- iOS 16.0+ / macOS 13.0+ / tvOS 16.0+ / watchOS 9.0+ / visionOS 1.0+

## Installation

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Ryu0118/RSSKit.git", from: "0.1.0")
]
```

Or add it through Xcode: File → Add Package Dependencies.

## Usage

### Basic Parsing

```swift
import RSSKit

let parser = RSSParser()

// Parse from Data
let feed = try parser.parse(data)

// Or parse from String
let feed = try parser.parse(xmlString)
```

### Accessing Feed Content

```swift
// Channel metadata
print(feed.channel.title)
print(feed.channel.link)
print(feed.channel.description)

// Optional channel properties
if let language = feed.channel.language {
    print("Language: \(language)")
}

// Iterate over items
for item in feed.channel.items {
    print(item.title ?? "Untitled")
    print(item.description ?? "")

    if let link = item.link {
        print("Read more: \(link)")
    }
}
```

### Working with Dates

```swift
for item in feed.channel.items {
    if let pubDate = item.pubDate {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        print("Published: \(formatter.string(from: pubDate))")
    }
}
```

### Podcast Enclosures

```swift
for item in feed.channel.items {
    if let enclosure = item.enclosure {
        print("Media URL: \(enclosure.url)")
        print("Type: \(enclosure.type)")        // e.g., "audio/mpeg"
        print("Size: \(enclosure.length) bytes")
    }
}
```

### Categories

```swift
// Channel categories
for category in feed.channel.categories {
    print(category.value)
    if let domain = category.domain {
        print("  Domain: \(domain)")
    }
}

// Item categories
for item in feed.channel.items {
    let categoryNames = item.categories.map(\.value)
    print("Tags: \(categoryNames.joined(separator: ", "))")
}
```

### Error Handling

```swift
do {
    let feed = try parser.parse(data)
} catch let error as RSSError {
    switch error {
    case .invalidXML(let underlying):
        print("XML parsing failed: \(underlying)")
    case .invalidRSSStructure:
        print("Not a valid RSS feed")
    case .missingRequiredElement(let element):
        print("Missing required element: \(element)")
    case .invalidURL(let urlString):
        print("Invalid URL: \(urlString)")
    case .invalidDateFormat(let dateString):
        print("Could not parse date: \(dateString)")
    case .invalidNumber(let element, let value):
        print("Invalid number in \(element): \(value)")
    case .unsupportedVersion(let version):
        print("Unsupported RSS version: \(version)")
    }
}
```

## Limitations

- **RSS 2.0 only**: Atom and JSON Feed formats are not supported
- **Read-only**: Feed generation is not supported
- **Standard elements only**: Namespace extensions (e.g., iTunes podcast tags) are ignored

## License

MIT
