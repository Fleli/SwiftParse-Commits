
let generator = Generator()
let path = "/Users/frederikedvardsen/desktop/"

let specification = """
enum DeclarationVisibility {
    case #private
    case #protected
    case #public
}

enum DeclarationPrefix {
    case #let
    case #var
}

class Declaration {
    ? var visibility: DeclarationVisibility
    ! var keyword: DeclarationPrefix
    ! var name: #identifier
    ! #;
}
"""

/*
 
 */

try generator.createParser(from: specification, named: "parseFile", at: path)
