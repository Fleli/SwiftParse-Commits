# SwiftParse

SwiftParse is a Simple LR (SLR) parser generator. Both SwiftParse and the resulting parsers are written in Swift. It offers a layer of abstraction over [SwiftSLR](https://github.com/Fleli/SwiftSLR).

## Inner workings

SwiftParse is divided into 6 steps.

Steps 1 and 2 represent the front-end of SwiftParse. Step 1 uses a [SwiftLex](https://github.com/Fleli/SwiftLex)-generated lexer, and a handwritten LL(1) parser to make sense of the user's specification.

Step 3 uses the result of the front-end to generate a SwiftSLR grammar and a `Set` of `List` instances that are used in step 4 to complete the SwiftSLR grammar.

Step 5 uses the same `[Statement]` to build two files: The _type_ file (which includes `class` and `enum` definitions that are derived from the user's specification) and the
_converter_ file that extends the `SLRNode` class with functions that recursively convert the `SLRNode` tree into a tree the types from the type file.

Step 6 uses SwiftSLR to generate the `SLRParser` class. This is responsible for doing the actual parsing when the user passes in a series of `Token`s.


 Step   | Input             | Output                | Description 
--------|-------------------|-----------------------|------------
1       | `String`          | `[Token]`             | Produce tokens from the user's input (using SwiftLex) 
2       | `[Token]`         | `[Statement]`         | Parse the tokens (recursive descent) and produce statements 
3       | `[Statement]`     | `String`, `Set<List>` | Generate (most of) the SwiftSLR grammar, and find list definitions
4       | `Set<List>`       | `String`              | Extend the SwiftSLR grammar to include list definitions
5       | `[Statement]`     | `String`, `String`    | Generate type definitions and `SLRNode` tree converters, write them to files
6       | `String`          | `String`              | Use SwiftSLR to generate the actual parser and write to a file

## Empty Productions

Since SwiftParse builds on top of SwiftSLR, it is limited by one issue (missing feature) with SwiftSLR: It does not accept empty productions. Thus, it does (for instance) not allow a list to be empty, so `[ A ]` only recognizes `A`, `A A`, `A A A` and so on. 
