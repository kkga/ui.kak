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

define-command -override ui-line-numbers-toggle -docstring 'toggle line numbers' %{
    try %{
        add-highlighter window/line-numbers number-lines %opt{ui_line_numbers_flags}
        echo -markup "{Information}line numbers enabled"
    } catch %{
        remove-highlighter window/line-numbers
        echo -markup "{Information}line numbers disabled"
    }
    trigger-user-hook ui-hl-changed
}

define-command -override ui-whitespaces-toggle -docstring 'toggle whitespaces' %{
    try %{
        add-highlighter window/whitespaces show-whitespaces %opt{ui_whitespaces_flags}
        echo -markup "{Information}whitespaces enabled"
    } catch %{
        remove-highlighter window/whitespaces
        echo -markup "{Information}whitespaces disabled"
    }
    trigger-user-hook ui-hl-changed
}

define-command -override ui-wrap-toggle -docstring 'toggle soft wrap' %{
    try %{
        add-highlighter window/wrap wrap %opt{ui_wrap_flags}
        echo -markup "{Information}soft wrap enabled"
    } catch %{
        remove-highlighter window/wrap
        echo -markup "{Information}soft wrap disabled"
    }
    trigger-user-hook ui-hl-changed
}

define-command -override ui-matching-toggle -docstring 'toggle matching char' %{
    try %{
        add-highlighter window/matching show-matching
        echo -markup "{Information}matching char enabled"
    } catch %{
        remove-highlighter window/matching
        echo -markup "{Information}matching char disabled"
    }
    trigger-user-hook ui-hl-changed
}

define-command -override ui-search-toggle -docstring 'toggle search' %{
    try %{
        add-highlighter window/search fill Normal  # dummy to throw error if enabled
        hook window -group ui-search NormalKey [/?*nN]|<a-[/?*nN]> %{ try %{
            add-highlighter -override window/search dynregex '%reg{/}' 0:Search
        }}
        hook window -group ui-search NormalKey <esc> %{ try %{
            remove-highlighter window/search
        }}
        echo -markup "{Information}search enabled"
    } catch %{
        remove-highlighter window/search
        remove-hooks window ui-search
        echo -markup "{Information}search disabled"
    }
    trigger-user-hook ui-hl-changed
}

define-command -override ui-trailing-spaces-toggle -docstring 'toggle trailing spaces' %{
    try %{
        add-highlighter window/trailing-spaces regex '\h+$' 0:TrailingSpace
        echo -markup "{Information}trailing spaces enabled"
    } catch %{
        remove-highlighter window/trailing-spaces
        echo -markup "{Information}trailing spaces disabled"
    }
    trigger-user-hook ui-hl-changed
}

define-command -override ui-todos-toggle -docstring 'toggle TODO comments' %{
    try %{
        add-highlighter window/todo-comments regex %opt{ui_todo_keywords_regex} 0:TodoComment
        echo -markup "{Information}TODO comments enabled"
    } catch %{
        remove-highlighter window/todo-comments
        echo -markup "{Information}TODO comments disabled"
    }
    trigger-user-hook ui-hl-changed
}

define-command -override ui-git-diff-toggle -docstring 'toggle git diff' %{
    try %{
        add-highlighter window/git-diff flag-lines Default git_diff_flags
        evaluate-commands %sh{
            cd "$(dirname "$kak_buffile")"
            git_dir="$(git rev-parse --show-toplevel 2>/dev/null)"
            [ -n "$git_dir" ] && echo "git update-diff"
            [ -n "$git_dir" ] && echo "hook window -group ui-git-diff BufWritePost .* %{ git update-diff }"
            [ -n "$git_dir" ] && echo "hook window -group ui-git-diff BufReload .* %{ git update-diff }"
        }
        echo -markup "{Information}git diff enabled"
    } catch %{
        remove-highlighter window/git-diff
        remove-hooks window ui-git-diff
        echo -markup "{Information}git diff disabled"
    }
    trigger-user-hook ui-hl-changed
}

define-command -override ui-lint-toggle -docstring 'toggle lint diagnostics' %{
    try %{
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
    } catch %{
        # copy-pasta from rc/tools/lint.kak
        remove-highlighter window/lint
        remove-hooks window lint-diagnostics
        echo -markup "{Information}lint diagnostics disabled"
    }
    trigger-user-hook ui-hl-changed
}

define-command -override ui-cursorline-toggle -docstring 'toggle cursor line' %{
    try %{
        add-highlighter window/cursorline line %val{cursor_line} CursorLine
        hook window -group ui-cursorline RawKey .* %{
            remove-highlighter window/cursorline
            add-highlighter window/cursorline line %val{cursor_line} CursorLine
        }
        echo -markup "{Information}cursor line enabled"
    } catch %{
        remove-highlighter window/cursorline
        remove-hooks window ui-cursorline
        echo -markup "{Information}cursor line disabled"
    }
    trigger-user-hook ui-hl-changed
}

define-command -override ui-cursorcolumn-toggle -docstring 'toggle cursor column' %{
    try %{
        add-highlighter window/cursorcolumn column %val{cursor_column} CursorColumn
        hook window -group ui-cursorcolumn RawKey .* %{
            remove-highlighter window/cursorcolumn
            add-highlighter window/cursorcolumn column %val{cursor_column} CursorColumn
        }
        echo -markup "{Information}cursor column enabled"
    } catch %{
        remove-highlighter window/cursorcolumn
        remove-hooks window ui-cursorcolumn
        echo -markup "{Information}cursor column disabled"
    }
    trigger-user-hook ui-hl-changed
}
