# Lines configured by zsh-newuser-install
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt autocd extendedglob
bindkey -e
# End of lines configured by zsh-newuser-install


# The following lines were added by compinstall
zstyle :compinstall filename '$HOME/.zshrc'
autoload -Uz compinit
compinit
# End of lines added by compinstall

autoload -U colors && colors

# Use a decent prompt
PS1="%B%{$fg[red]%}[%{$fg[green]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b"

# updates the window title.
function xtitle () {
    builtin print -n -- "\e]0;$@\a"
}

function precmd () {
    xtitle "$(print -P $USER@$HOST '[%~]')"
}
# end of updates the window title.

# Welcome alias
alias welcome="sudo /usr/local/bin/ld-entry -i"
