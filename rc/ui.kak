try %{ declare-user-mode ui }

define-command -override ui -docstring 'ui' %{
    enter-user-mode ui
}

# Options

set-face global Search +bu@MatchingChar
set-face global TrailingSpace Error
set-face global TodoComment +bf@Information
set-face global CursorLine "default,rgba:77777720"
set-face global CursorColumn "default,rgba:77777720"

declare-option str-list ui_line_numbers_flags
declare-option str-list ui_whitespaces_flags
declare-option str-list ui_wrap_flags
declare-option str ui_todo_keywords_regex "\b(TODO|FIXME|XXX|NOTE)\b"

# Mappings

map -docstring 'toggle line numbers' global ui l ': ui-line-numbers-toggle<ret>'
map -docstring 'toggle whitespaces' global ui s ': ui-whitespaces-toggle<ret>'
map -docstring 'toggle trailing spaces' global ui t ': ui-trailing-spaces-toggle<ret>'
map -docstring 'toggle wrap' global ui w ': ui-wrap-toggle<ret>'
map -docstring 'toggle matching' global ui m ': ui-matching-toggle<ret>'
map -docstring 'toggle git diff' global ui d ': ui-git-diff-toggle<ret>'
map -docstring 'toggle lint diagnostics' global ui L ': ui-lint-toggle<ret>'
map -docstring 'toggle search' global ui / ': ui-search-toggle<ret>'
map -docstring 'toggle todo comments' global ui x ': ui-todos-toggle<ret>'
map -docstring 'toggle cursor line' global ui c ': ui-cursorline-toggle<ret>'
map -docstring 'toggle cursor column' global ui C ': ui-cursorcolumn-toggle<ret>'

# Commands
define-command ui-line-numbers-enable -docstring 'enable line numbers' %{
    add-highlighter window/line-numbers number-lines %opt{ui_line_numbers_flags}
    echo -markup "{Information}line numbers enabled"
}
define-command ui-line-numbers-disable -docstring 'disable line numbers' %{
    remove-highlighter window/line-numbers
    echo -markup "{Information}line numbers disabled"
}
define-command -override ui-line-numbers-toggle -docstring 'toggle line numbers' %{
    try %{ ui-line-numbers-enable } catch %{ ui-line-numbers-disable }
    trigger-user-hook ui-hl-changed
}

define-command ui-whitespaces-enable -docstring 'enable whitespaces' %{
    add-highlighter window/whitespaces show-whitespaces %opt{ui_whitespaces_flags}
    echo -markup "{Information}whitespaces enabled"
}
define-command ui-whitespaces-disable -docstring 'disable whitespaces' %{
    remove-highlighter window/whitespaces
    echo -markup "{Information}whitespaces disabled"
}
define-command -override ui-whitespaces-toggle -docstring 'toggle whitespaces' %{
try %{ ui-whitespaces-enable } catch %{ ui-whitespaces-disable }
    trigger-user-hook ui-hl-changed
}

define-command ui-wrap-enable -docstring 'enable wrap' %{
    add-highlighter window/wrap wrap %opt{ui_wrap_flags}
    echo -markup "{Information}soft wrap enabled"
}
define-command ui-wrap-disable -docstring 'disable wrap' %{
    remove-highlighter window/wrap
    echo -markup "{Information}soft wrap disabled"
}
define-command -override ui-wrap-toggle -docstring 'toggle soft wrap' %{
try %{ ui-wrap-enable } catch %{ ui-wrap-disable }
    trigger-user-hook ui-hl-changed
}

define-command ui-matching-enable -docstring 'enable matching' %{
    add-highlighter window/matching show-matching
    echo -markup "{Information}matching char enabled"
}
define-command ui-matching-disable -docstring 'disable matching' %{
    remove-highlighter window/matching
    echo -markup "{Information}matching char disabled"
}
define-command -override ui-matching-toggle -docstring 'toggle matching char' %{
    try %{ ui-matching-enable } catch %{ ui-matching-disable}
    trigger-user-hook ui-hl-changed
}

define-command ui-search-enable -docstring 'enable search' %{
    add-highlighter window/search fill Normal  # dummy to throw error if enabled
    hook window -group ui-search NormalKey [/?*nN]|<a-[/?*nN]> %{ try %{
        add-highlighter -override window/search dynregex '%reg{/}' 0:Search
    }}
    hook window -group ui-search NormalKey <esc> %{ try %{
        remove-highlighter window/search
    }}
    echo -markup "{Information}search enabled"
}
define-command ui-search-disable -docstring 'disable search' %{
    remove-highlighter window/search
    remove-hooks window ui-search
    echo -markup "{Information}search disabled"
}
define-command -override ui-search-toggle -docstring 'toggle search' %{
    try %{ ui-search-enable } catch %{ ui-search-disable}
    trigger-user-hook ui-hl-changed
}

define-command ui-trailing-spaces-enable -docstring 'enable trailing spaces' %{
    add-highlighter window/trailing-spaces regex '\h+$' 0:TrailingSpace
    echo -markup "{Information}trailing spaces enabled"
}
define-command ui-trailing-spaces-disable -docstring 'disable trailing spaces' %{
    remove-highlighter window/trailing-spaces
    echo -markup "{Information}trailing spaces disabled"
}
define-command -override ui-trailing-spaces-toggle -docstring 'toggle trailing spaces' %{
    try %{ ui-trailing-spaces-enable } catch %{ ui-trailing-spaces-disable }
    trigger-user-hook ui-hl-changed
}

define-command ui-todos-enable -docstring 'enable TODO comments' %{
    add-highlighter window/todo-comments regex %opt{ui_todo_keywords_regex} 0:TodoComment
    echo -markup "{Information}TODO comments enabled"
}
define-command ui-todos-disable -docstring 'disable TODO comments' %{
    remove-highlighter window/todo-comments
    echo -markup "{Information}TODO comments disabled"
}
define-command -override ui-todos-toggle -docstring 'toggle TODO comments' %{
    try %{ ui-todos-enable } catch %{ ui-todos-disable }
    trigger-user-hook ui-hl-changed
}

define-command ui-git-diff-enable -docstring 'enable git diff' %{
    add-highlighter window/git-diff flag-lines Default git_diff_flags
    evaluate-commands %sh{
        cd "$(dirname "$kak_buffile")"
        git_dir="$(git rev-parse --show-toplevel 2>/dev/null)"
        [ -n "$git_dir" ] && echo "git update-diff"
        [ -n "$git_dir" ] && echo "hook window -group ui-git-diff WinDisplay .* %{ git update-diff }"
        [ -n "$git_dir" ] && echo "hook window -group ui-git-diff BufWritePost .* %{ git update-diff }"
        [ -n "$git_dir" ] && echo "hook window -group ui-git-diff BufReload .* %{ git update-diff }"
    }
    echo -markup "{Information}git diff enabled"
}
define-command ui-git-diff-disable -docstring 'disable git diff' %{
    remove-highlighter window/git-diff
    remove-hooks window ui-git-diff
    echo -markup "{Information}git diff disabled"
}
define-command -override ui-git-diff-toggle -docstring 'toggle git diff' %{
    try %{ ui-git-diff-enable } catch %{ ui-git-diff-disable }
    trigger-user-hook ui-hl-changed
}

define-command ui-lint-enable -docstring 'enable lint diagnostics' %{
    # copy-pasta from rc/tools/lint.kak
    # Assume that if the highlighter is set, then hooks also are
    add-highlighter window/lint flag-lines default lint_flags
    hook window -group lint-diagnostics NormalIdle .* %{
        lint-show-current-line
    }
    hook window -group lint-diagnostics WinSetOption lint_flags=.* %{ info; lint-show-current-line }
    hook window -group lint-diagnostics BufWritePost .* %{
        try %{ lint }
    }
    hook window -group lint-diagnostics BufReload .* %{
        try %{ lint }
    }
    echo -markup "{Information}lint diagnostics enabled"
}
define-command ui-lint-disable -docstring 'disable lint diagnostics' %{
    # copy-pasta from rc/tools/lint.kak
    remove-highlighter window/lint
    remove-hooks window lint-diagnostics
    echo -markup "{Information}lint diagnostics disabled"
}
define-command -override ui-lint-toggle -docstring 'toggle lint diagnostics' %{
    try %{ ui-lint-enable } catch %{ ui-lint-disable }
    trigger-user-hook ui-hl-changed
}

define-command ui-cursorline-enable -docstring 'enable cursor line' %{
    add-highlighter window/cursorline line %val{cursor_line} CursorLine
    hook window -group ui-cursorline RawKey .* %{
        remove-highlighter window/cursorline
        add-highlighter window/cursorline line %val{cursor_line} CursorLine
    }
    echo -markup "{Information}cursor line enabled"
}
define-command ui-cursorline-disable -docstring 'disable cursor line' %{
    remove-highlighter window/cursorline
    remove-hooks window ui-cursorline
    echo -markup "{Information}cursor line disabled"
}
define-command -override ui-cursorline-toggle -docstring 'toggle cursor line' %{
    try %{ ui-cursorline-enable } catch %{ ui-cursorline-disable}
    trigger-user-hook ui-hl-changed
}

define-command ui-cursorcolumn-enable -docstring 'enable cursor column' %{
    add-highlighter window/cursorcolumn column %val{cursor_column} CursorColumn
    hook window -group ui-cursorcolumn RawKey .* %{
        remove-highlighter window/cursorcolumn
        add-highlighter window/cursorcolumn column %val{cursor_column} CursorColumn
    }
    echo -markup "{Information}cursor column enabled"
}
define-command ui-cursorcolumn-disable -docstring 'disable cursor column' %{
    remove-highlighter window/cursorcolumn
    remove-hooks window ui-cursorcolumn
    echo -markup "{Information}cursor column disabled"
}
define-command -override ui-cursorcolumn-toggle -docstring 'toggle cursor column' %{
    try %{ ui-cursorcolumn-enable } catch %{ ui-cursorcolumn-disable}
    trigger-user-hook ui-hl-changed
}
