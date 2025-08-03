# 🤝 Contributing to iOS Real-Time Communication Framework

Thank you for your interest in contributing to the iOS Real-Time Communication Framework!

## 📋 Table of Contents

- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Pull Request Process](#pull-request-process)

---

## 🚀 Getting Started

### Prerequisites

- **Xcode**: 15.0 or later
- **Swift**: 5.9 or later
- **iOS SDK**: 15.0 or later
- **Git**: Latest version

### Required Knowledge

- **Swift Programming**: Advanced Swift knowledge
- **iOS Development**: Experience with iOS frameworks
- **Networking**: Understanding of WebSocket and HTTP protocols
- **Architecture**: Clean Architecture and SOLID principles
- **Testing**: Unit testing and integration testing experience

---

## 🛠️ Development Setup

### 1. Fork and Clone

```bash
# Fork the repository on GitHub
# Clone your fork
git clone https://github.com/your-username/iOS-Real-Time-Communication-Framework.git
cd iOS-Real-Time-Communication-Framework
```

### 2. Setup Development Environment

```bash
# Install dependencies
swift package resolve

# Build the project
swift build

# Run tests
swift test
```

---

## 📝 Coding Standards

### Swift Style Guide

We follow the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/).

#### Naming Conventions

```swift
// ✅ Correct
class RealTimeManager { }
func connectToServer() { }
let connectionStatus: ConnectionStatus

// ❌ Incorrect
class realTimeManager { }
func connect_to_server() { }
let connection_status: ConnectionStatus
```

#### Code Organization

```swift
// MARK: - Properties
private let configuration: RealTimeConfig
private var connection: WebSocketConnection?

// MARK: - Initialization
init(configuration: RealTimeConfig) {
    self.configuration = configuration
}

// MARK: - Public Methods
func connect() async throws -> ConnectionResult {
    // Implementation
}
```

---

## 🧪 Testing Guidelines

### Test Structure

```swift
import XCTest
@testable import RealTimeCommunication

final class RealTimeManagerTests: XCTestCase {
    
    private var sut: RealTimeManager!
    private var mockWebSocket: MockWebSocketConnection!
    
    override func setUp() {
        super.setUp()
        mockWebSocket = MockWebSocketConnection()
        sut = RealTimeManager(webSocket: mockWebSocket)
    }
    
    override func tearDown() {
        sut = nil
        mockWebSocket = nil
        super.tearDown()
    }
    
    func test_connect_success() async throws {
        // Given
        mockWebSocket.shouldConnect = true
        
        // When
        let result = try await sut.connect()
        
        // Then
        XCTAssertEqual(result.status, .connected)
        XCTAssertTrue(mockWebSocket.isConnected)
    }
}
```

### Test Categories

- **Unit Tests**: 100% coverage for business logic
- **Integration Tests**: End-to-end workflows
- **Performance Tests**: Benchmarks and memory usage
- **Security Tests**: Authentication and encryption

---

## 🔄 Pull Request Process

### Before Submitting

1. **Check Existing Issues**: Search for similar issues or PRs
2. **Create Issue**: Discuss significant changes before implementation
3. **Update Documentation**: Ensure documentation is current
4. **Write Tests**: Include tests for new functionality
5. **Follow Style Guide**: Ensure code follows project standards

### Pull Request Template

```markdown
## Description

Brief description of changes and motivation.

## Type of Change

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing

- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Performance tests pass
- [ ] Manual testing completed

## Checklist

- [ ] Code follows project style guidelines
- [ ] Self-review of code completed
- [ ] Documentation updated
- [ ] Tests added for new functionality
- [ ] All tests pass
- [ ] No breaking changes (or breaking changes documented)
```

---

## 🎯 Contribution Areas

### High Priority

- **Performance Optimization**: Improve connection speed and reliability
- **Security Enhancements**: Add encryption and authentication features
- **Error Handling**: Improve error recovery and user feedback
- **Testing**: Increase test coverage and quality

### Medium Priority

- **New Features**: Additional communication protocols
- **Platform Support**: macOS, tvOS, watchOS support
- **Documentation**: Improve and expand documentation
- **Examples**: Add more sample applications

---

## 📞 Contact

- **Issues**: [GitHub Issues](https://github.com/muhittincamdali/iOS-Real-Time-Communication-Framework/issues)
- **Discussions**: [GitHub Discussions](https://github.com/muhittincamdali/iOS-Real-Time-Communication-Framework/discussions)

---

<div align="center">

**🚀 Together we build the future of real-time communication!**

</div> 