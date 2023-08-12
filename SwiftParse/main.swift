
// TODO: Endre syntax på precedence betydelig slik at argument labels og casenames blir bedre.

let generator = Generator()
let path = "/Users/frederikedvardsen/desktop/"

let specification = """
precedence Expression {
    infix #+
    infix #*
    prefix #-
    postfix #mh
    : #identifier
    : #( Expression #)
}
"""

try generator.createParser(from: specification, named: "parseFile", at: path)

