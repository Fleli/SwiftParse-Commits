extension Generator {
    
    // Midlertidige typealiases frem til SwiftSLR importeres.
    typealias Production = (lhs: String, rhs: [Symbol])
    
    enum Symbol {
        
        case terminal(String)
        case nonTerminal(String)
        
        var slrNodeType: String {
            switch self {
            case .terminal(let type):       return type
            case .nonTerminal(let type):    return type
            }
        }
        
    }
    
    func build_ifStatement(_ production: Production) -> String {
        
        var ifStatement = "if type == \(production.lhs) && children.count == \(production.rhs.count)"
        
        for (index, symbol) in production.rhs.enumerated() {
            let childCheck = " && children[\(index)].type == \(symbol.slrNodeType)"
            ifStatement.append(childCheck)
        }
        
        ifStatement.append(" {\n")
        
        return ifStatement
        
    }
    
    
}
