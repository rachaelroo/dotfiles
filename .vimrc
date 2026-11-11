" ============================================================================
"  vimrc - minimal, portable, plugin-free
"  Works with Vim 8.0+ and Neovim 0.5+. Just copy/symlink and go.
" ============================================================================

" --- Leader ---------------------------------------------------------------
let mapleader = ' '

" --- Basics ---------------------------------------------------------------
set nocompatible
set encoding=utf-8
scriptencoding utf-8

filetype plugin indent on
syntax enable

set hidden                  " hide abandoned buffers instead of unloading
set autoread                " reload files changed outside vim
set updatetime=300
set timeout timeoutlen=500 ttimeoutlen=10   " snappy key sequences
set backspace=indent,eol,start
set whichwrap+=<,>,[,],h,l
set mouse=a
set confirm                 " ask instead of failing on unsaved changes
set history=1000

" --- Files / backups ------------------------------------------------------
set nobackup nowritebackup noswapfile
if has('persistent_undo')
  let s:undo_dir = expand('~/.vim/undo')
  if !isdirectory(s:undo_dir)
    call mkdir(s:undo_dir, 'p', 0700)
  endif
  let &undodir = s:undo_dir
  set undofile
endif

" --- Search ---------------------------------------------------------------
set incsearch hlsearch
set ignorecase smartcase    " smart case: /foo matches Foo, /Foo only matches Foo

" --- Completion / navigation ---------------------------------------------
set wildmenu wildmode=longest:full,full
set completeopt=menuone,preview
set path+=**                " :find completes recursively
set scrolloff=5 sidescrolloff=5
set splitbelow splitright

" --- Indentation ----------------------------------------------------------
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set autoindent
set shiftround

" --- UI -------------------------------------------------------------------
set background=dark
set number
set cursorline
set laststatus=2            " always show the statusline
set noshowmode              " mode is shown in the statusline
set noruler                 " position is shown in the statusline
set showcmd
set showmatch
set matchtime=2
set title                   " put the file name in the terminal title
set shortmess+=c

silent! let &fillchars = 'vert:│,fold:·'   " slim split divider
silent! let &fillchars .= ',eob: '         " hide trailing tildes (Vim 8.2+)

if has('termguicolors')
        \ && ($COLORTERM =~? 'truecolor\|24bit' || $TERM =~? 'kitty\|alacritty\|wezterm\|foot\|ghostty')
  set termguicolors
endif

" --- Colors ---------------------------------------------------------------
" Compact Nord-flavoured palette: [gui, cterm]
let s:p = {}
let s:p.none   = []
let s:p.bg0    = ['#2e3440', 236]   " editor background
let s:p.bg1    = ['#3b4252', 238]   " cursorline / statusline
let s:p.bg2    = ['#434c5e', 239]   " visual selection / badges
let s:p.fg0    = ['#d8dee9', 253]   " main text
let s:p.light  = ['#e5e9f0', 254]   " bright text
let s:p.fg1    = ['#616e88', 60]    " comments / dim text
let s:p.muted  = ['#4c566a', 240]   " line numbers / faded UI
let s:p.red    = ['#bf616a', 131]
let s:p.orange = ['#d08770', 173]
let s:p.yellow = ['#ebcb8b', 186]
let s:p.green  = ['#a3be8c', 108]
let s:p.teal   = ['#8fbcbb', 109]
let s:p.purple = ['#b48ead', 139]
let s:p.blue   = ['#81a1c1', 110]
let s:p.cyan   = ['#88c0d0', 116]
let s:p.deep   = ['#5e81ac', 67]    " selection accents

function! s:hl(group, fg, bg, ...) abort
  let l:attr = a:0 > 0 ? a:1 : 'NONE'
  let l:gui_fg = empty(a:fg) ? 'NONE' : a:fg[0]
  let l:ct_fg  = empty(a:fg) ? 'NONE' : a:fg[1]
  let l:gui_bg = empty(a:bg) ? 'NONE' : a:bg[0]
  let l:ct_bg  = empty(a:bg) ? 'NONE' : a:bg[1]
  execute 'highlight ' . a:group
        \ . ' guifg=' . l:gui_fg . ' guibg=' . l:gui_bg . ' gui=' . l:attr
        \ . ' ctermfg=' . l:ct_fg . ' ctermbg=' . l:ct_bg . ' cterm=' . l:attr
endfunction

function! s:apply_colors() abort
  " --- editor chrome ---
  call s:hl('Normal',       s:p.fg0,   s:p.bg0)
  call s:hl('Cursor',       s:p.bg0,   s:p.fg0)
  call s:hl('CursorLine',   s:p.none,  s:p.bg1)
  call s:hl('CursorColumn', s:p.none,  s:p.bg1)
  call s:hl('ColorColumn',  s:p.none,  s:p.bg1)
  call s:hl('LineNr',       s:p.muted, s:p.none)
  call s:hl('CursorLineNr', s:p.yellow, s:p.bg1, 'bold')
  call s:hl('SignColumn',   s:p.none,  s:p.bg0)
  call s:hl('VertSplit',    s:p.bg2,   s:p.bg0)
  call s:hl('WinSeparator', s:p.bg2,   s:p.bg0)
  call s:hl('Folded',       s:p.fg1,   s:p.bg1, 'italic')
  call s:hl('FoldColumn',   s:p.fg1,   s:p.bg0)
  call s:hl('NonText',      s:p.bg2,   s:p.none)
  call s:hl('SpecialKey',   s:p.bg2,   s:p.none)
  call s:hl('Whitespace',   s:p.bg2,   s:p.none)
  call s:hl('EndOfBuffer',  s:p.bg0,   s:p.none)

  " --- windows / menus ---
  call s:hl('StatusLine',   s:p.fg0,   s:p.bg1)
  call s:hl('StatusLineNC', s:p.muted, s:p.bg0)
  call s:hl('TabLine',      s:p.fg1,   s:p.bg1)
  call s:hl('TabLineFill',  s:p.none,  s:p.bg0)
  call s:hl('TabLineSel',   s:p.light, s:p.bg2, 'bold')
  call s:hl('Pmenu',        s:p.fg0,   s:p.bg1)
  call s:hl('PmenuSel',     s:p.bg0,   s:p.deep)
  call s:hl('PmenuSbar',    s:p.none,  s:p.bg2)
  call s:hl('PmenuThumb',   s:p.none,  s:p.muted)
  call s:hl('WildMenu',     s:p.bg0,   s:p.deep)

  " --- search / matches ---
  call s:hl('Visual',       s:p.none,  s:p.bg2)
  call s:hl('VisualNOS',    s:p.none,  s:p.bg2)
  call s:hl('Search',       s:p.bg0,   s:p.yellow)
  call s:hl('IncSearch',    s:p.bg0,   s:p.orange)
  call s:hl('CurSearch',    s:p.bg0,   s:p.orange)
  call s:hl('MatchParen',   s:p.cyan,  s:p.bg2, 'bold')

  " --- messages ---
  call s:hl('Directory',    s:p.cyan,  s:p.none, 'bold')
  call s:hl('Title',        s:p.cyan,  s:p.none, 'bold')
  call s:hl('Question',     s:p.cyan,  s:p.none)
  call s:hl('ModeMsg',      s:p.green, s:p.none, 'bold')
  call s:hl('MoreMsg',      s:p.green, s:p.none, 'bold')
  call s:hl('WarningMsg',   s:p.yellow, s:p.none, 'bold')
  call s:hl('ErrorMsg',     s:p.red,   s:p.none, 'bold')

  " --- syntax ---
  call s:hl('Comment',      s:p.fg1,   s:p.none, 'italic')
  call s:hl('Constant',     s:p.orange, s:p.none)
  call s:hl('String',       s:p.green, s:p.none)
  call s:hl('Character',    s:p.green, s:p.none)
  call s:hl('Number',       s:p.orange, s:p.none)
  call s:hl('Boolean',      s:p.orange, s:p.none)
  call s:hl('Float',        s:p.orange, s:p.none)
  call s:hl('Identifier',   s:p.fg0,   s:p.none)
  call s:hl('Function',     s:p.cyan,  s:p.none)
  call s:hl('Statement',    s:p.blue,  s:p.none)
  call s:hl('Conditional',  s:p.blue,  s:p.none)
  call s:hl('Repeat',       s:p.blue,  s:p.none)
  call s:hl('Label',        s:p.blue,  s:p.none)
  call s:hl('Operator',     s:p.blue,  s:p.none)
  call s:hl('Keyword',      s:p.blue,  s:p.none)
  call s:hl('Exception',    s:p.blue,  s:p.none)
  call s:hl('PreProc',      s:p.purple, s:p.none)
  call s:hl('Include',      s:p.purple, s:p.none)
  call s:hl('Define',       s:p.purple, s:p.none)
  call s:hl('Macro',        s:p.purple, s:p.none)
  call s:hl('PreCondit',    s:p.purple, s:p.none)
  call s:hl('Type',         s:p.teal,  s:p.none)
  call s:hl('StorageClass', s:p.teal,  s:p.none)
  call s:hl('Structure',    s:p.teal,  s:p.none)
  call s:hl('Typedef',      s:p.teal,  s:p.none)
  call s:hl('Special',      s:p.red,   s:p.none)
  call s:hl('SpecialChar',  s:p.red,   s:p.none)
  call s:hl('Tag',          s:p.red,   s:p.none)
  call s:hl('Delimiter',    s:p.red,   s:p.none)
  call s:hl('Debug',        s:p.red,   s:p.none)
  call s:hl('Error',        s:p.red,   s:p.none, 'bold')
  call s:hl('Todo',         s:p.bg0,   s:p.yellow, 'bold')

  " --- statusline badges ---
  call s:hl('User3', s:p.light, s:p.muted)   " clock badge
  call s:update_mode()
endfunction

" --- Statusline -----------------------------------------------------------
"  [ MODE ]  file.txt [+]        vim  utf-8/unix  12:45  68%  [ 23:59 ]
let s:mode_names = {
      \ 'n': 'NORMAL',   'no': 'O-PENDING', 'nov': 'O-PENDING',
      \ 'noV': 'O-PENDING', "no\<C-v>": 'O-PENDING',
      \ 'v': 'VISUAL',   'V': 'V-LINE',     "\<C-v>": 'V-BLOCK',
      \ 's': 'SELECT',   'S': 'S-LINE',     "\<C-s>": 'S-BLOCK',
      \ 'i': 'INSERT',   'ic': 'INSERT',    'ix': 'INSERT',
      \ 'R': 'REPLACE',  'Rc': 'REPLACE',   'Rx': 'REPLACE',
      \ 'Rv': 'V-REPLACE', 'Rvc': 'V-REPLACE', 'Rvx': 'V-REPLACE',
      \ 'c': 'COMMAND',  'cv': 'EX',        'ce': 'EX',
      \ 'r': 'PROMPT',   'rm': 'MORE',      'r?': 'CONFIRM',
      \ 't': 'TERMINAL', 'nt': 'TERMINAL',  '!': 'SHELL',
      \ }

function! StatuslineMode() abort
  return printf('%-7s', get(s:mode_names, mode(), toupper(mode())))
endfunction

" Colour the mode badge to match the current mode.
function! s:update_mode() abort
  let l:m = mode(1)
  if l:m[0] ==# 'i'
    let l:color = s:p.green
  elseif l:m[0] ==# 'R'
    let l:color = s:p.red
  elseif l:m[0] =~# '[vVsS]' || l:m ==# "\<C-v>" || l:m ==# "\<C-s>"
    let l:color = s:p.purple
  elseif l:m[0] ==# 'c'
    let l:color = s:p.yellow
  elseif l:m[0] ==# 't'
    let l:color = s:p.cyan
  else
    let l:color = s:p.blue
  endif
  call s:hl('User1', s:p.bg0, l:color, 'bold')
endfunction

let s:stl  = "%1*  %{StatuslineMode()}  %*"
let s:stl .= "%<%f %h%m%r%w"
let s:stl .= "%="
let s:stl .= "%{&ft==#''?'none':&ft}  %{(&fenc==#''?&encoding:&fenc).'/'.&ff}"
let s:stl .= "  %l:%c  %p%%"
let s:stl .= "%3*  %{strftime('%H:%M')}  %*"
let &statusline = s:stl

" Keep the clock ticking while vim is idle.
if exists('*timer_start')
  function! s:redraw_status(timer) abort
    redrawstatus
  endfunction
  call timer_start(20000, function('s:redraw_status'), {'repeat': -1})
else
  augroup vimrc_clock
    autocmd!
    autocmd CursorHold * redrawstatus
  augroup END
endif

augroup vimrc_colors
  autocmd!
  autocmd ColorScheme * call s:apply_colors()
  if exists('##ModeChanged')
    autocmd ModeChanged * call s:update_mode()
  else
    autocmd InsertEnter,InsertLeave,ColorScheme * call s:update_mode()
  endif
augroup END

call s:apply_colors()

" --- Mappings -------------------------------------------------------------
nnoremap <silent> <leader><space> :nohlsearch<CR>
nnoremap Y y$
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
xnoremap < <gv
xnoremap > >gv

" --- Autocommands ---------------------------------------------------------
augroup vimrc_general
  autocmd!
  " Restore cursor position when reopening a file
  autocmd BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line('$') |
        \   execute "normal! g`\"" |
        \ endif
  " Never auto-comment new lines, Makefiles need real tabs
  autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
  autocmd FileType make setlocal noexpandtab
augroup END
