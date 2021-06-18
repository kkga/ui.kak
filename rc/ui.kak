try %{ declare-user-mode ui }

define-command -override ui -docstring 'ui' %{
    enter-user-mode ui
}

# Options

set-face global Search +bu@MatchingChar
set-face global TrailingSpace Error
set-face global CursorLine "default,rgba:77777720"
set-face global CursorColumn "default,rgba:77777720"
set-face global WrapMarker "default,rgba:77777720"
set-face global TodoComment "yellow,default+rb"

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
map -docstring 'toggle search' global ui / ': ui-search-toggle<ret>'
map -docstring 'toggle TODO' global ui x ': ui-todos-toggle<ret>'
map -docstring 'toggle cursor line' global ui c ': ui-cursorline-toggle<ret>'
map -docstring 'toggle cursor column' global ui C ': ui-cursorcolumn-toggle<ret>'

# Commands

define-command -override -hidden ui-line-numbers-toggle -docstring 'toggle line numbers' %{
    try %{
        add-highlighter window/line-numbers number-lines %opt{ui_line_numbers_flags}
        echo -markup "{Information}line numbers enabled"
    } catch %{
        remove-highlighter window/line-numbers
        echo -markup "{Information}line numbers disabled"
    }
}

define-command -override -hidden ui-whitespaces-toggle -docstring 'toggle whitespaces' %{
    try %{
        add-highlighter window/whitespaces show-whitespaces %opt{ui_whitespaces_flags}
        echo -markup "{Information}whitespaces enabled"
    } catch %{
        remove-highlighter window/whitespaces
        echo -markup "{Information}whitespaces disabled"
    }
}

define-command -override -hidden ui-wrap-toggle -docstring 'toggle soft wrap' %{
    try %{
        add-highlighter window/wrap wrap %opt{ui_wrap_flags}
        echo -markup "{Information}soft wrap enabled"
    } catch %{
        remove-highlighter window/wrap
        echo -markup "{Information}soft wrap disabled"
    }
}

define-command -override -hidden ui-matching-toggle -docstring 'toggle matching char' %{
    try %{
        add-highlighter window/matching show-matching
        echo -markup "{Information}matching char enabled"
    } catch %{
        remove-highlighter window/matching
        echo -markup "{Information}matching char disabled"
    }
}

define-command -override -hidden ui-search-toggle -docstring 'toggle search' %{
    try %{
        add-highlighter window/search dynregex '%reg{/}' 0:Search
        hook window -group ui-search NormalKey [/?*nN]|<a-[/?*nN]> %{ try %{
            add-highlighter window/search dynregex '%reg{/}' 0:Search
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
}

define-command -override -hidden ui-trailing-spaces-toggle -docstring 'toggle trailing spaces' %{
    try %{
        add-highlighter window/trailing-spaces regex '\h+$' 0:TrailingSpace
        echo -markup "{Information}trailing spaces enabled"
    } catch %{
        remove-highlighter window/trailing-spaces
        echo -markup "{Information}trailing spaces disabled"
    }
}

define-command -override -hidden ui-todos-toggle -docstring 'toggle TODO comments' %{
    try %{
        add-highlighter window/todo-comments regex %opt{ui_todo_keywords_regex} 0:TodoComment
        echo -markup "{Information}TODO comments enabled"
    } catch %{
        remove-highlighter window/todo-comments
        echo -markup "{Information}TODO comments disabled"
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
        echo -markup "{Information}git diff enabled"
    } catch %{
        remove-highlighter window/git-diff
        remove-hooks window ui-git-diff
        echo -markup "{Information}git diff disabled"
    }
}

define-command -override -hidden ui-cursorline-toggle -docstring 'toggle cursor line' %{
    try %{
        add-highlighter window/cursorline line %val{cursor_line} CursorLine
        hook window -group cursorline NormalKey .* %{
            remove-highlighter window/cursorline
            add-highlighter window/cursorline line %val{cursor_line} CursorLine
        }
        hook window -group cursorline InsertKey .* %{
            remove-highlighter window/cursorline
            add-highlighter window/cursorline line %val{cursor_line} CursorLine
        }
        echo -markup "{Information}cursor line enabled"
    } catch %{
        remove-highlighter window/cursorline
        remove-hooks window cursorline
        echo -markup "{Information}cursor line disabled"
    }
}

define-command -override -hidden ui-cursorcolumn-toggle -docstring 'toggle cursor column' %{
    try %{
        add-highlighter window/cursorcolumn column %val{cursor_column} CursorColumn
        hook window -group cursorcolumn NormalKey .* %{
            remove-highlighter window/cursorcolumn
            add-highlighter window/cursorcolumn column %val{cursor_column} CursorColumn
        }
        hook window -group cursorcolumn InsertKey .* %{
            remove-highlighter window/cursorcolumn
            add-highlighter window/cursorcolumn column %val{cursor_column} CursorColumn
        }
        echo -markup "{Information}cursor column enabled"
    } catch %{
        remove-highlighter window/cursorcolumn
        remove-hooks window cursorcolumn
        echo -markup "{Information}cursor column disabled"
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
# [x] trailing space
# [x] hl search
#     find a smart way to toggle it
# [ ] lsp line flags
# [ ] lsp references
# [x] TODO/FIXME/XXX/NOTE
# [???] lint line flags
