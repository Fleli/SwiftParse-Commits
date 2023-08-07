# SwiftParse

SwiftParse is an SLR parser generator. It offers a layer of abstraction over [https://github.com/Fleli/SwiftSLR].

SwiftParse is divided into _n_ steps.

The first two represent SwiftParse's front-end, and has the responsibility of making sense of the user's specification.
The third and fourth steps use that specification to generate a (SwiftSLR) parser.


 Step   | Input             | Output            | Description 
--------|-------------------|-------------------|------------
1       | `String`          | `[Token]`         | Produce tokens from the user's input (using SwiftLex) 
2       | `[Token]`         | `[Statement]`     | Parse the tokens (recursive descent) and produce statements 
3       | `[Statement]`     | `String`          | Produce a grammar from the SwiftParse specification
4       | `String`          | `String`          | Feed the grammar into SwiftSLR to produce a parser 
5       |                   |                   | 
6       |                   |                   | 
7       |                   |                   | 
