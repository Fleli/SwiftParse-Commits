# Tree Conversion

One of the main reasons why SwiftParse is easier to use than SwiftSLR, is that SwiftParse automatically converts the generic SLRNode tree into a tree of user-defined types. These types are deduced from the SwiftParse specification.

SwiftSLR produces a tree of SLRNodes. It returns a single SLRNode with a number of children, each with a number of children themselves.

The user-defined types appear as cases of a `UserDefinedType` enum. Each SLRNode object is extended with the function with the function `convertToUserDefinedType() throws -> UserDefinedType`, which recursively (bottom-up) converts the tree of generic SLRNode objects into a tree of user-defined types.

