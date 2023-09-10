extension Generator {
    
    private typealias AssociatedValue = (label: String, type: String)
    
    func build_nested(_ lhs: String, _ cases: [NestItem]) throws -> String {
        
        var string = "\(desiredVisibility) indirect enum \(lhs.nonColliding) {" + lt + lt
        
        for nestItem in cases {
            build(&string, with: nestItem)
        }
        
        string = string.dropLast() + "\n}\n"
        
        return string
        
    }
    
    private func build(_ string: inout String, with nestItem: NestItem) {
        
        let caseName = nestItem.caseName
        let production = nestItem.production
        
        string += "case " + caseName.nonColliding
        
        var usedLabels: [String : Int] = [:]
        
        var associatedValues: [(label: String, type: String)] = []
        var associatedValuesString = ""
        
        for rhsComponent in production {
            let associatedValue = associatedValue(of: rhsComponent, with: &usedLabels)
            associatedValues.append((label: associatedValue.label, type: associatedValue.type))
        }
        
        associatedValuesString += associatedValues.reduce("", {$0 + $1.label + ": " + $1.type + ", "}).dropLast(2)
        
        if associatedValues.count > 0 {
            string += "(" + associatedValuesString + ")"
        }
        
        string += lt
        
    }
    
    private func associatedValue(of rhsComponent: RhsComponent, with usedLabels: inout [String : Int]) -> AssociatedValue {
        
        let associatedValueLabel: String
        let associatedValueType: String
        
        switch rhsComponent {
        case .item(let rhsItem):
            
            switch rhsItem {
            case .terminal(let type):
                associatedValueLabel = getLabel(&usedLabels, type)
                associatedValueType = "String"
            case .nonTerminal(let name):
                associatedValueLabel = getLabel(&usedLabels, name.camelCased.nonColliding)
                associatedValueType = name.nonColliding
            }
            
        case .list(let repeating, _):
            
            associatedValueLabel = getLabel(&usedLabels, repeating.swiftSLRToken.camelCased.nonColliding) + "s"
            associatedValueType = "[" + repeating.swiftSLRToken.nonColliding + "]"
            
        }
        
        return (associatedValueLabel, associatedValueType)
        
    }
    
    private func getLabel(_ usedLabels: inout [String : Int], _ expected: String) -> String {
        
        let expected = "_ " + expected.changeToSwiftIdentifier(use: "_terminal")
        
        if let value = usedLabels[expected] {
            usedLabels[expected]? += 1
            return expected + "\(value)"
        }
        
        usedLabels[expected] = 1
        return expected
        
    }
    
}
