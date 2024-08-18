# Go Bash Completion Script

This repository contains a Bash completion script for the Go programming language command-line tools. It provides intelligent auto-completion for Go commands and their various options, making it easier and faster to work with Go from the command line.

## Features

- Comprehensive completion for main Go commands (`build`, `run`, `test`, etc.)
- Subcommand-specific completions (e.g., `go mod init`, `go tool pprof`, etc.)
- Intelligent package name suggestions based on your current workspace
- Workspace-aware completions that adapt to the presence of `go.work` files
- Caching of package lists for improved performance

## Installation

1. Clone this repository or download the script file:
   ```bash
   git clone https://github.com/Watchdog0x/goComplete.git && cd goComplete && sudo chmod +x go-completion.sh
   ```

2. Add the script to your `bash_completion`:
   ```bash
   if [ -d "/usr/share/bash-completion/completions" ]; then
       sudo ln -rfs go-completion.sh /usr/share/bash-completion/completions/go
   else
       sudo ln -rfs go-completion.sh /etc/bash_completion.d/
   fi
   ```

3. Restart your terminal or run `source ~/.bashrc` to apply the changes.

## Usage

Once installed, you can start using the Go completion script immediately. Simply start typing a Go command and press Tab to see available completions. For example:

```bash
go b<Tab>           # Completes to: go build
go run -<Tab>       # Shows available flags for 'go run'
go mod i<Tab>       # Completes to: go mod init
```

## Supported Commands

This completion script supports all major Go commands and their subcommands, including:

- `build`
- `clean`
- `doc`
- `env`
- `fix`
- `fmt`
- `generate`
- `get`
- `install`
- `list`
- `mod`
- `run`
- `test`
- `tool`
- `version`
- `vet`
- `work`

Each command has tailored completions for its specific flags and options.

## Contributing

Contributions to improve this completion script are welcome! Please feel free to submit issues or pull requests if you find any bugs or have suggestions for enhancements.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- The Go team for creating such an amazing language and toolset
- The Bash completion community for their excellent documentation and examples
