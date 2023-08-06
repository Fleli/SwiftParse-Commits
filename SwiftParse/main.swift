
let generator = Generator()
let path = "/Users/frederikedvardsen/desktop/"

let specification = """

enum AccessControl {
    case #private
    case #protected
    case #public
}

enum DeclarationPrefix {
    case #let
    case #var
}

nested Type {
    case function Type #-> Type
    case tuple #( [ Type | #, ] #)
    case basic #identifier
}

precedence Expression {
    infix #+ #-
    infix #* #/ #%
    : #( Expression #)
    : #identifier
}

"""

/*
 
 */

try generator.createParser(from: specification, named: "parseFile", at: path)
