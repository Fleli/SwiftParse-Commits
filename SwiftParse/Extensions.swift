extension Int {
    
    func toLetters() -> String {
        
        var symbolValues: [Int] = []
        
        var _self = self
        let modulus = 26
        
        while _self >= 0 {
            
            let value = _self % modulus
            symbolValues.append(value)
            
            _self -= value
            _self /= modulus
            
            if _self == 0 {
                break
            }
            
        }
        
        var string = ""
        
        for value in symbolValues {
            let character = Character(UnicodeScalar(65 + value)!)
            string.insert(character, at: string.startIndex)
            
        }
        
        return string
        
    }
    
}

extension [RhsItem] {
    
    func produceSwiftSLRSyntax() -> String {
        
        var string = ""
        
        for item in self {
            string += item.swiftSLRToken + " "
        }
        
        return string
        
    }
    
}
