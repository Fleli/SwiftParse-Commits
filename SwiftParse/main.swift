
// TODO: Endre syntax på precedence betydelig slik at argument labels og casenames blir bedre.
// Merk: Mange av generator-funksjonene har veldig lik form. Kan være et hint om at det er mulig å generalisere de ulike statements og få til både mer funksjonalitet og ryddigere kode i en senere versjon. Undersøk nærmere ...

// TODO: Oppdater parser & generator for classes slik at liste-definisjoner er mulig der også

let generator = Generator()
let path = "/Users/frederikedvardsen/desktop/"

let specification = """

enum Visibility {
    case #private
    case #public
}

nested Type {
    case tuple #( [ Type | #, ] #)
    case basic #identifier
}

class Declaration {
    
    ? var visibility: Visibility
    ! var name: #identifier
    ? var type: Type
    
}

"""

try generator.createParser(from: specification, named: "parseFile", at: path)

