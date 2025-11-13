" --- Basic UI Settings ---
syntax on                   " Enable syntax highlighting
set t_Co=256                " Enable 256 colors
set noshowmode              " Don't show mode command

" --- Text & Indentation (User Preference: Tabs) ---
set tabstop=4               " A tab character counts for 4 spaces
set shiftwidth=4            " Auto-indent uses 4 spaces
set softtabstop=4           " Backspace key works like shiftwidth
set noexpandtab             " Use real tabs for indentation (User's preference for alignment)
set autoindent              " Copy indent from current line when starting new line
set smartindent             " Smart indenting for C-style languages

" --- Searching ---
set ignorecase              " Ignore case when searching
set smartcase               " Do not ignore case when search pattern contains capitals
set hlsearch                " Highlight all search results
set incsearch               " Highlight search results as you type

" --- File Handling ---
set hidden                  " Allow buffer switching without saving
set encoding=utf-8          " Use UTF-8 for encoding
set nowrap                  " Don't wrap lines

" --- FORCE Visual Settings (Must be at the bottom) ---
set number                  " Show line numbers (Force load)
set relativenumber          " Show relative line numbers (Force load)