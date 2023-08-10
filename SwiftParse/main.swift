
let generator = Generator()
let path = "/Users/frederikedvardsen/desktop/"

let specification = """
enum DeclarationVisibility {
    case #private
    case #protected
    case Other
}

enum Other {
    case #lol
    case #mh
}
"""

/*
 
 */

try generator.createParser(from: specification, named: "parseFile", at: path)
