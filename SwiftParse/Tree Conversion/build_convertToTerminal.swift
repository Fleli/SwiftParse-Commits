extension Generator {
    
    func build_convertToTerminal() -> String {
        
        return """
        extension SLRNode {
        
            func convertToTerminal() -> String {
            
                if let token = self.token {
                    return token.content
                }
                
                fatalError()
            
            }
            
        }
        """
        
    }
    
}
