import Foundation
import CommandLineKit
#if canImport(AppKit)
import AppKit
#endif

public enum RuntimeExit: Error {
    case success
}

public enum ClipboardError: LocalizedError {
    case invalidOutputDirectory(String)
    case missingPNG([String])
    case platformUnsupported

    public var errorDescription: String? {
        switch self {
        case .invalidOutputDirectory(let path):
            return "The output directory '\(path)' is not a folder."
        case .missingPNG(let types):
            guard !types.isEmpty else {
                return "Clipboard does not contain any PNG data."
            }
            return "Clipboard contains \(types.joined(separator: ", ")) but no PNG representation."
        case .platformUnsupported:
            return "This tool requires macOS 10.13 or later with AppKit."
        }
    }
}

public struct ClipboardSaveResult {
    public let outputURL: URL
    public let byteCount: Int
}

public struct ClipboardSnapshot {
    public let pngData: Data?
    public let availableTypes: [String]
}

public protocol ClipboardDataSource {
    func snapshot() throws -> ClipboardSnapshot
}

struct ClipboardSaver {
    let dataSource: ClipboardDataSource

    func savePNG(to outputURL: URL) throws -> ClipboardSaveResult {
        let snapshot = try dataSource.snapshot()
        guard let data = snapshot.pngData else {
            throw ClipboardError.missingPNG(snapshot.availableTypes)
        }
        try data.write(to: outputURL, options: .atomic)
        return ClipboardSaveResult(outputURL: outputURL, byteCount: data.count)
    }
}

struct OutputPathResolver {
    private let fileManager: FileManager
    private let tildeExpander: (String) -> String

    init(fileManager: FileManager = .default,
         tildeExpander: @escaping (String) -> String = { NSString(string: $0).expandingTildeInPath }) {
        self.fileManager = fileManager
        self.tildeExpander = tildeExpander
    }

    func resolve(path: String) throws -> URL {
        let expandedPath = tildeExpander(path)
        let normalizedPath = NSString(string: expandedPath)
        let baseURL = URL(fileURLWithPath: fileManager.currentDirectoryPath, isDirectory: true)
        let outputURL: URL

        if normalizedPath.isAbsolutePath {
            outputURL = URL(fileURLWithPath: expandedPath).standardizedFileURL
        } else {
            outputURL = baseURL.appendingPathComponent(expandedPath).standardizedFileURL
        }
        let directoryURL = outputURL.deletingLastPathComponent()
        var isDirectory: ObjCBool = false

        if fileManager.fileExists(atPath: directoryURL.path, isDirectory: &isDirectory) {
            guard isDirectory.boolValue else {
                throw ClipboardError.invalidOutputDirectory(directoryURL.path)
            }
        } else if !directoryURL.path.isEmpty {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        }

        return outputURL
    }
}

public struct ClipboardTool {
    private let resolver: OutputPathResolver
    private let saver: ClipboardSaver

    init(resolver: OutputPathResolver, dataSource: ClipboardDataSource) {
        self.resolver = resolver
        self.saver = ClipboardSaver(dataSource: dataSource)
    }

    public func run() throws -> ClipboardSaveResult {
        let outputPath = try parseArguments()
        let resolvedURL = try resolver.resolve(path: outputPath)
        return try saver.savePNG(to: resolvedURL)
    }

    private func parseArguments() throws -> String {
        let cli = CommandLineKit.CommandLine()
        let filePath = StringOption(shortFlag: "o",
                                   longFlag: "out",
                                   required: false,
                                   helpMessage: "File path you want to save PNG to, default: ./clipboard.png")
        let help = BoolOption(shortFlag: "h",
                              longFlag: "help",
                              helpMessage: "Prints a help message.")
        cli.addOptions(filePath, help)

        do {
            try cli.parse()
        } catch {
            cli.printUsage(error)
            throw error
        }

        if help.wasSet {
            cli.printUsage()
            throw RuntimeExit.success
        }

        return filePath.value ?? "./clipboard.png"
    }
}

public extension ClipboardTool {
    static func makeDefault() throws -> ClipboardTool {
        let resolver = OutputPathResolver()
#if canImport(AppKit)
        if #available(macOS 10.13, *) {
            return ClipboardTool(resolver: resolver, dataSource: PasteboardDataSource())
        } else {
            throw ClipboardError.platformUnsupported
        }
#else
        throw ClipboardError.platformUnsupported
#endif
    }
}

#if canImport(AppKit)
@available(macOS 10.13, *)
struct PasteboardDataSource: ClipboardDataSource {
    func snapshot() throws -> ClipboardSnapshot {
        let pasteboard = NSPasteboard.general
        var pngData = pasteboard.data(forType: .png)

        if pngData == nil, let tiffData = pasteboard.data(forType: .tiff) {
            pngData = ImageConverter.pngData(fromTIFF: tiffData)
        }

        let availableTypes = pasteboard.types?.map { $0.rawValue } ?? []
        return ClipboardSnapshot(pngData: pngData, availableTypes: availableTypes)
    }
}

@available(macOS 10.13, *)
private enum ImageConverter {
    static func pngData(fromTIFF data: Data) -> Data? {
        guard let bitmap = NSBitmapImageRep(data: data) else {
            return nil
        }
        return bitmap.representation(using: .png, properties: [:])
    }
}

#else
struct PasteboardDataSource: ClipboardDataSource {
    func snapshot() throws -> ClipboardSnapshot {
        throw ClipboardError.platformUnsupported
    }
}
#endif
