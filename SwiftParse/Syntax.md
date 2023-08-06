# Syntax

The following is a playground to test 

```

// OK
@main [Statement]

// OK
enum Statement {
    case Declaration
    case Class
    case Assignment
}

// Acceptable
class Declaration {
    
    ? var visibility: VisibilityModifier
    ! var keyword: DeclarationPrefix
    ! var name: #identifier
    ? #: var type: Type
    ? #= var value: Expression
    ! #;
    
    // A declaration ...
    // optionally begins with a visibilityModifier.
    // then, it has a keyword
    // then, it has a name
    // then, it optionally has an explicit type
    // then, it optionally has an initial value
    // then, it has a semicolon
    
}

enum VisibilityModifier {
    case #private
    case #protected
    case #public
}

enum DeclarationPrefix {
    case #let
    case #var
}

// nested produces enum but is recursive and allows nesting (via associated values) instead of exactly one match
// Each case includes a name, followed by the RHS of the production that produces that case (the specified nonterminal always appears on the left)

nested Type {
    
    case function Type #-> Type                 // A 'Type' is a function from one 'Type' to another
    case tuple #( [ Type | #, ] #)              // A 'Type' is a list of 'Type's separated by ','
    case basic #identifier                      // A 'Type' is an identifier
    
}

// A few things are required for Expressions: They follow some precedence rules, and they should be stored in an enum.

precedence Expression {
    
    infix #+ #-
    infix #* #/ #%
    prefix #-
    
    : #( Expression #)
    : #identifier
    
}

```
