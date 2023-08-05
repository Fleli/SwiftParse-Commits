
let generator = Generator()
let path = "/Users/frederikedvardsen/desktop/"

let specification = """
nested Type {
    
    case function Type #-> Type
    case tuple Type -> #( [ Type | #, ] #)
    case basic Type -> #identifier
    
}
"""

try generator.createParser(from: specification, named: "parseFile", at: path)
