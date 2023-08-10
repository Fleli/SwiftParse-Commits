extension Generator {
    
    private var l0: String { "\n\t" }
    private var l1: String { l0 + l0 }
    
    func build_type(for statement: Statement) throws -> String {
        
        let lhs = statement.lhs
        let type = statement.rhs
        
        switch type {
        case .enum(let cases):
            return try build_enum(lhs, cases)
        case .nested(let cases):
            return try build_nested(lhs, cases)
        case .precedence(let groups):
            return try build_precedence(lhs, groups)
        case .class(let elements, let allProductions):
            return try build_class(lhs, elements, allProductions)
        }
        
    }
    
    func build_enum(_ lhs: String, _ cases: [RhsItem]) throws -> String {
        
        var string = "enum \(lhs) {" + l0
        
        for enumCase in cases {
            
            let caseName: String
            let suffix: String
            
            switch enumCase {
            case .terminal(let type):
                caseName = type
                suffix = ""
            case .nonTerminal(let name):
                caseName = name
                suffix = "(" + name.CamelCased.nonColliding + ")"
            }
            
            string += "case " + caseName.camelCased.nonColliding + suffix + l0
            
        }
        
        string = string.dropLast() + "}\n"
        
        return string
        
    }
    
    func build_nested(_ lhs: String, _ cases: [NestItem]) throws -> String {
        
        return ""
        
    }
    
    func build_precedence(_ lhs: String, _ groups: [PrecedenceGroup]) throws -> String {
        
        return ""
        
    }
    
    func build_class(_ lhs: String, _ elements: [ClassElement], _ allProductions: [[ClassItem]]) throws -> String {
        
        return ""
        
    }
    
    
}
