class Generator {
    
    let lexer = Lexer()
    let parser = LLParser()
    
    init() {
        
        print("init", self)
        
    }
    
    
    func createParser(from specification: String, named name: String, at path: String) throws {
        
        let tokens = try produceTokens(from: specification)
        
        let statements = try parser.parse(tokens)
        
        for statement in statements {
            try statement.printString()
        }
        
        for statement in statements {
            let typeString = try build_type(for: statement)
            let converter = try build_conversion(statement)
            print(typeString)
            print(converter)
        }
        
    }
    
    
    private func produceTokens(from input: String) throws -> [Token] {
        
        var tokens = try lexer.lex(input)
        
        for index in 0 ..< tokens.count {
            if tokens[index].type == "terminal" { tokens[index].content.removeFirst() }
        }
        
        return tokens
        
    }
    
    
}
