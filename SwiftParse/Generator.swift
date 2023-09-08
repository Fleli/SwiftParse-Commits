import Foundation
import SwiftSLR

class Generator {
    
    let lexer = Lexer()
    let parser = LLParser()
    
    struct List: Hashable {
        
        let repeatingItem: RhsItem
        let separator: RhsItem?
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(repeatingItem)
            hasher.combine(separator)
        }
        
    }
    
    private var lists: Set<List> = []
    
    func createParser(from specification: String, at path: String) throws {
        
        let tokens = try produceTokens(from: specification)
        
        let statements = try parser.parse(tokens, self)
        
        var swiftSLRSpecificationFile = "Program -> \(statements.mainItem.swiftSLRToken)\n"
        
        for statement in statements.statements {
            try swiftSLRSpecificationFile.append(statement.asSwiftSLR())
        }
        
        var types = ""
        var converters = ""
        
        for list in lists {
            let nodeName = list.repeatingItem.swiftSLRNodeName
            let separator = (list.separator?.swiftSLRToken ?? "") + " "
            swiftSLRSpecificationFile.append(nodeName + "LIST -> " + nodeName + "LIST " + separator + nodeName + "\n")
            swiftSLRSpecificationFile.append(nodeName + "LIST -> " + nodeName + "\n")
            converters += generateListConverter(nodeName, separator)
        }
        
        // TODO: Generer SLR-parser med SwiftSLR
        
        for statement in statements.statements {
            types += try build_type(for: statement) + "\n"
            converters += try "extension SLRNode {\n\n\(build_conversion(statement))\n}\n\n"
        }
        
        converters += build_convertToTerminal()
        
        writeToFile(content: types, at: path + "/" + "Types.swift")
        writeToFile(content: converters, at: path + "/" + "Converters.swift")
        
        try SwiftSLR.Generator.generate(from: swiftSLRSpecificationFile, includingToken: false, location: path, parseFile: "Parser")
        
    }
    
    
    private func produceTokens(from input: String) throws -> [Token] {
        
        var tokens = try lexer.lex(input)
        
        for index in 0 ..< tokens.count {
            if tokens[index].type == "terminal" { tokens[index].content.removeFirst() }
        }
        
        return tokens
        
    }
    
    private func generateListConverter(_ nodeName: String, _ separator: String) -> String {
        return """
            extension SLRNode {
                
                func convertTo\(nodeName.CamelCased)LIST() -> [\(nodeName.nonColliding)] {
                    
                    if children.count == 1 {
                        return [children[0].convertTo\(nodeName.CamelCased)()]
                    }
                    
                    if children.count == 2 {
                        return children[0].convertTo\(nodeName.CamelCased)LIST() + [children[1].convertTo\(nodeName.CamelCased)()]
                    }
                    
                    if children.count == 3 {
                        return children[0].convertTo\(nodeName.CamelCased)LIST() + [children[2].convertTo\(nodeName.CamelCased)()]
                    }
                    
                    fatalError()
                    
                }
                
            }
            
            """
    }
    
    func insertList(of repeating: RhsItem, with separator: RhsItem?) {
        lists.insert(.init(repeatingItem: repeating, separator: separator))
    }
    
    func writeToFile(content: String, at path: String) {
        
        let fileManager = FileManager()
        let didCreate = fileManager.createFile(atPath: path, contents: content.data(using: .utf8))
        print("didCreate:", didCreate)
        
    }
    
}
