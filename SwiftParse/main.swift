
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
    case Return
    case Assignment
}

enum Visibility {
    case #private
    case #protected
    case #public
}

nested Type {
    case basic #identifier
    case function Type #-> Type
    case tuple #( [ Type | #, ] #)
}

enum DeclarationKeyword {
    case #let
    case #var
}

class Return {
    ! #return
    ? var expression: Expression
    ! #;
}

class Assignment {
    ! var lhs: #identifier
    ! #=
    ! var rhs: Expression
    ! #;
}

class Declaration {
    ? var visibility: Visibility
    ! var keyword: DeclarationKeyword
    ! var name: #identifier
    ? #: var type: Type
    ? #= var value: Expression
}

nested Reference {
    case variable #identifier
}

precedence Expression {
    infix #||
    infix #&&
    infix #!
    infix #|
    infix #^
    infix #&
    infix #== #!=
    infix #>= #<= #> #<
    infix #+ #-
    infix #* #/ #%
    prefix #-
    : Reference
    : #( Expression #)
    : Closure
}

class Closure {
    ! #{
    ? #: Type #;
    ! var list: Main
    ! #}
}

"""

do {
    
    try generator.createParser(from: specification, at: path)
    
} catch {
    
    print(error)
    
}
