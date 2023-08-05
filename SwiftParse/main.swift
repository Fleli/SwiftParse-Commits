
let generator = Generator()
let path = "/Users/frederikedvardsen/desktop/"

let specification = """
enum Statement {
    
    case Assignment
    case Declaration
    case Call
    
}
"""

try generator.createParser(from: specification, named: "parseFile", at: path)
