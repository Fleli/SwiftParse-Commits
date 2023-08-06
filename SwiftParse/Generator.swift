class Generator {
    
    let lexer = Lexer()
    let parser = LLParser()
    
    init() {
        
        print("init", self)
        
    }
    
    
    func createParser(from specification: String, named name: String, at path: String) throws {
        
        
        
        var tokens = try lexer.lex(specification)
        
        for index in 0 ..< tokens.count {
            
            if tokens[index].type == "terminal" {
                tokens[index].content.removeFirst()
            }
            
        }
        
        let statements = try parser.parse(tokens)
        
        statements.forEach {
            print($0)
        }
        
        print("\n")
        
        for statement in statements {
            try statement.printString()
        }
        
    }
    
    
    
    
    
}
