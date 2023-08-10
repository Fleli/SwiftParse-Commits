extension Generator {
    
    private var l0: String { "\n\t" }
    private var l1: String { l0 + l0 }
    
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
    
    func build_enum(_ lhs: String, _ cases: [RhsItem]) throws -> String {
        
        var string = "enum \(lhs.nonColliding) {" + l0
        
        for enumCase in cases {
            
            let caseName: String
            let suffix: String
            
            switch enumCase {
            case .terminal(let type):
                caseName = type
                suffix = ""
            case .nonTerminal(let name):
                caseName = name
                suffix = "(" + name.CamelCased.nonColliding + ")"
            }
            
            string += "case " + caseName.camelCased.nonColliding + suffix + l0
            
        }
        
        string = string.dropLast() + "}\n"
        
        return string
        
    }
    
    func build_nested(_ lhs: String, _ cases: [NestItem]) throws -> String {
        
        var string = "enum \(lhs.nonColliding) {" + l1
        
        for nestItem in cases {
            
            let caseName = nestItem.caseName
            let production = nestItem.production
            
            string += "case " + nestItem.caseName.nonColliding
            
            var usedLabels: [String : Int] = [:]
            
            var associatedValues: [(label: String, type: String)] = []
            var associatedValuesString = ""
            
            func getLabel(_ expected: String) -> String {
                
                var expected = expected
                
                for c in expected {
                    if !"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz".contains(c) {
                        expected = "_terminal"
                        break
                    }
                }
                
                if let value = usedLabels[expected] {
                    usedLabels[expected]? += 1
                    return expected + "\(value)"
                }
                
                usedLabels[expected] = 1
                return expected
                
            }
            
            for rhsComponent in production {
                
                switch rhsComponent {
                case .item(let rhsItem):
                    switch rhsItem {
                    case .terminal(let type):
                        let label = getLabel(type)
                        associatedValues.append((label: label, type: "String"))
                    case .nonTerminal(let name):
                        let label = getLabel(name.camelCased.nonColliding)
                        associatedValues.append((label: label, type: name.nonColliding))
                    }
                case .list(let repeating, _):
                    let label = getLabel(repeating.swiftSLRToken.camelCased.nonColliding)
                    associatedValues.append((label: label + "s", type: "[" + repeating.swiftSLRToken + "]"))
                }
                
            }
            
            if associatedValues.count > 0 {
                
                for index in 0 ..< associatedValues.count - 1 {
                    let associatedValue = associatedValues[index]
                    associatedValuesString += associatedValue.label + ": " + associatedValue.type + ", "
                }
                
            }
            
            if let last = associatedValues.last {
                associatedValuesString += last.label + ": " + last.type
                string += "(" + associatedValuesString + ")"
            }
            
            string += l0
            
        }
        
        string = string.dropLast() + "\n}\n"
        
        return string
        
    }
    
    func build_precedence(_ lhs: String, _ groups: [PrecedenceGroup]) throws -> String {
        
        return ""
        
    }
    
    func build_class(_ lhs: String, _ elements: [ClassElement], _ allProductions: [[ClassItem]]) throws -> String {
        
        return ""
        
    }
    
    
}
