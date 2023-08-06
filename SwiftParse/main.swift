
let generator = Generator()
let path = "/Users/frederikedvardsen/desktop/"

let specification = """

precedence Expression {
    
    infix #+ #-
    infix #* #/ #%
    prefix #-
    
    : #( Expression #)
    
}

"""

try generator.createParser(from: specification, named: "parseFile", at: path)
