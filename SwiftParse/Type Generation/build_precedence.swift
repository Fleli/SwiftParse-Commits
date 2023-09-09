extension Generator {
    
    func build_precedence(_ lhs: String, _ groups: [PrecedenceGroup]) throws -> String {
        
        typealias Operators = [RhsItem]
        
        let swiftType = lhs.nonColliding
        
        var string = desiredVisibility + " indirect enum \(swiftType) {\n\t\n"
        var operatorGroups: [Operators] = []
        
        let twoArgumentNonRoots = groups.compactMap { $0.infixOperators }
        let ta = twoArgumentNonRoots.reduce([], { $0 + $1 } )
        let taCount = twoArgumentNonRoots.map({ $0.count }).reduce(0, { $0 + $1 })
        
        print("Two argument non roots of \(lhs): \(twoArgumentNonRoots.count) \(twoArgumentNonRoots)")
        
        if taCount > 0 {
            
            string += "\t\(desiredVisibility) enum InfixOperator: String {\n\t"
            
            for index in 0 ..< taCount {
                string += "\tcase operator_\(index) = \"\(ta[index])\"\n\t" // TODO: Endre syntax slik at brukeren velger hva operatoren skal hete i denne enum-en. MERK: Det krever også endring i parseren og PrecedenceGroup-enum-en.
            }
            
            string += "}\n"
            
            string += "\t\n\tcase infixOperator(InfixOperator, \(lhs), \(lhs))\n\t\n"
            
        }
        
        let singleArgumentNonRoots = groups.compactMap { $0.singleArgumentOperators }
        let sa = singleArgumentNonRoots.reduce([], { $0 + $1 })
        let saCount = sa.count
        
        print("Single argument non roots of \(lhs): \(singleArgumentNonRoots.count) \(singleArgumentNonRoots)")
        
        if saCount > 0 {
            
            string += "\t\(desiredVisibility) enum SingleArgumentOperator: String {\n\t"
            
            for index in 0 ..< saCount {
                string += "\tcase operator_\(index)\"\(sa[index])\"\n\t" // TODO: Endre syntax slik at brukeren velger hva operatoren skal hete i denne enum-en. MERK: Det krever også endring i parseren og PrecedenceGroup-enum-en.
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
