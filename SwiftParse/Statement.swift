
struct Statement: CustomStringConvertible {
    
    let lhs: String
    let rhs: StatementType
    
    var description: String { lhs + ": " + rhs.description }
    
}

enum StatementType: CustomStringConvertible {
    
    case `enum`(cases: [RhsComponent])
    case nested(cases: [NestItem])
    case precedence(groups: [PrecedenceGroup])
    
    var description: String {
        switch self {
        case .enum(let cases):
            return "enum of \(cases)"
        case .nested(let items):
            return "nested of \(items)"
        case .precedence(let groups):
            return "precedence of \(groups)"
        }
    }
    
}

enum RhsComponent: CustomStringConvertible {
    
    case item(RhsItem)
    case control(Token)
    
    var description: String {
        switch self {
        case .item(let rhsItem):
            return rhsItem.description
        case .control(let token):
            return token.type
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
    
    init?(from token: Token) {
        
        if token.type == "terminal" {
            self = .terminal(type: token.content)
        } else if token.type == "nonTerminal" {
            self = .nonTerminal(name: token.content)
        } else {
            return nil
        }
        
    }
    
}

struct NestItem: CustomStringConvertible {
    
    let caseName: String
    let production: [RhsComponent]
    
    var description: String { caseName + " -> " + production.description }
    
}

enum PrecedenceGroup: CustomStringConvertible {
    
    case ordinary(type: OperatorPosition, operators: [RhsItem])
    case root(rhs: [RhsComponent])
    
    var description: String {
        switch self {
        case .ordinary(let type, let operators):
            return type.rawValue + ": " + operators.description
        case .root(let rhs):
            return "root -> " + rhs.description
        }
    }
    
}

enum OperatorPosition: String {
    case prefix = "prefix"
    case infix = "infix"
    case postfix = "postfix"
}
