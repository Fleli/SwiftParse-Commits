# Tree Conversion

One of the main reasons why SwiftParse is easier to use than SwiftSLR, is that SwiftParse automatically converts the generic SLRNode tree into a tree of user-defined types. These types are deduced from the SwiftParse specification.

SwiftSLR produces a tree of SLRNodes. It returns a single SLRNode with a number of children, each with a number of children themselves.

The user-defined types appear as cases of a `UserDefinedType` enum. Each SLRNode object is extended with the function with the function `convertToUserDefinedType() throws -> UserDefinedType`, which recursively (bottom-up) converts the tree of generic SLRNode objects into a tree of user-defined types.

The `convertToUserDefinedType() throws -> UserDefinedType` function is effectively organized as an `if - else if`-chain (it uses only `if` statements, but each statement contains a `return` statement and therefore does not fall through). Each `if` statement checks the node type, number of children and the type of each child of the given node. It therefore uniquely determines which production led to that node being created, and uses this to generate the correct user-defined type. One example of such an `if` statement (for the production `TypeLIST -> TypeLIST #, Type`)

    ```
    if type == "TypeList"  &&  children.count == 3  &&  children[0].type == "TypeList"  &&  children[1].type == ","  &&  children[2].type == "Type" { ... }
    ```
