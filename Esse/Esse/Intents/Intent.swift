import AppIntents
import EsseCore
import Foundation

struct EsseFunctionEntity: AppEntity, Identifiable {
    let id: String
    let name: String
    let desc: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Function"
    static var defaultQuery = FunctionQuery()
}

struct FunctionQuery: EntityQuery {
    func entities(for identifiers: [EsseFunctionEntity.ID]) async throws -> [EsseFunctionEntity] {
        let filtered = Storage.sharedInstance.pAllFunctions.filter { identifiers.contains($0.id) }
        return filtered.map { EsseFunctionEntity(id: $0.id, name: $0.title, desc: $0.desc) }
    }

    func entities(matching string: String) async throws -> [EsseFunctionEntity] {
        let filtered = Storage.sharedInstance.pAllFunctions.filter { $0.searchableText.score(word: string) > 0.4 }.sorted { $0.searchableText.score(word: string) > $1.searchableText.score(word: string) }
        return filtered.map { EsseFunctionEntity(id: $0.id, name: $0.title, desc: $0.desc) }
    }

    func suggestedEntities() async throws -> [EsseFunctionEntity] {
        Storage.sharedInstance.pAllFunctions.map { EsseFunctionEntity(id: $0.id, name: $0.title, desc: $0.desc) }
    }
}

struct RunEsseFunction: AppIntent {
    static var title: LocalizedStringResource = "Run Esse Function"
    static var description = IntentDescription("Applies Esse function on provided input")

    @Parameter(title: "Function")
    var function: EsseFunctionEntity

    @Parameter(title: "Input")
    var input: String

    static var parameterSummary: some ParameterSummary {
        Summary("Transform \(\.$input) with \(\.$function)")
    }

    func perform() async throws -> some IntentResult & ReturnsValue {
        guard let f = Storage.sharedInstance.pAllFunctions.first(where: { $0.id == function.id }) else {
            return .result(value: "")
        }

        return .result(value: f.run(input))
    }
}
