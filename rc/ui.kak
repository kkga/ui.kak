declare-option str ui_cursorline_bg 'rgba:005F5F40'
declare-option str ui_cursorcolumn_bg 'rgba:005F5F40'


try %{ declare-user-mode ui }

define-command -override ui -docstring 'ui' %{
    enter-user-mode ui
}

# Mappings

map -docstring 'toggle cursor line' global ui c ': ui-cursorline-toggle<ret>'
map -docstring 'toggle cursor column' global ui C ': ui-cursorcolumn-toggle<ret>'
map -docstring 'toggle line numbers' global ui l ': ui-line-numbers-toggle<ret>'
map -docstring 'toggle whitespaces' global ui s ': ui-whitespaces-toggle<ret>'
map -docstring 'toggle wrap' global ui w ': ui-wrap-toggle<ret>'
map -docstring 'toggle matching' global ui m ': ui-matching-toggle<ret>'

# Commands

define-command -override -hidden ui-cursorline-toggle -docstring 'toggle cursor line' %{
    try %{
        set-face global CursorLine "default,%opt{ui_cursorline_bg}"
        add-highlighter global/cursorline line %val{cursor_line} CursorLine
        hook global -group cursorline NormalKey .* %{
            remove-highlighter global/cursorline
            add-highlighter global/cursorline line %val{cursor_line} CursorLine
        }
        hook global -group cursorline InsertKey .* %{
            remove-highlighter global/cursorline
            add-highlighter global/cursorline line %val{cursor_line} CursorLine
        }
    } catch %{
        remove-highlighter global/cursorline
        remove-hooks global cursorline
    }
}

define-command -override -hidden ui-cursorcolumn-toggle -docstring 'toggle cursor column' %{
    try %{
        set-face global CursorColumn "default,%opt{ui_cursorcolumn_bg}"
        add-highlighter global/cursorcolumn column %val{cursor_column} CursorColumn
        hook global -group cursorcolumn NormalKey .* %{
            remove-highlighter global/cursorcolumn
            add-highlighter global/cursorcolumn column %val{cursor_column} CursorColumn
        }
        hook global -group cursorcolumn InsertKey .* %{
            remove-highlighter global/cursorcolumn
            add-highlighter global/cursorcolumn column %val{cursor_column} CursorColumn
        }
    } catch %{
        remove-highlighter global/cursorcolumn
        remove-hooks global cursorcolumn
    }
}

define-command -override -hidden ui-line-numbers-toggle -docstring 'toggle line numbers' %{
    try %{
        add-highlighter global/line-numbers number-lines -hlcursor
    } catch %{
        remove-highlighter global/line-numbers
    }
}

define-command -override -hidden ui-whitespaces-toggle -docstring 'toggle whitespaces' %{
    try %{
        add-highlighter global/whitespaces show-whitespaces
    } catch %{
        remove-highlighter global/whitespaces
    }
}

define-command -override -hidden ui-wrap-toggle -docstring 'toggle soft wrap' %{
    try %{
        add-highlighter global/wrap wrap -word
    } catch %{
        remove-highlighter global/wrap
    }
}

define-command -override -hidden ui-matching-toggle -docstring 'toggle matching' %{
    try %{
        add-highlighter global/matching show-matching
    } catch %{
        remove-highlighter global/matching
    }
}

# git diff
# hl search
# relative number
# spell
# cursor column
#


