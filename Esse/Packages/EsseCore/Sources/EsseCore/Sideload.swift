import Foundation

public class Sideload {
    public static let sharedInstance = Sideload()

    public var containerUrl: URL? {
        guard let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "X93LWC49WV.com.ameba.esse") else {
            print("Failed to get shared container URL")
            return nil
        }
        
        let appSupportDirectory = sharedContainerURL.appendingPathComponent("Library/Application Support/Scripts")
        
        if !FileManager.default.fileExists(atPath: appSupportDirectory.path) {
            do {
                try FileManager.default.createDirectory(at: appSupportDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Failed to create Application Support directory: \(error.localizedDescription)")
                return nil
            }
        }

        return appSupportDirectory
    }
    
    func getDocumentsDirectory() -> URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    func loadFunctions() -> [TextFunction] {
        guard let url = containerUrl else { return [] }

        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Sideload \(error)")
            }
        }
        var out: [TextFunction] = []

        let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil)
        while let element = enumerator?.nextObject() as? URL {
            guard element.absoluteString.hasSuffix("js") else { continue }
            if let function = loadScript(url: element) {
                guard !out.contains(where: { $0.id == function.id }) else { continue } // filter duplicate IDs
                out.append(function)
            }
        }
        return out
    }

    private func loadScript(url: URL) -> TextFunction? {
        do {
            let script = try String(contentsOf: url)
            guard
                let openComment = script.range(of: "/**"),
                let closeComment = script.range(of: "**/")
            else {
                throw NSError()
            }

            let meta = script[openComment.upperBound ..< closeComment.lowerBound]
            let json = try JSONSerialization.jsonObject(with: meta.data(using: .utf8)!, options: .allowFragments) as! [String: Any]
            let function = TextFunction(id: json["id"] as? String ?? UUID().uuidString,
                                        title: json["name"] as? String ?? "Unknown External Function",
                                        description: json["description"] as? String ?? "",
                                        category: json["category"] as? String ?? "Custom",
                                        author: json["author"] as? String ?? "Unknown",
                                        function: script, fileURL: url)
            return function
        } catch {
            print("Unable to load ", url.absoluteString)
            return nil
        }
    }
}
