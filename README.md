# SwiftParse

SwiftParse is a Simple LR (SLR) parser generator. Both SwiftParse and the resulting parsers are written in Swift. It offers a layer of abstraction over [SwiftSLR](https://github.com/Fleli/SwiftSLR). In addition to calling the SwiftSLR API for the actual parser, SwiftParse does two things:
- It takes the user's specification and forms Swift types that match them
- It defines extension on the `SLRNode` type (the type that makes up the parse tree) to convert the tree so it consists only of user-defined types

## How do I use SwiftParse?

SwiftParse is not organized as a package (though this might change later). Instead, you use its `main.swift` file to tell SwiftParse what should be generated. The `createParser` function of `generator` takes in a `specification` (`String`) and a `path` (`String`). When you run the program, it will (if the specification does not contain errors) generate three files: `Types.swift`, `Converters.swift` and `Parser.swift`. The latter comes from SwiftSLR.

## The SwiftParse specification format

A SwiftParse specification `String` starts with an `@main` statement, starting with the `@main` reserved keyword followed by a non-terminal. This is used to tell the parser what production is final and accepting. An `@main` statement might look like this:

```
@main Main
```

Then comes the actual (abstracted) grammar. SwiftParse offers four types of statements:
- `enum` statements, for simple groups of related but distinct options
- `nested` statements, for extended `enum`s that allow indirection, multiple terminals and non-terminals per case, and lists.
- `precedence` statements, that offer a maintainable, readable and clean syntax for deeply dependent (and recursive) productions
- `class` statements, for types that follow a specific pattern, with some optional and some required parts

Note: The non-terminal `SwiftSLRMain` is reserved by SwiftParse and should never be used. 

### The `enum` statement

`enum` statements are the simplest of the four. If declarations can start either with the `var` or `let` keywords, an `enum` is perfect:

The SwiftParse syntax for that `enum` would look the following:
```
enum DeclarationPrefix {
    case #let
    case #var
}
```

When SwiftParse sees this statement, it will
- include the `DeclarationPrefix` productions in the grammar that it passes to SwiftSLR
- create a `DeclarationPrefix` type (including `CustomStringConvertible` conformance) in the resulting Swift files so that it can be further used
- generate converter functions so that the raw `SLRNode` tree from SwiftSLR's parser can be converted to user-defined types

The `DeclarationPrefix` type in the resulting `Types.swift` file will look like this:
```
public enum DeclarationKeyword: CustomStringConvertible {
	
    case `let`
    case `var`
	
    public var description: String {
    	switch self {
    	case .`let`: return "let"
    	case .`var`: return "var"
    	}
    }
    
}
```

### The `nested` statement

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
