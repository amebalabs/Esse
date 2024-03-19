import Foundation

public class Sideload {
    public static let sharedInstance = Sideload()

    var containerUrl: URL? {
        if let str = UserDefaults.standard.string(forKey: "PluginDirectory"),
           case let url = URL(fileURLWithPath: str)
        {
            return url
        }
        return FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
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
        if out.isEmpty {
            let str = "very hidden file"
            let filename = url.appendingPathComponent(".esse")
            try? str.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
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
