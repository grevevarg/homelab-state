from ansible.plugins.filter.core import FilterModule as CoreFilterModule

class FilterModule:
    def filters(self):
        return {
            'parse_package_list': self.parse_package_list,
        }
    
    @staticmethod
    def parse_package_list(content):
        """Parse base64-encoded package file content into a list of packages."""
        if isinstance(content, bytes):
            content = content.decode('utf-8')
        elif isinstance(content, str):
            # If it's base64, decode it first
            try:
                import base64
                content = base64.b64decode(content).decode('utf-8')
            except:
                pass
        
        # Split by newlines, strip whitespace, filter empty lines and comments
        return [line.strip() for line in content.split('\n') 
                if line.strip() and not line.startswith('#')]
