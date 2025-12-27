# RSSKit

A lightweight Swift library for parsing RSS feeds.

## Project Overview

RSSKit is a modular RSS parsing library that prioritizes simplicity and correctness over feature breadth.

**Modules:**
- `RSS2Kit` - RSS 2.0 parsing only
- `RSS1Kit` - RSS 1.0 (RDF) parsing only
- `RSSKit` - Unified API with auto-detection (imports both)

**Not Supported:**
- Atom feeds
- JSON Feed
- RSS feed creation/writing

## Build Requirements

- Swift 6.2+
- Xcode 26.1+
- Platform versions:
  - iOS 16.0+
  - macOS 13.0+
  - tvOS 16.0+
  - watchOS 9.0+
  - visionOS 1.0+

## Architecture

### Design Principles

- **SOLID**: Each type has a single responsibility
- **DRY**: Shared logic extracted into reusable components
- **One major type per file**: Keep files focused and navigable
- **Abstraction through composition**: Break complex parsing into smaller, testable units

### Module Structure

```
Sources/
├── RSSCore/              # Shared models and utilities
│   ├── Models/           # RSSFeed, RSSChannel, RSSItem, etc.
│   ├── Parsing/          # Shared parsing utilities (XMLDocumentParser, DateParser)
│   └── Errors/           # RSSError
├── RSS2Kit/              # RSS 2.0 parser
│   └── RSS2Parser.swift
├── RSS1Kit/              # RSS 1.0 parser
│   └── RSS1Parser.swift
└── RSSKit/               # Unified API with auto-detection
    └── RSSParser.swift

Tests/
├── RSSCoreTests/
├── RSS2KitTests/
├── RSS1KitTests/
└── RSSKitTests/
    └── Fixtures/         # Sample RSS feeds for testing
```

### Key Types

| Type | Module | Responsibility |
|------|--------|----------------|
| `RSSFeed` | RSSCore | Root model representing a parsed RSS feed |
| `RSSChannel` | RSSCore | Channel metadata (title, link, description, etc.) |
| `RSSItem` | RSSCore | Individual feed item |
| `RSSError` | RSSCore | Parsing and validation errors |
| `RSS2Parser` | RSS2Kit | RSS 2.0 parser |
| `RSS1Parser` | RSS1Kit | RSS 1.0 parser |
| `RSSParser` | RSSKit | Unified parser with auto-detection |

### Dublin Core Mapping (RSS 1.0)

| Dublin Core | RSSChannel/RSSItem |
|-------------|-------------------|
| `dc:creator` | `managingEditor` (channel) / `author` (item) |
| `dc:date` | `pubDate` |
| `dc:subject` | `categories` |
| `dc:rights` | `copyright` |
| `dc:language` | `language` |

## Code Style

### Swift Conventions

- Use Swift 6 strict concurrency
- Prefer value types (`struct`) over reference types
- Use `Sendable` where appropriate
- Leverage Swift's type system for safety

### Naming

- Models: Noun-based (`RSSFeed`, `RSSItem`)
- Parsers: Suffix with `Parser` (`RSS1Parser`, `RSS2Parser`)
- Errors: Suffix with `Error` (`RSSError`)

### Documentation

- Document all public APIs with DocC-compatible comments
- Include code examples for main entry points

## Testing

Follow these guidelines:

- Test each parser in isolation
- Use fixture files for complex RSS documents
- Test edge cases (malformed XML, missing elements, encoding issues)
- Aim for high coverage on parsing logic

Run tests:
```bash
swift test
```

## Dependencies

None. RSSKit uses only Foundation's `XMLParser`.
