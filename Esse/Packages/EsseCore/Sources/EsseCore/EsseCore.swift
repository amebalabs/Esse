import JavaScriptCore

public typealias TextFunctionAction = (String) -> String

public enum FunctionCategory: String, Codable, CaseIterable {
    case Custom
    case Cleaning
    case Convert
    case Case
    case ASCII
    case Extract
    case QuotationMarks = "Quotation Marks"
    case Other
    case Developer
}

public struct TextFunction {
    public enum FunctionType {
        case Standard
        case Custom
        case External
    }

    public let id: String
    public let type: FunctionType
    public let author: String
    public let title: String
    public let desc: String
    public let category: FunctionCategory
    public var actions: [TextFunctionAction] = []
    public var externalFunction: String = ""
    public var externalFileURL: URL?
    public var functionIDs: [Int] = []
    public var searchableText: String {
        (title + desc).lowercased()
    }

    init(id: String, title: String, description: String, category: FunctionCategory = .Other, action: @escaping TextFunctionAction) {
        self.id = id
        type = .Standard
        self.title = title
        desc = description
        author = "Ameba Labs"
        self.category = category
        actions.append(action)
    }

    init(id: String, title: String, description: String, category: FunctionCategory = .Custom, actions: [TextFunctionAction]) {
        self.id = id
        type = .Custom
        self.title = title
        desc = description
        author = "Ameba Labs"
        self.category = category
        self.actions = actions
    }

    init(id: String, title: String, description: String, category: String, author: String, function: String, fileURL: URL) {
        self.id = id
        type = .External
        self.title = title
        desc = description
        self.author = author
        externalFileURL = fileURL
        externalFunction = function
        self.category = FunctionCategory(rawValue: category) ?? .Custom
        actions = [
            { text -> String in
                guard function != "" else { return text }
                let context = JSContext()
                context?.evaluateScript(function)
                context?.exceptionHandler = { _, exception in
                    print(exception?.toString() ?? "")
                }
                let main = context?.objectForKeyedSubscript("main")
                return main?.call(withArguments: [text])?.toString() ?? ""
            },
        ]
    }

    public func run(_ input: String) -> String {
        actions.reduce(input) { $1($0) }
    }

    public var description: String {
        var out = "id: \(id) \n"
        out = out + "title: \(title) \n"
        out = out + "description: \(desc) \n"
        out = out + "category: \(category) \n"
        return out
    }

    public var externalMemo: String {
        var out = "Id: \(id) \n"
        out = out + "Author: \(author) \n"
        out = out + "File: \(externalFileURL?.lastPathComponent ?? "") \n"
        return out
    }
}

extension TextFunction: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: TextFunction, rhs: TextFunction) -> Bool {
        lhs.id == rhs.id
    }
}

public struct TextFunctionStorable: Codable {
    let id: String
    let title: String
    let description: String
    let category: FunctionCategory
    var functionIDs: [String] = []

    init(id: String, title: String, description: String, functionIDs: [String]) {
        self.id = id
        self.title = title
        self.description = description
        category = .Custom
        self.functionIDs = functionIDs
    }
}

public extension [TextFunction] {
    func run(value: String) -> String {
        let actions = compactMap{$0.actions}.flatMap { $0 }
        return actions.reduce(value) { $1($0) }
    }
}
