extension Generator {
    
    private var t1: String { "\t" }
    private var t2: String { t1 + t1 }
    
    private var l0: String { "\n" + t2 }
    private var l1: String { l0 + l0 }
    
    private var signatureSuffix: String { " {\n\t\t\n" }
    
    func build_conversion(_ statement: Statement) throws -> String {
        
        let lhs = statement.lhs
        let type = statement.rhs
        
        switch type {
        case .enum(let cases):
            return try build_conversion(lhs, cases)
        case .nested(let cases):
            return try build_conversion(lhs, cases)
        case .precedence(let groups):
            return try build_conversion(lhs, groups)
        case .class(let elements, let allProductions):
            return try build_conversion(lhs, elements, allProductions)
        }
        
    }
    
    private func signature(for type: String) -> String {
        return "func convertTo\(type.CamelCased)() -> \(type.nonColliding)" + signatureSuffix
    }
    
    private func typeIs(_ expected: String) -> String {
        return "if type == \"" + expected + "\""
    }
    
    private func child(_ index: Int, is type: String) -> String {
        return " && children[" + String(index) + "].type == \"" + type + "\""
    }
    
    private func childCountIs(_ count: Int) -> String {
        return " && children.count == \(count)"
    }
    
    // If: "enum A { case p; case q; ... }", this function converts from the SLRNode with type 'A'. So this might return 'A.p'.
    private func build_conversion(_ lhs: String, _ cases: [RhsItem]) throws -> String {
        
        print("rhsItems:", cases)
        
        var string = """
            \(signature(for: lhs)) {
                
        
        """
        
        for enumCase in cases {
            switch enumCase {
            case .terminal(let type):
                string += """
                        if type == "\(lhs)" && children[0].type == "\(type)" {
                            return \(lhs).\(type.camelCased.nonColliding)
                        }
                        
                
                """
            case .nonTerminal(let name):
                string += """
                        if type == "\(lhs)" && children[0].type == "\(name)" {
                            let nonTerminalNode = children[0].convertTo\(name.nonColliding)()
                            return \(lhs.nonColliding).\(name.camelCased.nonColliding)(nonTerminalNode)
                        }
                        
                
                """
            }
        }
        
        string += """
                fatalError()
            
            }
        
        """
        
        return string
        
    }
    
    // SLRNodes med type T hvor nested T er definert. Dvs returner en enum-case i enum-en T
    private func build_conversion(_ lhs: String, _ cases: [NestItem]) throws -> String {
        
        print("nestItems:", cases)
        
        var string = "\t" + signature(for: lhs)
        
        for nestCase in cases {
            
            let caseName = nestCase.caseName
            let production = nestCase.production
            
            var ifStatement = t2 + typeIs(lhs) + childCountIs(production.count)
            
            var declarations: [String] = []         // Hele declaration (Swift-statement)
            var associatedValues: [String] = []     // Det som brukes for å konstruere enum-casen (argument)
            
            for (index, rhsComponent) in production.enumerated() {
                switch rhsComponent {
                case .item(let rhsItem):
                    switch rhsItem {
                    case .terminal(let type):
                        ifStatement += child(index, is: type)
                    case .nonTerminal(let name):
                        ifStatement += child(index, is: name)
                    }
                case .list(let repeating, _):
                    ifStatement += child(index, is: repeating.swiftSLRToken + "LIST")
                }
            }
            
            string += ifStatement + "\n"
            
        }
        
        return string
        
    }
    
    private func build_conversion(_ lhs: String, _ groups: [PrecedenceGroup]) throws -> String {
        
        return ""
        
    }
    
    private func build_conversion(_ lhs: String, _ elements: [ClassElement], _ allProductions: [[ClassItem]]) throws -> String {
        
        return ""
        
    }
    
    
}
