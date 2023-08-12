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

extension [ClassItem] {
    
    func produceSwiftSLRSyntax() -> String {
        
        var string = ""
        
        for item in self {
            string += item.swiftSLRToken + " "
        }
        
        return string
        
    }
    
}

extension String {
    
    private static let swiftKeywords = [
        "associativity", "async", "await", "break", "case", "catch", "class", "continue", "default", "defer",
        "deinit", "do", "else", "enum", "extension", "false", "fileprivate", "final", "for", "func", "get",
        "guard", "if", "import", "in", "infix", "init", "inout", "internal", "is", "lazy", "left", "let", "nil",
        "none", "nonmutating", "open", "operator", "optional", "override", "postfix", "precedence", "prefix",
        "private", "protocol", "public", "repeat", "required", "rethrows", "return", "right", "self", "set",
        "static", "struct", "subscript", "super", "switch", "throw", "throws", "true", "try", "try?", "try!",
        "typealias", "unowned", "var", "weak", "where", "while", "Type", "Self"
    ]
    
    // TODO: Backtick self if Swift keyword
    var nonColliding: String {
        if Self.swiftKeywords.contains(self) {
            return "`\(self)`"
        } else {
            return self
        }
    }
    
    var camelCased: String {
        
        guard let first = first else {
            return ""
        }
        
        return first.lowercased() + self[index(after: startIndex) ..< endIndex]
        
    }
    
    var CamelCased: String {
        
        guard let first = first else {
            return ""
        }
        
        return first.uppercased() + self[index(after: startIndex) ..< endIndex]
        
    }
    
    func changeToSwiftIdentifier(use backup: String) -> String {
        
        for c in self {
            if !"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz".contains(c) {
                return backup
            }
        }
        
        return self
        
    }
    
}
