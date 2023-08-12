extension Generator {
    
    func build_precedence(_ lhs: String, _ groups: [PrecedenceGroup]) throws -> String {
        
        typealias Operators = [RhsItem]
        
        let swiftType = lhs.nonColliding
        
        var string = "enum \(swiftType) {\n\t\n"
        var operatorGroups: [Operators] = []
        
        let twoArgumentNonRoots = groups.filter { $0.isInfix }
        
        if twoArgumentNonRoots.count > 0 {
            
            string += "\tenum InfixOperator {\n\t"
            
            for index in 0 ..< twoArgumentNonRoots.count {
                string += "\tcase operator_\(index)\n\t" // TODO: Endre syntax slik at brukeren velger hva operatoren skal hete i denne enum-en. MERK: Det krever også endring i parseren og PrecedenceGroup-enum-en.
            }
            
            string += "}\n"
            
            string += "\t\n\tcase infixOperator(InfixOperator, \(lhs), \(lhs))\n\t\n"
            
        }
        
        let singleArgumentNonRoots = groups.filter { $0.isSingleArgument }
        
        if singleArgumentNonRoots.count > 0 {
            
            string += "\tenum SingleArgumentOperator {\n\t"
            
            for index in 0 ..< singleArgumentNonRoots.count {
                string += "\tcase operator_\(index)\n\t" // TODO: Endre syntax slik at brukeren velger hva operatoren skal hete i denne enum-en. MERK: Det krever også endring i parseren og PrecedenceGroup-enum-en.
            }
            
            string += "}\n\t\n\tcase singleArgumentOperator(SingleArgumentOperator, \(lhs))\n\t\n"
            
        }
        
        for group in groups {
            
            switch group {
            case .ordinary(_, let operators):
                operatorGroups.append(operators)
            case .root(let rhs):
                string += try build_precedence_root(rhs)
            }
            
        }
        
        string += "\n}\n"
        
        return string
        
    }
    
    private func build_precedence_root(_ rhs: [RhsItem]) throws -> String {
        
        var string = ""
        var associatedValues: [String] = []
        
        for item in rhs {
            switch item {
            case .terminal(let type):
                string += type.changeToSwiftIdentifier(use: "Terminal")
                associatedValues.append("String")
            case .nonTerminal(let name):
                string += name
                associatedValues.append(name)
            }
        }
        
        string = "\tcase " + string + "("
        
        if rhs.count >= 2 {
            for index in (0 ..< rhs.count - 1) {
                string += associatedValues[index] + ", "
            }
        }
        
        string += associatedValues.last! + ")"
        
        string += "\n"
        
        return string
        
    }
    
}
