extension Generator {
    
    func build_enum(_ lhs: String, _ cases: [RhsItem]) throws -> String {
        
        var string = "enum \(lhs.nonColliding) {" + l0
        
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
    
}
