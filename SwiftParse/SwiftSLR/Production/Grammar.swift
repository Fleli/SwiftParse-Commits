class Grammar {
    
    var initialProduction: Production
    
    var productions: [Production] = []
    
    private var terminals: Set<String> = []
    
    var firstSets: [String : Set<String>] = [:]
    var followSets: [String : Set<String?>] = [:]
    
    private var firstSetCount: Int { firstSets.map { $0.value.count } .sum() }
    private var followSetCount: Int { followSets.map { $0.value.count } .sum() }
    
    init(_ initialProduction: Production) {
        
        self.initialProduction = initialProduction
        
        initialProduction.isAccepting = true
        
        addProduction(self.initialProduction)
        
    }
    
    func addProduction(_ production: Production) {
        
        production.grammar = self
        productions.append(production)
        
        terminals.formUnion(production.terminals)
        
    }
    
    func productionsFor(_ nonTerminal: String) -> [Production] {
        
        return productions.filter { $0.lhs == nonTerminal }
        
    }
    
    func calculateFirstAndFollowSets() {
        
        productions.forEach {
            firstSets[$0.lhs] = []
            followSets[$0.lhs] = []
        }
        
        followSets[initialProduction.lhs] = [nil]
        
        calculateFirstSets()
        calculateFollowSets()
        
        followSets.forEach {
            Swift.print($0)
        }
        
    }
    
    private func calculateFirstSets() {
        
        var firstSetCounts: [Int] = []
        
        let productionCount = productions.count
        
        var didReachFixedPoint: Bool {
            
            let lastIndex = firstSetCounts.count - 1
            
            return firstSetCounts.count > productionCount
                && firstSetCounts[lastIndex] == firstSetCounts[lastIndex - productionCount]
            
        }
        
        var productionIndex = 0
        
        while !didReachFixedPoint {
            
            let production = productions[productionIndex]
            
            let lhs = production.lhs
            let firstRhs = production.rhs[0]
            
            if case .nonTerminal(let rhsNonTerminal) = firstRhs {
                Swift.print("LHS nonTerminal is {\(rhsNonTerminal)}")
                let otherFirst = firstSets[rhsNonTerminal]!
                firstSets[lhs]?.formUnion(otherFirst)
            } else if case .terminal(let terminal) = firstRhs {
                firstSets[lhs]?.insert(terminal)
            }
            
            firstSetCounts.append(firstSetCount)
            productionIndex = (productionIndex + 1) % productionCount
            
        }
        
    }
    
    private func calculateFollowSets() {
        
        var followSetCounts: [Int] = []
        
        let productionCount = productions.count
        
        var didReachFixedPoint: Bool {
            
            let lastIndex = followSetCounts.count - 1
            
            return followSetCounts.count > productionCount
                && followSetCounts[lastIndex] == followSetCounts[lastIndex - productionCount]
            
        }
        
        var productionIndex = 0
        
        while !didReachFixedPoint {
            
            let production = productions[productionIndex]
            
            supplyFollowSet(from: production)
            
            followSetCounts.append(followSetCount)
            productionIndex = (productionIndex + 1) % productionCount
            
        }
        
    }
    
    private func supplyFollowSet(from production: Production) {
        
        let lhs = production.lhs
        
        for nonTerminal in production.nonTerminals {
            
            for nextNonTerminal in production.nonTerminalsAfter(nonTerminal) {
                let otherFirst = firstSets[nextNonTerminal]!
                followSets[nonTerminal]?.formUnion(otherFirst)
            }
            
            for nextTerminal in production.terminalsAfter(nonTerminal) {
                followSets[nonTerminal]?.insert(nextTerminal)
            }
            
            if production.nonTerminalIsLast(nonTerminal) {
                let lhsFollow = followSets[lhs]!
                followSets[nonTerminal]?.formUnion(lhsFollow)
            }
            
        }
        
    }
    
    func print(with indentation: Int = 0) {
        
        let prefix = String(repeating: "\t", count: indentation)
        
        Swift.print("\n" + prefix + "Grammar {")
        
        productions.forEach {
            Swift.print(prefix + "\t\($0)")
        }
        
        Swift.print(prefix + "}\n")
        
    }
    
}
