extension Generator {
    
    var l0: String { "\n\t" }
    var l1: String { l0 + l0 }
    
    func build_type(for statement: Statement) throws -> String {
        
        let lhs = statement.lhs
        let type = statement.rhs
        
        switch type {
        case .enum(let cases):
            return try build_enum(lhs, cases)
        case .nested(let cases):
            return try build_nested(lhs, cases)
        case .precedence(let groups):
            return try build_precedence(lhs, groups)
        case .class(let elements, let allProductions):
            return try build_class(lhs, elements, allProductions)
        }
        
    }
    
}
