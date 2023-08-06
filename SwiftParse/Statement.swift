
struct Statement: CustomStringConvertible {
    
    let lhs: String
    let rhs: StatementType
    
    var description: String { lhs + ": " + rhs.description }
    
    func printString() throws {
        
        let string = try rhs.createProductions(with: lhs)
        print(string)
        
    }
    
}

enum StatementType: CustomStringConvertible {
    
    case `enum`(cases: [RhsComponent])
    case nested(cases: [NestItem])
    case precedence(groups: [PrecedenceGroup])
    case `class`(elements: [ClassElement])
    
    var description: String {
        switch self {
        case .enum(let cases):
            return "enum of \(cases)"
        case .nested(let items):
            return "nested of \(items)"
        case .precedence(let groups):
            return "precedence of \(groups)"
        case .class(let elements):
            return "class of \(elements)"
        }
    }
    
}

enum RhsComponent: CustomStringConvertible {
    
    case item(RhsItem)
    case list(repeating: RhsItem, separator: RhsItem?)
    
    var description: String {
        switch self {
        case .item(let rhsItem):
            return rhsItem.description
        case .list(let repeating, let separator):
            return "[ \(repeating.description) | \(String(describing: separator?.description)) ]"
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
    
    var swiftSLRToken: String {
        switch self {
        case .terminal(let type):
            return "#" + type
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
    case root(rhs: [RhsItem])
    
    var description: String {
        switch self {
        case .ordinary(let type, let operators):
            return type.rawValue + ": " + operators.description
        case .root(let rhs):
            return "root -> " + rhs.description
        }
    }
    
    var notRoot: Bool {
        switch self {
        case .ordinary(_, _):
            return true
        case .root(_):
            return false
        }
    }
    
}

enum OperatorPosition: String {
    case prefix = "prefix"
    case infix = "infix"
    case postfix = "postfix"
}

struct ClassElement: CustomStringConvertible {
    
    let required: Bool
    let classItems: [ClassItem]
    
    var description: String {
        return (required ? "!" : "?") + " " + classItems.description
    }
    
    init(_ lineInitializer: String, classItems: [ClassItem]) {
        
        switch lineInitializer {
        case "?":   required = false
        case "!":   required = true
        default:    fatalError()
        }
        
        self.classItems = classItems
        
    }
    
}

enum ClassItem: CustomStringConvertible {
    
    case classField(name: String, type: RhsItem)
    case syntactical(item: RhsItem)
    
    var description: String {
        switch self {
        case .classField(let name, let type):
            return name + ": " + type.description
        case .syntactical(let item):
            return item.description
        }
    }
    
}
