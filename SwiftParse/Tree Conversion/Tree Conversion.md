# Tree Conversion

## Overview

Pure SwiftSLR produces a tree of `SLRNode` objects. It returns a single SLRNode with a number of children, each with a number of children themselves. SwiftParse uses the specification to automatically convert the generic SLRNode tree into a tree of user-defined types that are deduced from the classes, enums, etc. that the user specifies.

## User-defined types

A 'user-defined type' is a type that the user declares in the SwiftParse specification. For instance, the grammar
```
enum DeclarationVisibility {
    case #private
    case #protected
    case #public
}

enum DeclarationPrefix {
    case #let
    case #var
}

class Declaration {
    ? var visibility: DeclarationVisibility
    ! var keyword: DeclarationPrefix
    ! var name: #identifier
    ! #;
}
```
will introduce the user-defined types `DeclarationVisibility`, `DeclarationPrefix` and `Declaration`.

The grammar indicates that the `Declaration` class should contain the fields `visibility`, `keyword` and `name` of types `DeclarationVisibility`, `DeclarationPrefix` and `String`, respectively. Note that `name` is a `String` because all terminals should be stored as `String`s, whereas non-terminals are stored in dedicated (user-defined) types.

Two productions are generated for the `Declaration` non-terminal since the `visibility` field is optional. Note that `visibility` is literally stored as an optional in Swift. This results in having multiple initializers for the `Declaration` class:

```
class Declaration {

    let visibility: DeclarationVisibility?
    let keyword: DeclarationPrefix
    let name: String
    
    // Declaration -> DeclarationPrefix #identifier #;
    init(_ keyword: DeclarationPrefix, _ name: String) {
        self.visibility = nil
        self.keyword = keyword
        self.name = name
    }
    
    // Declaration -> DeclarationVisibility DeclarationPrefix #identifier #; 
    init(_ visibility: DeclarationVisibility, _ keyword: DeclarationPrefix, _ name: String) {
        self.visibility = visibility
        self.keyword = keyword
        self.name = name
    }
    
}
```

## Conversion

To convert from an `SLRNode` tree into a tree of user-defined types, 
