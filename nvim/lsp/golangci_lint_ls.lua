vim.lsp.config.golangci_lint_ls = {
	cmd = {'golangci-lint-langserver'},
	filetypes = { 'go' },
	init_options = {
		command = {
			"golangci-lint",
			"run",
			"--output.json.path",
			"stdout",
			"--show-stats=false",
			"--issues-exit-code=1",
			"--path-mode=abs",
		},
	},
}
