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
                string += """
                        \(typeIs(lhs) + child(0, is: type)) {
                            return \(lhs).\(type.camelCased.nonColliding)
                        }
                        
                
                """
            case .nonTerminal(let name):
                string += """
                        \(typeIs(lhs))\(child(0, is: name)) {
                            let nonTerminalNode = children[0]\(callSyntax(for: name))()
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
            
            ifStatement += " {" + ltt
            
            for declaration in declarations {
                ifStatement += t1 + declaration + ltt
            }
            
            ifStatement += t1 + "return \(lhs.nonColliding).\(caseName.nonColliding)("
            
            if declarations.count >= 2 {
                for index in 0 ..< declarations.count - 1 {
                    ifStatement += "arg\(index), "
                }
            }
            
            ifStatement += "arg\(declarations.count - 1))" + ltt
            
            ifStatement += "}" + lt
            
            string += ifStatement + "\n"
            
        }
        
        string += t2 + "fatalError()\n\t\n\t}\n\t"
        
        return string
        
    }
    
    private func build_conversion(_ lhs: String, _ groups: [PrecedenceGroup]) throws -> String {
        
        var string = firstLine(for: lhs)
        
        var infixOperatorCount = 0
        var singleArgOperatorCount = 0
        
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
                        +   " {" + lttt + lttt
                        +   "let arg1 = children[0].convertTo\(nonTerminal)()" + lttt
                        +   "let arg2 = children[2].convertTo\(nextNonTerminal)()" + lttt
                        +   "return .infixOperator(.operator_\(infixOperatorCount), arg1, arg2)" + lttt + ltt
                        
                        infixOperatorCount += 1
                        
                    case .prefix:
                        
                        ifStatement +=
                            childCountIs(2)
                        +   child(0, is: `operator`.swiftSLRToken)
                        +   child(1, is: nextNonTerminal)
                        +   " {" + lttt + lttt
                        +   "let arg = children[1].convertTo\(nextNonTerminal)()" + lttt
                        +   "return .singleArgumentOperator(.operator_\(singleArgOperatorCount), arg)" + lttt + ltt
                        
                        singleArgOperatorCount += 1
                        
                    case .postfix:
                        
                        ifStatement +=
                            childCountIs(2)
                        +   child(0, is: nextNonTerminal)
                        +   child(1, is: `operator`.swiftSLRToken)
                        +   " {" + lttt + lttt
                        +   "let arg = children[0].convertTo\(nextNonTerminal)()" + lttt
                        +   "return .singleArgumentOperator(.operator_\(singleArgOperatorCount), arg)" + lttt + ltt
                        
                        singleArgOperatorCount += 1
                        
                    }
                    
                    string += ifStatement + "}" + ltt + "\n"
                    
                    // Steg 2: Konverter når den har "gått rett gjennom", dvs. f.eks. Expression -> CASEBExpression er brukt.
                    
                    string +=
                        "\t\t"
                    +   typeIs(nonTerminal)
                    +   childCountIs(1)
                    +   child(0, is: nextNonTerminal)
                    +   " {" + lttt + lttt
                    +   "return children[0].convertTo\(lhs)()" + lttt + ltt
                    +   "}" + ltt + "\n"
                    
                }
                
            case .root(let rhs):
                
                let lastGroup = groups.filter { $0.notRoot }.count
                let rootPrefix = "CASE" + lastGroup.toLetters()
                let nonTerminal = rootPrefix + lhs
                
                var declarations: [String] = []
                
                var ifStatement =
                    "\t\t"
                +   typeIs(nonTerminal)
                +   childCountIs(rhs.count)
                
                var caseName = ""
                
                for (index, rhsItem) in rhs.enumerated() {
                    switch rhsItem {
                    case .terminal(let type):
                        ifStatement += child(index, is: type)
                        declarations.append("let arg\(index) = children[\(index)].convertToTerminal()")
                        caseName += type.changeToSwiftIdentifier(use: "Terminal")
                    case .nonTerminal(let name):
                        ifStatement += child(index, is: name)
                        declarations.append("let arg\(index) = children[\(index)].convertTo\(name)()")
                        caseName += name
                    }
                }
                
                string +=
                    ifStatement
                +   " {" + lttt + lttt
                
                var returnStatement = "return " + caseName + "("
                
                for (index, declaration) in declarations.enumerated() {
                    
                    string += declaration + lttt
                    
                    returnStatement.append("arg\(index)")
                    
                    if index < declarations.count - 1 {
                        returnStatement.append(", ")
                    }
                    
                }
                
                string += returnStatement + ")" + lttt + ltt + "}" + ltt + "\n"
                
            }
            
        }
        
        return string
        
    }
    
    private func build_conversion(_ lhs: String, _ elements: [ClassElement], _ allProductions: [[ClassItem]]) throws -> String {
        
        var string = firstLine(for: lhs)
        
        for production in allProductions {
            
            var ifStatement = "\t\t" + typeIs(lhs) + childCountIs(production.count)
            var argumentDeclarations: [String] = []
            var initArgs: [String] = []
            
            for (index, classItem) in production.enumerated() {
                
                initArgs.append("arg\(index)")
                
                switch classItem {
                case .classField(_, let type):
                    
                    switch type {
                    case .terminal(let type):
                        ifStatement += child(index, is: type)
                        argumentDeclarations.append("let arg\(index) = children[\(index)].\(convertToTerminalCall)")
                    case .nonTerminal(let name):
                        ifStatement += child(index, is: type.swiftSLRNodeName)
                        argumentDeclarations.append("let arg\(index) = children[\(index)].\(callSyntax(for: name))")
                    }
                    
                case .syntactical(let item):
                    ifStatement += child(index, is: item.swiftSLRNodeName)
                    argumentDeclarations.append("let arg\(index) = children[\(index)].\(convertToTerminalCall)")
                }
                
            }
            
            ifStatement += " {\n"
            
            argumentDeclarations.forEach { ifStatement += "\t\t\t" + $0 + "\n" }
            
            ifStatement += "\t\t\treturn .init(" + initArgs.convertToList(", ") + ")\n\t\t}\n\t\t"
            
            string += ifStatement + "\n"
            
        }
        
        string += "\t\tfatalError()\n\t\t\n\t}\n"
        
        return string
        
    }
    
}
