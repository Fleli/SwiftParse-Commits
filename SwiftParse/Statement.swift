
struct Statement: CustomStringConvertible {
    
    let lhs: String
    let rhs: StatementType
    
    var description: String { lhs + ": " + rhs.description }
    
}

enum StatementType: CustomStringConvertible {
    
    case `enum`(cases: [RhsItem])
    
    var description: String {
        switch self {
        case .enum(let cases):
            return "enum of \(cases)"
        }
    }
    
}

enum RhsItem: CustomStringConvertible {
    
    case terminal(type: String)
    case nonTerminal(name: String)
    
    var description: String {
        switch self {
        case .terminal(let type):
            return type
        case .nonTerminal(let name):
            return name
        }
    }
    
    init(from token: Token) {
        
        if token.type == "terminal" {
            self = .terminal(type: token.content)
        } else if token.type == "nonTerminal" {
            self = .nonTerminal(name: token.content)
        } else {
            fatalError()
        }
        
    }
    
}
