class Generator {
    
    let lexer = Lexer()
    let parser = LLParser()
    
    init() {
        
        print("init", self)
        
    }
    
    
    func createParser(from specification: String, named name: String, at path: String) throws {
        
        
        
        let tokens = try lexer.lex(specification)
        
        tokens.forEach {
            print($0)
        }
        
        let statements = parser.parse(tokens)
        
        
    }
    
    
    
    
    
}
