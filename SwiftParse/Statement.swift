enum Statement {
    
    case `enum`(_ cases: [RhsItem])
    
}

enum RhsItem {
    case terminal(type: String)
    case nonTerminal(name: String)
}
