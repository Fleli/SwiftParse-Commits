extension StatementType {
    
    
    func createProductions(with lhs: String) throws -> String {
        
        switch self {
        case .enum(let cases):
            return try Self.enumCasesToString(cases, lhs)
        case .nested(let cases):
            return try Self.nestedCasesToString(cases, lhs)
        case .precedence(let groups):
            fatalError()
        case .class(let elements):
            fatalError()
        }
        
        return lhs
        
    }
    
    private static func enumCasesToString(_ cases: [RhsComponent], _ lhs: String) throws -> String {
        
        var string = ""
        
        for enumCase in cases {
            
            guard case .item(let rhsItem) = enumCase else {
                fatalError()
            }
            
            string += lhs + " -> " + rhsItem.swiftSLRToken + "\n"
            
        }
        
        return string
        
    }
    
    private static func nestedCasesToString(_ cases: [NestItem], _ lhs: String) throws -> String {
        
        var string = ""
        
        for nestItem in cases {
            
            string += lhs + " -> "
            
            for rhsComponent in nestItem.production {
                
                guard case .item(let rhsItem) = rhsComponent else {
                    print(rhsComponent)
                    fatalError()
                }
                
                string += rhsItem.swiftSLRToken + " "
                
            }
            
            string += "\n"
            
        }
        
        return string
        
    }
    
}
