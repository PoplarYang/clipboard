import Foundation
import XCTest
@testable import ClipboardCore

final class ClipboardToolTests: XCTestCase {
    func testOutputPathResolverExpandsTildeAndCreatesDirectories() throws {
        let tmpRoot = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tmpRoot, withIntermediateDirectories: true)

        let resolver = OutputPathResolver(
            fileManager: .default,
            tildeExpander: { path in
                guard path.hasPrefix("~") else { return path }
                return path.replacingOccurrences(of: "~",
                                                 with: tmpRoot.path,
                                                 options: .anchored,
                                                 range: nil)
            }
        )

        let targetPath = "~/nested/folder/test.png"
        let resolvedURL = try resolver.resolve(path: targetPath)

        XCTAssertTrue(resolvedURL.path.hasSuffix("nested/folder/test.png"))
        var isDirectory: ObjCBool = false
        let directoryPath = resolvedURL.deletingLastPathComponent().path
        XCTAssertTrue(FileManager.default.fileExists(atPath: directoryPath, isDirectory: &isDirectory))
        XCTAssertTrue(isDirectory.boolValue)
    }

    func testClipboardSaverWritesPNG() throws {
        let tempURL = temporaryFileURL()
        let pngData = Data(repeating: 0xFF, count: 8)

        let saver = ClipboardSaver(
            dataSource: MockClipboardDataSource(
                capturedSnapshot: ClipboardSnapshot(pngData: pngData, availableTypes: ["public.png"])
            )
        )

        let result = try saver.savePNG(to: tempURL)

        XCTAssertEqual(result.byteCount, pngData.count)
        XCTAssertEqual(try Data(contentsOf: tempURL), pngData)
    }

    func testClipboardSaverThrowsWhenPNGMissingButReportsTypes() {
        let saver = ClipboardSaver(
            dataSource: MockClipboardDataSource(
                capturedSnapshot: ClipboardSnapshot(pngData: nil, availableTypes: ["public.jpeg"])
            )
        )

        XCTAssertThrowsError(try saver.savePNG(to: temporaryFileURL())) { error in
            guard case let ClipboardError.missingPNG(types) = error else {
                return XCTFail("Expected missingPNG error, got \(error)")
            }
            XCTAssertEqual(types, ["public.jpeg"])
        }
    }

    private func temporaryFileURL() -> URL {
        URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("png")
    }

    static var allTests = [
        ("testOutputPathResolverExpandsTildeAndCreatesDirectories", testOutputPathResolverExpandsTildeAndCreatesDirectories),
        ("testClipboardSaverWritesPNG", testClipboardSaverWritesPNG),
        ("testClipboardSaverThrowsWhenPNGMissingButReportsTypes", testClipboardSaverThrowsWhenPNGMissingButReportsTypes),
    ]
}

private struct MockClipboardDataSource: ClipboardDataSource {
    let capturedSnapshot: ClipboardSnapshot

    func snapshot() throws -> ClipboardSnapshot {
        capturedSnapshot
    }
}
