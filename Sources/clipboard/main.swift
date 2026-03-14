import Foundation
import ClipboardCore

#if canImport(AppKit)
do {
    let tool = try ClipboardTool.makeDefault()
    let result = try tool.run()
    print("File Path: \(result.outputURL.path)")
    print("File Type: PNG")
    print("Content Count: \(result.byteCount)")
    exit(EXIT_SUCCESS)
} catch RuntimeExit.success {
    exit(EXIT_SUCCESS)
} catch let error as ClipboardError {
    fputs((error.errorDescription ?? String(describing: error)) + "\n", stderr)
    exit(EXIT_FAILURE)
} catch {
    fputs("Unexpected error: \(error)\n", stderr)
    exit(EXIT_FAILURE)
}
#else
fputs("This tool requires macOS 10.13 or later with AppKit.\n", stderr)
exit(EXIT_FAILURE)
#endif
