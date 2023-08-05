class LLParser {
    
    private var index = 0
    private var tokens: [Token] = []
    private var statements: [Statement] = []
    
    private var notExhausted: Bool { index < tokens.count }
    
    func parse(_ tokens: [Token]) throws -> [Statement] {
        
        self.index = 0
        self.tokens = tokens
        self.statements = []
        
        while notExhausted {
            
            let current = tokens[index]
            
            switch current.type {
            case "enum":
                try parseEnum()
            default:
                break
            }
            
        }
        
        return statements
        
    }
    
    
    private func parseEnum() throws {
        
        index += 1
        
        var enumCases: [RhsItem] = []
        
        try assertNextIsAmong("nonTerminal")
        
        let name = tokens[index].content
        
        index += 1
        
        try assertNextIsAmong("{")
        
        index += 1
        
        while notExhausted  &&  tokens[index].type == "case" {
            
            index += 1
            
            try assertNextIsAmong("terminal", "nonTerminal")
            
            let nextToken = tokens[index]
            let rhsItem = RhsItem(from: nextToken)
            enumCases.append(rhsItem)
            
            index += 1
            
        }
        
        try assertNextIsAmong("}")
        
        index += 1
        
        let newStatement = Statement(lhs: name, rhs: .enum(cases: enumCases))
        statements.append(newStatement)
        
    }
    
    
    private func assertNextIsAmong(_ types: String ...) throws {
        
        guard notExhausted else {
            throw ParseError.exhausted(expected: types.description)
        }
        
        let next = tokens[index]
        
        guard types.contains(next.type) else {
            throw ParseError.unexpected(found: next.type, expected: types.description)
        }
        
    }
    
    
}

enum ParseError: Error {
    
    case exhausted(expected: String)
    case unexpected(found: String, expected: String)
    
}
