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
    
    
    private func build_conversion(_ lhs: String, _ cases: [RhsItem]) throws -> String {
        
        var converted = "\nenum \(lhs) {\n"
        
        for enumCase in cases {
            converted += "\tcase `\(enumCase.swiftSLRToken)`\n"
        }
        
        converted += "}\n"
        
        return converted
        
    }
    
    private func build_conversion(_ lhs: String, _ cases: [NestItem]) throws -> String {
        
        
        
    }
    
    private func build_conversion(_ lhs: String, _ groups: [PrecedenceGroup]) throws -> String {
        
        
        
    }
    
    private func build_conversion(_ lhs: String, _ elements: [ClassElement], _ allProductions: [[ClassItem]]) throws -> String {
        
        
        
    }
    
    
}
