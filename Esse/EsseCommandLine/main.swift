import Foundation
import ArgumentParser
import EsseCore

let storage = Storage.sharedInstance

struct Esse: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Swiss army knife of text transformation.",
        version: "Esse version 2020.5",
        subcommands: [List.self]
    )
    
    @Option(name: .short, help: "Transformation(s) to execute.")
    var transformations: String?
    
    @Option(name: .short, help: "Text to transform.")
    var input: String?
    
    mutating func run() throws {
        var functions: [TextFunction] = []
        transformations?.split(separator: ",").forEach { id in
            guard let f = storage.pAllFunctions.first(where: {$0.id.lowercased().contains(id.lowercased())}) else {return}
            functions.append(f)
        }
        
        if let text = input {
            print(runFunctions(text: text, functions: functions), terminator:"")
            return
        }
        
        let input = FileHandle.standardInput
        if let text = String(bytes: input.availableData, encoding: .utf8) {
            print(runFunctions(text: text, functions: functions), terminator:"")
            return
        }
    }
    
    func runFunctions(text: String, functions: [TextFunction]) -> String{
        let actions = functions.compactMap {$0.actions}.flatMap {$0}
        return actions.reduce(text) {$1($0)}
    }
}

extension Esse {
    struct List: ParsableCommand, Decodable {
        static var configuration =
        CommandConfiguration(abstract: "Print list of available transformations.")
        
        @Flag(help: "Print only id.")
        var onlyid: Int
        
        @Flag(help: "Alfred compatible output.")
        var alfred: Int
        
        @Argument(help: "Transfromation.")
        var transformation: String?
        
        
        mutating func run() {
            storage.reloadExternalFunctions()
            var functions = storage.pAllFunctions
            if let transformation = transformation {
                functions = storage.pAllFunctions.filter({$0.id.lowercased().contains(transformation.lowercased())})
            }
            
            if functions.isEmpty {
                print("No functions found.")
                return
            }
            
            if onlyid != 0{
                functions.forEach{print($0.id)}
                return
            }
            
            if alfred != 0 {
                let alfredItems = functions.map{$0.alfred}
                let alfredOutput = TextFunction.AlfredOutput(items: alfredItems)
                
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                guard let jsonData = try? encoder.encode(alfredOutput), let str = String(data: jsonData, encoding: .utf8) else {return}
                print(str)
                return
            }
            functions.forEach{print($0.description)}
        }
    }
}

extension TextFunction {
    struct AlfredOutput: Codable {
        let items: [AlfredItem]
    }
    struct AlfredItem: Codable {
        let uid: String
        let title: String
        let subtitle: String
        var match: String
        var arg: String
        var autocomplete: String
    }
    var alfred: AlfredItem {
        return AlfredItem(uid: id, title: title, subtitle: desc, match: "\(title) \(desc)", arg: id, autocomplete: title)
    }
}
Esse.main()
