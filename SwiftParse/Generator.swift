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
    
    init() {
        
        print("init", self)
        
    }
    
    
    func createParser(from specification: String, named name: String, at path: String) throws {
        
        let tokens = try produceTokens(from: specification)
        
        let statements = try parser.parse(tokens, self)
        
        var swiftSLRSpecificationFile = ""
        
        for statement in statements {
            try swiftSLRSpecificationFile.append(statement.asSwiftSLR())
        }
        
        for list in lists {
            let nodeName = list.repeatingItem.swiftSLRNodeName
            let separator = (list.separator?.swiftSLRToken ?? "") + " "
            swiftSLRSpecificationFile.append(nodeName + "LIST -> " + nodeName + "LIST " + separator + nodeName + "\n")
            swiftSLRSpecificationFile.append(nodeName + "LIST -> " + nodeName + "\n")
            print("""
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
            
            """)
        }
        
        // TODO: Generer SLR-parser med SwiftSLR
        // TODO: Finn alle liste-definisjoner og lag konverteringsfunksjoner for dem også.
        
        print("\nSwiftSLR Specification\n--(begin)\n\(swiftSLRSpecificationFile)--(end)\n")
        
        for statement in statements {
            let typeString = try build_type(for: statement)
            let converter = try build_conversion(statement)
            print(typeString)
            print("extension SLRNode {\n\n\(converter)\n}")
        }
        
        print(build_convertToTerminal())
        
        print("\nLISTS:", lists)
        
    }
    
    
    private func produceTokens(from input: String) throws -> [Token] {
        
        var tokens = try lexer.lex(input)
        
        for index in 0 ..< tokens.count {
            if tokens[index].type == "terminal" { tokens[index].content.removeFirst() }
        }
        
        return tokens
        
    }
    
    
    func insertList(of repeating: RhsItem, with separator: RhsItem?) {
        lists.insert(.init(repeatingItem: repeating, separator: separator))
    }
    
    
}
