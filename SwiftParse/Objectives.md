# Objectives

The goal of SwiftParse is to allow a user to specify the syntax of a language without thinking too deeply about expressing it grammatically. SwiftParse is built on top of SwiftSLR, but hides the not-so-readable formal grammar and replaces it with an intuitive and concise specification.

For instance, SwiftParse should allow abstractions like

```
A -> [B]
```

to describe a list of at least one `B` object, instead of the less intuitive and purely grammatical way of expression: 

```
A -> A B
A -> B
```

Also, SwiftParse should reduce probability of error and be more maintainable than SwiftSLR is. Instead of hard-coding non-terminals into deeply recursive grammars, SwiftParse allows easy insertion and deletion without thinking of one production relative to others. For instance,

```
E -> E + T
E -> T
T -> T * F
T -> F
F -> (E)
F -> -F
F -> x
```

is relatively difficult to change later, because non-terminals are interdependent. The expression grammar illustrates some important issues: 
- It requires the user to think about how to express precedence
- It is very repetitive and not very concise
- It is difficult to change later on because of interdependancies between productions and non-terminals.

SwiftParse's `enum` function is specifically designed to solve these problems. It offers lighter and more readable syntax, and is much more maintainable. See the `Syntax` document for detailed information on syntax and semantics of the `enum` feature. 

```
E -> F {
    
    infix +
    infix *
    
    F -> -F
    F -> x
    F -> (E)
    
}
```
