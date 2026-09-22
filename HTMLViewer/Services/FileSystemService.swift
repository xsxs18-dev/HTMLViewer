import Foundation

enum FileSystemError: LocalizedError {
    case alreadyExists
    case invalidName
    case underlying(Error)

    var errorDescription: String? {
        switch self {
        case .alreadyExists:
            return String(localized: "An item with this name already exists.")
        case .invalidName:
            return String(localized: "Invalid name.")
        case .underlying(let error):
            return error.localizedDescription
        }
    }
}

final class FileSystemService {
    static let shared = FileSystemService()

    private let fileManager = FileManager.default

    var rootURL: URL {
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documents.appendingPathComponent("Pages", isDirectory: true)
        if !fileManager.fileExists(atPath: url.path) {
            try? fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        }
        return url
    }

    func contents(of directory: URL) throws -> [PageItem] {
        let urls = try fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.isDirectoryKey, .fileSizeKey, .contentModificationDateKey],
            options: [.skipsHiddenFiles]
        )
        let items = urls.map { PageItem(url: $0) }
        return items.sorted { lhs, rhs in
            if lhs.isDirectory != rhs.isDirectory {
                return lhs.isDirectory && !rhs.isDirectory
            }
            return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
        }
    }

    @discardableResult
    func createFolder(named name: String, in directory: URL) throws -> URL {
        let sanitized = sanitize(name)
        guard !sanitized.isEmpty else { throw FileSystemError.invalidName }
        let url = directory.appendingPathComponent(sanitized, isDirectory: true)
        guard !fileManager.fileExists(atPath: url.path) else { throw FileSystemError.alreadyExists }
        do {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: false)
            return url
        } catch {
            throw FileSystemError.underlying(error)
        }
    }

    @discardableResult
    func createFile(named name: String, in directory: URL, contents: Data = Data()) throws -> URL {
        let sanitized = sanitize(name)
        guard !sanitized.isEmpty else { throw FileSystemError.invalidName }
        let url = directory.appendingPathComponent(sanitized, isDirectory: false)
        guard !fileManager.fileExists(atPath: url.path) else { throw FileSystemError.alreadyExists }
        guard fileManager.createFile(atPath: url.path, contents: contents) else {
            throw FileSystemError.underlying(NSError(domain: "FileSystemService", code: -1))
        }
        return url
    }

    @discardableResult
    func rename(_ item: PageItem, to newName: String) throws -> URL {
        let sanitized = sanitize(newName)
        guard !sanitized.isEmpty else { throw FileSystemError.invalidName }
        let destination = item.url.deletingLastPathComponent().appendingPathComponent(sanitized, isDirectory: item.isDirectory)
        guard !fileManager.fileExists(atPath: destination.path) else { throw FileSystemError.alreadyExists }
        do {
            try fileManager.moveItem(at: item.url, to: destination)
            return destination
        } catch {
            throw FileSystemError.underlying(error)
        }
    }

    func delete(_ item: PageItem) throws {
        do {
            try fileManager.removeItem(at: item.url)
        } catch {
            throw FileSystemError.underlying(error)
        }
    }

    func uniqueName(for suggestedName: String, in directory: URL) -> String {
        let base = (suggestedName as NSString).deletingPathExtension
        let ext = (suggestedName as NSString).pathExtension
        var candidate = suggestedName
        var counter = 1
        while fileManager.fileExists(atPath: directory.appendingPathComponent(candidate).path) {
            counter += 1
            candidate = ext.isEmpty ? "\(base) \(counter)" : "\(base) \(counter).\(ext)"
        }
        return candidate
    }

    private func sanitize(_ name: String) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let forbidden = CharacterSet(charactersIn: "/\\:")
        return trimmed.components(separatedBy: forbidden).joined()
    }
}
