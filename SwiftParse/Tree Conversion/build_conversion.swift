extension Generator {
    
    
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
    
    // If: "enum A { case p; case q; ... }", this function converts from the SLRNode with type 'A'. So this might return 'A.p'.
    private func build_conversion(_ lhs: String, _ cases: [RhsItem]) throws -> String {
        
        var string = """
            func convertTo\(lhs)() -> \(lhs) {
                
        
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
                            let nonTerminalNode = children[0].convertTo\(name)()
                            return \(lhs).\(name.camelCased.nonColliding)(nonTerminalNode)
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
    
    private func build_conversion(_ lhs: String, _ cases: [NestItem]) throws -> String {
        
        return ""
        
    }
    
    private func build_conversion(_ lhs: String, _ groups: [PrecedenceGroup]) throws -> String {
        
        return ""
        
    }
    
    private func build_conversion(_ lhs: String, _ elements: [ClassElement], _ allProductions: [[ClassItem]]) throws -> String {
        
        return ""
        
    }
    
    
}
