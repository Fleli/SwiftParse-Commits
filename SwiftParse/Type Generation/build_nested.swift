extension Generator {
    
    func build_nested(_ lhs: String, _ cases: [NestItem]) throws -> String {
        
        var string = "indirect enum \(lhs.nonColliding) {" + lt + lt
        
        for nestItem in cases {
            
            let caseName = nestItem.caseName
            let production = nestItem.production
            
            string += "case " + caseName.nonColliding
            
            var usedLabels: [String : Int] = [:]
            
            var associatedValues: [(label: String, type: String)] = []
            var associatedValuesString = ""
            
            func getLabel(_ expected: String) -> String {
                
                let expected = "_ " + expected.changeToSwiftIdentifier(use: "_terminal")
                
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
                    associatedValues.append((label: label + "s", type: "[" + repeating.swiftSLRToken.nonColliding + "]"))
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
            
            string += lt
            
        }
        
        string = string.dropLast() + "\n}\n"
        
        return string
        
    }
    
}
