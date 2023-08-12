extension Generator {
    
    private var t1: String { "\t" }
    private var t2: String { t1 + t1 }
    
    private var signatureSuffix: String { " {\n\t\t\n" }
    
    private var convertToTerminalCall: String { "convertToTerminal()" }
    
    func build_conversion(_ statement: Statement) throws -> String {
        
        let lhs = statement.lhs
        let type = statement.rhs
        
        switch type {
        case .enum(let cases):
            return try build_conversion(lhs, cases)
        case .nested(let cases):
            return try build_conversion(lhs, cases)
        case .precedence(let groups):
            return try build_conversion(lhs, groups)
        case .class(let elements, let allProductions):
            return try build_conversion(lhs, elements, allProductions)
        }
        
    }
    
    private func callSyntax(for type: String) -> String {
        return "convertTo\(type.CamelCased)()"
    }
    
    private func signature(for type: String) -> String {
        return callSyntax(for: type) + " -> \(type.nonColliding)"
    }
    
    private func firstLine(for type: String) -> String {
        return "\tfunc " + signature(for: type) + signatureSuffix
    }
    
    private func typeIs(_ expected: String) -> String {
        return "if type == \"" + expected + "\""
    }
    
    private func child(_ index: Int, is type: String) -> String {
        return " && children[" + String(index) + "].type == \"" + type + "\""
    }
    
    private func childCountIs(_ count: Int) -> String {
        return " && children.count == \(count)"
    }
    
    private func declaration(_ index: Int, _ component: RhsComponent) -> String {
        
        let prefix = "let arg\(index) = children[\(index)]."
        
        switch component {
        case .item(let rhsItem):
            switch rhsItem {
            case .terminal(_):
                return prefix + convertToTerminalCall
            case .nonTerminal(let name):
                return prefix + callSyntax(for: name)
            }
        case .list(let repeating, _):
            return prefix + callSyntax(for: repeating.swiftSLRToken + "LIST")
        }
        
    }
    
    // If: "enum A { case p; case q; ... }", this function converts from the SLRNode with type 'A'. So this might return 'A.p'.
    private func build_conversion(_ lhs: String, _ cases: [RhsItem]) throws -> String {
        
        var string = firstLine(for: lhs)
        
        for enumCase in cases {
            switch enumCase {
            case .terminal(let type):
                string += t2 + typeIs(lhs) + child(0, is: type) + "{" + lt + t1 + "return \(lhs).\(type.camelCased.nonColliding)" + lt + "}" + lt + "\n"
            case .nonTerminal(let name):
                string += """
                        \(typeIs(lhs))\(child(0, is: name)) {
                            let nonTerminalNode = children[0].convertTo\(name.nonColliding)()
                            return \(lhs.nonColliding).\(name.camelCased.nonColliding)(nonTerminalNode)
                        }\(lt)\n
                """
            }
        }
        
        string += """
                fatalError()
            
            }
        
        """
        
        return string
        
    }
    
    // SLRNodes med type T hvor nested T er definert. Dvs returner en enum-case i enum-en T
    private func build_conversion(_ lhs: String, _ cases: [NestItem]) throws -> String {
        
        var string = firstLine(for: lhs)
        
        for nestCase in cases {
            
            let caseName = nestCase.caseName
            let production = nestCase.production
            
            var ifStatement = t2 + typeIs(lhs) + childCountIs(production.count)
            
            var declarations: [String] = []         // Hele declaration (Swift-statement)
            
            for (index, rhsComponent) in production.enumerated() {
                
                switch rhsComponent {
                case .item(let rhsItem):
                    switch rhsItem {
                    case .terminal(let type):
                        ifStatement += child(index, is: type)
                    case .nonTerminal(let name):
                        ifStatement += child(index, is: name)
                    }
                case .list(let repeating, _):
                    ifStatement += child(index, is: repeating.swiftSLRToken + "LIST")
                }
                
                declarations.append(declaration(index, rhsComponent))
                
            }
            
            ifStatement += " {" + lt + lt
            
            for declaration in declarations {
                ifStatement += t1 + declaration + lt
            }
            
            ifStatement += t1 + lt + t1 + "return \(lhs.nonColliding).\(caseName.nonColliding)("
            
            if declarations.count >= 2 {
                for index in 0 ..< declarations.count - 1 {
                    ifStatement += "arg\(index), "
                }
            }
            
            ifStatement += "arg\(declarations.count - 1))" + lt + lt
            
            ifStatement += "}" + lt
            
            string += ifStatement + "\n"
            
        }
        
        string += t2 + "fatalError()\n\t\n\t}\n\t"
        
        return string
        
    }
    
    private func build_conversion(_ lhs: String, _ groups: [PrecedenceGroup]) throws -> String {
        
        var string = firstLine(for: lhs)
        
        for (index, group) in groups.enumerated() {
            
            let prefix = (index > 0) ? "CASE" + index.toLetters() : ""
            let nonTerminal = prefix + lhs
            
            switch group {
            case .ordinary(let position, let operators):
                
                let nextPrefix = "CASE" + (index + 1).toLetters()
                let nextNonTerminal = nextPrefix + lhs
                
                for `operator` in operators {
                    
                    // Steg 1: Konverter når parseren har sett at operasjonen faktisk utføres
                    
                    var ifStatement = "\t\t" + typeIs(nonTerminal)
                    
                    switch position {
                    case .infix:
                        ifStatement +=
                            childCountIs(3)
                        +   child(0, is: nonTerminal)
                        +   child(1, is: `operator`.swiftSLRToken)
                        +   child(2, is: nextNonTerminal)
                        +   " {" + lttt + ltt
                        +   "\tlet arg1 = children[0].convertTo\(nonTerminal)" + ltt
                        +   "\tlet arg2 = children[2].convertTo\(nextNonTerminal)" + ltt
                        +   "\treturn "
                    case .prefix:
                        ifStatement +=
                            childCountIs(2)
                        +   child(0, is: `operator`.swiftSLRToken)
                        +   child(1, is: nextNonTerminal)
                        +   " {" + ltt + ltt
                    case .postfix:
                        ifStatement +=
                            childCountIs(2)
                        +   child(0, is: nextNonTerminal)
                        +   child(1, is: `operator`.swiftSLRToken)
                        +   " {" + ltt + ltt
                    }
                    
                    string += ifStatement + "}\n"
                    
                    // Steg 2: Konverter når den har "gått rett gjennom", dvs. f.eks. Expression -> CASEBExpression er brukt.
                    
                }
                
            case .root(let rhs):
                
                break
                
            }
            
        }
        
        return string
        
    }
    
    private func build_conversion(_ lhs: String, _ elements: [ClassElement], _ allProductions: [[ClassItem]]) throws -> String {
        
        return ""
        
    }
    
    
}
