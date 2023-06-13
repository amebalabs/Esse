import Foundation
import Observation
#if !os(macOS)
    import UIKit
#endif

public class Storage {
    public static let sharedInstance = Storage()

    private var sideload = Sideload.sharedInstance
    public let userDefaults = UserDefaults(suiteName: "group.ameba.co.essy")!
    private let savedFunctions = "savedFunctions"
    private let savedCustomFunctions = "savedCustomFunctions"
    private let savedScratchpadFunctions = "savedScratchpadFunctions"
    private let actionExtensionFunctions = "actionExtensionFunctions"
    private let todayWidgetFunctions = "todayWidgetFunctions"
    private var savedCustomFunctionsFile: URL? {
        sideload.containerUrl?.appendingPathComponent(".customFunctions.esse")
    }

    private var functionIDs: [String] {
        didSet {
            userDefaults.set(functionIDs, forKey: savedFunctions)
            userDefaults.synchronize()
        }
    }

    private var customFunctionIDS: [String] = [] {
        didSet {
            userDefaults.setValue(customFunctionIDS, forKey: savedScratchpadFunctions)
            userDefaults.synchronize()
        }
    }

    private var customFunctions: [TextFunction] = []
    private var customFunctionsStorable: [TextFunctionStorable] = [] {
        didSet {
            if let data = try? JSONEncoder().encode(customFunctionsStorable) {
                userDefaults.setValue(data, forKey: savedCustomFunctions)
                userDefaults.synchronize()
                if let file = savedCustomFunctionsFile {
                    try? data.write(to: file)
                }
            }
        }
    }

    private var externalFunctions: [TextFunction] = []

    private var actionExtensionFunctionsIDS: [String] = [] {
        didSet {
            userDefaults.setValue(actionExtensionFunctionsIDS, forKey: actionExtensionFunctions)
            userDefaults.synchronize()
        }
    }

    private var todayWidgetFunctionsIDS: [String] = [] {
        didSet {
            userDefaults.setValue(todayWidgetFunctionsIDS, forKey: todayWidgetFunctions)
            userDefaults.synchronize()
        }
    }

    #if !os(macOS)
        public var fontDescriptor: UIFontDescriptor {
            didSet {
                let archive = try? NSKeyedArchiver.archivedData(withRootObject: fontDescriptor, requiringSecureCoding: true)
                userDefaults.setValue(archive, forKey: "fontDescriptor")
                userDefaults.synchronize()
            }
        }
    #endif
    public var fontSize: Double {
        didSet {
            userDefaults.setValue(fontSize, forKey: "fontSize")
            userDefaults.synchronize()
        }
    }

    public var pFunctionIDs: [String] {
        functionIDs
    }

    public var pCustomFunctionIDs: [String] {
        customFunctionIDS
    }

    public var pActionFunctionIDs: [String] {
        actionExtensionFunctionsIDS
    }

    public var pTodayWidgetFunctionsIDS: [String] {
        todayWidgetFunctionsIDS
    }

    public var pExternalFunctions: [TextFunction] {
        externalFunctions
    }

    public var pAllFunctions: [TextFunction] {
        AllFunctions + customFunctions + externalFunctions
    }

    public init() {
        if let savedFunctions = userDefaults.array(forKey: savedFunctions) as? [String] {
            functionIDs = savedFunctions
        } else {
            functionIDs = [
                "co.ameba.Esse.CaseFunctions.lowerCase",
                "co.ameba.Esse.CaseFunctions.capitaliseWords",
                "co.ameba.Esse.CleaningFunctions.removeEmptyLines",
                "co.ameba.Esse.CleaningFunctions.removeDuplicateLines",
            ]
        }

        if let customFunctionsIDs = userDefaults.array(forKey: savedScratchpadFunctions) as? [String] {
            customFunctionIDS = customFunctionsIDs
        } else {
            customFunctionIDS = [
                "co.ameba.Esse.CaseFunctions.upperCase",
                "co.ameba.Esse.CaseFunctions.kebabCase",
            ]
        }

        #if !os(macOS)
            if let archive = userDefaults.object(forKey: "fontDescriptor") as? Data, let fontDescr = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIFontDescriptor.self, from: archive) {
                fontDescriptor = fontDescr
            } else {
                fontDescriptor = UIFont.systemFont(ofSize: UIFont.systemFontSize).fontDescriptor
            }
        #endif

        fontSize = userDefaults.double(forKey: "fontSize")
        if fontSize == 0 {
            fontSize = 14
        }

        if let file = savedCustomFunctionsFile, FileManager.default.fileExists(atPath: file.path), let data = try? Data(contentsOf: file) {
            let decoder = JSONDecoder()
            if let savedFunctions = try? decoder.decode([TextFunctionStorable].self, from: data), !savedFunctions.isEmpty {
                customFunctionsStorable = savedFunctions
            }
        } else if let data = userDefaults.object(forKey: savedCustomFunctions) as? Data {
            let decoder = JSONDecoder()
            if let savedFunctions = try? decoder.decode([TextFunctionStorable].self, from: data) {
                customFunctionsStorable = savedFunctions
            }
        }

        customFunctionsStorable.forEach { f in
            let functions = f.functionIDs.compactMap { id in
                pAllFunctions.first { $0.id == id }?.actions
            }.flatMap { $0 }
            let tf = TextFunction(id: f.id, title: f.title, description: f.description, actions: functions)
            customFunctions.append(tf)
        }

        if let savedFunctions = userDefaults.array(forKey: actionExtensionFunctions) as? [String] {
            actionExtensionFunctionsIDS = savedFunctions
        } else {
            actionExtensionFunctionsIDS = [
                "co.ameba.Esse.OtherFunctions.upsideDown",
                "co.ameba.Esse.OtherFunctions.circleLetters",
            ]
        }

        if let savedFunctions = userDefaults.array(forKey: todayWidgetFunctions) as? [String] {
            todayWidgetFunctionsIDS = savedFunctions
        } else {
            todayWidgetFunctionsIDS = [
                "co.ameba.Esse.CaseFunctions.upperCase",
                "co.ameba.Esse.OtherFunctions.rot13",
            ]
        }

        externalFunctions = sideload.loadFunctions()
    }

    public func reloadExternalFunctions() {
        externalFunctions = sideload.loadFunctions()
    }
}

// MARK: Functions

public extension Storage {
    func add(_ functionId: String) {
        guard !functionIDs.contains(functionId) else { return }
        functionIDs.append(functionId)
    }

    func insert(_ functionId: String, at index: Int) -> Int? {
        let idx = remove(functionId)
        functionIDs.insert(functionId, at: index)
        return idx
    }

    func remove(_ functionId: String) -> Int? {
        if let idx = functionIDs.firstIndex(of: functionId) {
            functionIDs.remove(at: idx)
            return idx
        }
        return nil
    }

    func replace(_ functionsIDs: [String]) {
        functionIDs = functionsIDs
    }
}

// MARK: Custom Functions

public extension Storage {
    func CFadd(_ functionId: String) {
        customFunctionIDS.append(functionId)
    }

    func CFSet(_ functionsIDs: [String]) {
        customFunctionIDS = functionsIDs
    }

    func CFInsert(_ functionId: String, at index: Int) {
        customFunctionIDS.insert(functionId, at: index)
    }

    func CFReset() {
        customFunctionIDS = []
    }

    func CFRemove(_ functionId: String) {
        if let idx = customFunctionIDS.firstIndex(of: functionId) {
            customFunctionIDS.remove(at: idx)
        }
    }

    func CFRemove(index: Int) {
        if customFunctionIDS.count >= (index + 1) {
            customFunctionIDS.remove(at: index)
        }
    }

    func CFSaveNewFuntion(title: String) {
        guard customFunctionIDS.count > 0 else { return }

        let id = UUID().uuidString
        let description = customFunctionIDS.compactMap { id in
            pAllFunctions.first { $0.id == id }
        }.compactMap(\.title).joined(separator: " ➔ ")

        let functionIDs = customFunctionIDS.compactMap { id in
            pAllFunctions.first { $0.id == id }
        }.compactMap(\.id)
        let storableFunction = TextFunctionStorable(id: id, title: title, description: description, functionIDs: functionIDs)
        customFunctionsStorable.append(storableFunction)

        let textFunctionActions = customFunctionIDS.compactMap { id in
            pAllFunctions.first { $0.id == id }?.actions
        }.flatMap { $0 }
        let tf = TextFunction(id: id, title: title, description: description, actions: textFunctionActions)
        customFunctions.append(tf)
    }

    func CFDeleteSavedFunction(id: String) {
        if let idx = customFunctions.firstIndex(where: { $0.id == id }) {
            customFunctions.remove(at: idx)
        }

        if let idx = customFunctionsStorable.firstIndex(where: { $0.id == id }) {
            customFunctionsStorable.remove(at: idx)
        }

        if let idx = functionIDs.firstIndex(where: { $0 == id }) {
            functionIDs.remove(at: idx)
        }

        if let idx = actionExtensionFunctionsIDS.firstIndex(where: { $0 == id }) {
            actionExtensionFunctionsIDS.remove(at: idx)
        }

        if let idx = todayWidgetFunctionsIDS.firstIndex(where: { $0 == id }) {
            todayWidgetFunctionsIDS.remove(at: idx)
        }
    }
}

// MARK: Share Sheet Functions

public extension Storage {
    func AEAdd(_ functionId: String) {
        guard !actionExtensionFunctionsIDS.contains(functionId) else { return }
        actionExtensionFunctionsIDS.append(functionId)
    }

    func AERemove(_ functionId: String) {
        if let idx = actionExtensionFunctionsIDS.firstIndex(of: functionId) {
            actionExtensionFunctionsIDS.remove(at: idx)
        }
    }

    func AEInsert(_ functionId: String, at index: Int) {
        actionExtensionFunctionsIDS.insert(functionId, at: index)
    }

    func AEReplace(_ functionsIDs: [String]) {
        actionExtensionFunctionsIDS = functionsIDs
    }
}

// MARK: Today Widget Functions

public extension Storage {
    func TWAdd(_ functionId: String) {
        guard !todayWidgetFunctionsIDS.contains(functionId) else { return }
        todayWidgetFunctionsIDS.append(functionId)
    }

    func TWRemove(_ functionId: String) {
        if let idx = todayWidgetFunctionsIDS.firstIndex(of: functionId) {
            todayWidgetFunctionsIDS.remove(at: idx)
        }
    }

    func TWInsert(_ functionId: String, at index: Int) {
        todayWidgetFunctionsIDS.insert(functionId, at: index)
    }

    func TWReplace(_ functionsIDs: [String]) {
        todayWidgetFunctionsIDS = functionsIDs
    }
}
