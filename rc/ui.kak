try %{ declare-user-mode ui }

define-command -override ui -docstring 'ui' %{
    enter-user-mode ui
}

# Options

set-face global search 'default,blue+bi'

declare-option str ui_cursorline_bg 'rgba:005F5F40'
declare-option str ui_cursorcolumn_bg 'rgba:005F5F40'
declare-option str-list ui_line_numbers_flags

# Mappings

map -docstring 'toggle cursor line' global ui c ': ui-cursorline-toggle<ret>'
map -docstring 'toggle cursor column' global ui C ': ui-cursorcolumn-toggle<ret>'
map -docstring 'toggle line numbers' global ui l ': ui-line-numbers-toggle<ret>'
map -docstring 'toggle relative line numbers' global ui r ': ui-line-numbers-relative-toggle<ret>'
map -docstring 'toggle whitespaces' global ui w ': ui-whitespaces-toggle<ret>'
map -docstring 'toggle wrap' global ui w ': ui-wrap-toggle<ret>'
map -docstring 'toggle matching' global ui m ': ui-matching-toggle<ret>'
map -docstring 'toggle git diff' global ui d ': ui-git-diff-toggle<ret>'
map -docstring 'toggle search' global ui s ': ui-search-toggle<ret>'

# Commands

define-command -override -hidden ui-line-numbers-toggle -docstring 'toggle line numbers' %{
    try %{
        add-highlighter window/line-numbers number-lines %opt{ui_line_numbers_flags}
    } catch %{
        remove-highlighter window/line-numbers
    }
}

define-command -override -hidden ui-line-numbers-relative-toggle -docstring 'toggle relative line numbers' %{
    try %{
        add-highlighter window/line-numbers number-lines -relative
    } catch %{
        remove-highlighter window/line-numbers
    }
}

define-command -override -hidden ui-whitespaces-toggle -docstring 'toggle whitespaces' %{
    try %{
        add-highlighter window/whitespaces show-whitespaces
    } catch %{
        remove-highlighter window/whitespaces
    }
}

define-command -override -hidden ui-wrap-toggle -docstring 'toggle soft wrap' %{
    try %{
        add-highlighter window/wrap wrap -word
    } catch %{
        remove-highlighter window/wrap
    }
}

define-command -override -hidden ui-matching-toggle -docstring 'toggle matching' %{
    try %{
        add-highlighter window/matching show-matching
    } catch %{
        remove-highlighter window/matching
    }
}

define-command -override -hidden ui-search-toggle -docstring 'toggle search' %{
    try %{
        add-highlighter window/search dynregex '%reg{/}' 0:search
    } catch %{
        remove-highlighter window/search
    }
}

define-command -override -hidden ui-git-diff-toggle -docstring 'toggle git diff' %{
    try %{
        git update-diff
        add-highlighter window/git-diff flag-lines Default git_diff_flags
        hook window -group ui-git-diff BufWritePost .* %{
            git update-diff
        }
        hook window -group ui-git-diff BufReload .* %{
            git update-diff
        }
    } catch %{
        remove-highlighter window/git-diff
        remove-hooks window ui-git-diff
    }
}

define-command -override -hidden ui-cursorline-toggle -docstring 'toggle cursor line' %{
    try %{
        set-face window CursorLine "default,%opt{ui_cursorline_bg}"
        add-highlighter window/cursorline line %val{cursor_line} CursorLine
        hook window -group cursorline NormalKey .* %{
            remove-highlighter window/cursorline
            add-highlighter window/cursorline line %val{cursor_line} CursorLine
        }
        hook window -group cursorline InsertKey .* %{
            remove-highlighter window/cursorline
            add-highlighter window/cursorline line %val{cursor_line} CursorLine
        }
    } catch %{
        remove-highlighter window/cursorline
        remove-hooks window cursorline
    }
}

define-command -override -hidden ui-cursorcolumn-toggle -docstring 'toggle cursor column' %{
    try %{
        set-face window CursorColumn "default,%opt{ui_cursorcolumn_bg}"
        add-highlighter window/cursorcolumn column %val{cursor_column} CursorColumn
        hook window -group cursorcolumn NormalKey .* %{
            remove-highlighter window/cursorcolumn
            add-highlighter window/cursorcolumn column %val{cursor_column} CursorColumn
        }
        hook window -group cursorcolumn InsertKey .* %{
            remove-highlighter window/cursorcolumn
            add-highlighter window/cursorcolumn column %val{cursor_column} CursorColumn
        }
    } catch %{
        remove-highlighter window/cursorcolumn
        remove-hooks window cursorcolumn
    }
}

# define-command -override -hidden ui-lint-diagnostics-toggle -docstring 'toggle lint diagnostics' %{
#     try %{
#         lint
#     } catch %{
#         remove-highlighter window/lint
#         remove-hooks window lint-diagnostics
#     }
# }

# define-command lint-hide-diagnostics -docstring "Hide line markers and disable automatic diagnostic displaying" %{
#     remove-highlighter window/lint
#     remove-hooks window lint-diagnostics
# }
# [x] git diff
# [x] relative number
# [x] cursor column
# [ ] lsp line flags
# [ ] trailing space
# [ ] TODO/FIXME/XXX/NOTE
# [???] lint line flags
# hl search
