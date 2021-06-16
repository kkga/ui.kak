declare-option str ui_cursorline_bg rgba:7F7F7F16

try %{ declare-user-mode ui }

define-command -override ui -docstring 'ui' %{
    enter-user-mode ui
}

# Mappings

map -docstring 'toggle cursor line' global ui c ': ui-cursorline-toggle<ret>'
map -docstring 'toggle line numbers' global ui l ': ui-line-numbers-toggle<ret>'
map -docstring 'toggle whitespaces' global ui s ': ui-whitespaces-toggle<ret>'
map -docstring 'toggle wrap' global ui w ': ui-wrap-toggle<ret>'
map -docstring 'toggle matching' global ui m ': ui-matching-toggle<ret>'

# Commands

define-command -override -hidden ui-cursorline-toggle -docstring 'toggle cursor line' %{
    try %{
        set-face global CursorLine "default,%opt{ui_cursorline_bg}"
        # add-highlighter window/cursorline fill Normal  # dummy to throw error if enabled
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

define-command -override -hidden ui-line-numbers-toggle -docstring 'toggle line numbers' %{
    try %{
        add-highlighter global/line-numbers number-lines -hlcursor
    } catch %{
        remove-highlighter global/line-numbers
    }
}

define-command -override -hidden ui-whitespaces-toggle -docstring 'toggle whitespaces' %{
    try %{
        add-highlighter window/whitespaces show-whitespaces -tab "»" -lf "↲" -nbsp "␣" -spc "·"
    } catch %{
        remove-highlighter window/whitespaces
    }
}

define-command -override -hidden ui-wrap-toggle -docstring 'toggle soft wrap' %{
    try %{
        add-highlighter window/wrap wrap -marker "…"
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

# git diff
# hl search
# relative number
# spell
# cursor column
#


