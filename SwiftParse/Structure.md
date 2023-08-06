# Structure

SwiftParse is divided into _n_ steps:
 Step   | Input             | Output            | Description 
--------|-------------------|-------------------|------------
1       | `String`          | `[Token]`         | Produce tokens from the user's input (using SwiftLex) 
2       | `[Token]`         | `[Statement]`     | Parse the tokens (simple recursive descent) and produce statements 
3       | `[Statement]`     | `String`          | Produce a grammar from the SwiftParse specification
4       |                   |                   | 
5       |                   |                   | 
6       |                   |                   | 
7       |                   |                   | 
