# Contributing to ClaudeUsage

Thank you for your interest in contributing to ClaudeUsage! 🎉

## How to Contribute

### Reporting Issues

- Check if the issue already exists
- Provide clear reproduction steps
- Include your PowerShell version (`$PSVersionTable`)
- Include module version (`Get-Module ClaudeUsage | Select-Object Version`)

### Suggesting Features

- Open an issue with the "enhancement" label
- Describe the use case
- Provide examples if possible

### Pull Requests

1. **Fork** the repository
2. **Create a feature branch**: `git checkout -b feature/your-feature-name`
3. **Make your changes**
4. **Test your changes**: Ensure the module works correctly
5. **Commit** with clear messages
6. **Push** to your fork
7. **Open a Pull Request**

## Development Setup

```powershell
# Clone the repository
git clone https://github.com/backmind/ClaudeUsage.git
cd ClaudeUsage

# Install the module locally for testing
Copy-Item -Path . -Destination "$env:USERPROFILE\Documents\PowerShell\Modules\ClaudeUsage\" -Recurse -Force

# Import and test
Import-Module ClaudeUsage -Force
Get-ClaudeUsage -Brief
```

## Testing

Before submitting a PR, test all parameters:

```powershell
# Test basic usage
Get-ClaudeUsage

# Test brief mode
Get-ClaudeUsage -Brief

# Test show all (if you have Claude Max)
Get-ClaudeUsage -ShowAll

# Test raw output
Get-ClaudeUsage -Raw
```

## Code Style

- Use clear variable names
- Add comments for complex logic
- Follow PowerShell best practices
- Keep functions focused and modular

## Areas for Contribution

We especially welcome contributions for:

- **Claude Max features**: If you have Claude Max, you can help test and improve 7-day limit displays
- **Error handling**: Improve error messages and edge cases
- **Documentation**: Examples, screenshots, tutorials
- **Cross-platform testing**: macOS and Linux support
- **Performance**: Optimize API calls and caching
- **Features**: New parameters, output formats, etc.

## Questions?

Feel free to open an issue for any questions about contributing!
