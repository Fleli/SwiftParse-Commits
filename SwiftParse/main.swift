
let generator = Generator()
let path = "/Users/frederikedvardsen/desktop/"

let specification = """

enum DeclarationPrefix {
    case #let
    case #var
    case Type
}

nested Type {
    
    case function Type #-> Type
    case tuple #( [ Type | #, ] #)
    case basic #identifier
    
}
"""

/*
 
 */

try generator.createParser(from: specification, named: "parseFile", at: path)

