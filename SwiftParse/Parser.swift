class LLParser {
    
    private var index = 0
    private var tokens: [Token] = []
    private var statements: [Statement] = []
    
    private var notExhausted: Bool { index < tokens.count }
    
    func parse(_ tokens: [Token]) -> [Statement] {
        
        self.index = 0
        self.tokens = tokens
        self.statements = []
        
        while notExhausted {
            
            let current = tokens[index]
            
            switch current.type {
            case "enum":
                break
            default:
                break
            }
            
        }
        
        return []
        
    }
    
    
    private func parseEnum() {
        
        
        
    }
    
    
}
