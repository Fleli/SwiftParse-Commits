
// TODO: Endre syntax på precedence betydelig slik at argument labels og casenames blir bedre.
// Merk: Mange av generator-funksjonene har veldig lik form. Kan være et hint om at det er mulig å generalisere de ulike statements og få til både mer funksjonalitet og ryddigere kode i en senere versjon. Undersøk nærmere ...

// TODO: Oppdater parser & generator for classes slik at liste-definisjoner er mulig der også

let generator = Generator()
let path = "/Users/frederikedvardsen/desktop/"

let specification = """

@main Main

nested Main {
    case list [ Statement ]
}

enum Statement {
    case Declaration
    case Assignment
    case Function
}

enum DeclarationKeyword {
    case #let
    case #var
}

nested Type {
    case basic #identifier
    case function Type #-> Type
    case tuple #( [ Type | #, ] #)
}

class Assignment {
    ! var lhs: Reference
    ! #=
    ! var rhs: Expression
    ! #;
}

class Declaration {
    ! var keyword: DeclarationKeyword
    ! var name: #identifier
    ? #: var type: Type
    ? #= var value: Expression
    ! #;
}

nested Reference {
    case variable #identifier
    case call Reference #( [ Argument | #, ] #)
}

class Argument {
    ? var flowWord: #identifier #:
    ! var value: Expression
}

precedence Expression {
    infix #+ #-
    infix #* #/ #%
    prefix #-
    : Reference
    : #( Expression #)
}

class Function {
    ! #func var name: #identifier
    ! #( var parameters: Parameters #)
    ? #-> var returnType: Type
    ! #{ var body: Main #}
}

nested Parameters {
    case parameterList [ Parameter | #, ]
}

class Parameter {
    ? var label: #identifier
    ! var name: #identifier
    ! #:
    ! var type: Type
}

"""

do {
    
    try generator.createParser(from: specification, at: path)
    
} catch {
    
    print(error)
    
}
