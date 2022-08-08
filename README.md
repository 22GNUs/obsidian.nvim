# Obsidian.nvim

A Neovim plugin for [Obsidian](https://obsidian.md), written in Lua.

This is for people who love the concept of Obsidian -- a simple, markdown-based notes app -- but love Neovim too much to stand typing characters into anything else.

## Features

- ▶️ Autocompletion for note references via [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) (triggered by typing `[[`)
- 🏃 Go to a note buffer with `gf` when cursor is on a reference
- 💅 Additional markdown syntax highlighting and concealing for references

### Commands

- `:ObsidianBacklinks` for getting a location list of references to the current buffer
- `:ObsidianToday` to create a new daily note
- `:ObsidianOpen` to open a note in the Obsidian app (only works on MacOS for now - [#4](https://github.com/epwalsh/obsidian.nvim/issues/4))

## Setup

### Requirements

- A nightly build of NeoVim (this plugin uses `vim.fs`).
- The [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) plugin.
- If you want completion features (recommended) you'll also need [ripgrep](https://github.com/BurntSushi/ripgrep) to be installed and on your `$PATH`.
See [ripgrep#installation](https://github.com/BurntSushi/ripgrep) for install options.

### Install

Using `vim-plug`, for example:

```vim
Plug 'nvim-lua/plenary.nvim'  " required
Plug 'hrsh7th/nvim-cmp'       " optional, for completion
Plug 'godlygeek/tabular'      " optional, needed for 'preservim/vim-markdown'
Plug 'preservim/vim-markdown' " optional, recommended for syntax highlighting, folding, etc if you're not using nvim-treesitter
Plug 'epwalsh/obsidian.nvim'
```

To avoid unexpected breaking changes, you can also pin `Obsidian.nvim` to a specific release like this:

```vim 
Plug 'epwalsh/obsidian.nvim', { 'tag': 'v1.*' }
```

Always check the [CHANGELOG](./CHANGELOG.md) when upgrading.

### Configuration

For a minimal configuration, just add:

```lua
require("obsidian").setup({
  dir = "~/my-vault",
  completion = {
    nvim_cmp = true, -- if using nvim-cmp, otherwise set to false
  }
})
```

❗ Note: you do **not** need to specify this plugin as an `nvim-cmp` "source".
Obsidian.nvim will set itself up as a source automatically when you enter a markdown buffer within your vault directory.

```lua
require("cmp").setup({
  sources = {
    { name = "obsidian" }, -- WRONG! Don't put this here. Obsidian configures itself for nvim-cmp
  },
})
```

❗ Note: if you're using [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter/blob/master/README.md) and not [vim-markdown](https://github.com/preservim/vim-markdown), you'll probably want to enable `additional_vim_regex_highlighting` for markdown to benefit from Obsidian.nvim's extra syntax improvements:

```lua 
require("nvim-treesitter.configs").setup({
  ensure_installed = { "markdown", "markdown_inline", ... },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = { "markdown" },
  },
})
```
