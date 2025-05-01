fpath=(~/.zsh/completions $fpath)
autoload -Uz compinit
compinit

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME=""

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

HYPHEN_INSENSITIVE="true"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

plugins=(
	git
	aliases
	sudo
	zsh-autosuggestions
	zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

git_branch() {
    # -- Finds and outputs the current branch name by parsing the list of
    #    all branches
    # -- Current branch is identified by an asterisk at the beginning
    # -- If not in a Git repository, error message goes to /dev/null and
    #    no output is produced
    git branch --no-color 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

git_status() {
    # Outputs a series of indicators based on the status of the
    # working directory:
    # + changes are staged and ready to commit
    # ! unstaged changes are present
    # ? untracked files are present
    # S changes have been stashed
    # P local commits need to be pushed to the remote
    local gitstatus="$(git status --porcelain 2>/dev/null)"
    local output=''
    [[ -n $(egrep '^[MADRC]' <<<"$gitstatus") ]] && output="$output+"
    [[ -n $(egrep '^.[MD]' <<<"$gitstatus") ]] && output="$output!"
    [[ -n $(egrep '^\?\?' <<<"$gitstatus") ]] && output="$output?"
    [[ -n $(git stash list) ]] && output="${output}S"
    [[ -n $(git unpushed) ]] && output="${output}P"
    [[ -n $output ]] && output="|$output"  # separate from branch name
    echo $output
}

git_color() {
    # Receives output of git_status as argument; produces appropriate color
    # code based on status of working directory:
    # - White if everything is clean
    # - Green if all changes are staged
    # - Red if there are uncommitted changes with nothing staged
    # - Yellow if there are both staged and unstaged changes
    local staged dirty
    [[ $1 == *+* ]] && staged=yes
    [[ $1 == *[\!\?]* ]] && dirty=yes
    if [[ -n $staged ]] && [[ -n $dirty ]]; then
        echo -e '\033[1;33m'  # bold yellow
    elif [[ -n $staged ]]; then
        echo -e '\033[1;32m'  # bold green
    elif [[ -n $dirty ]]; then
        echo -e '\033[1;31m'  # bold red
    else
        echo -e '\033[1;37m'  # bold white
    fi
}

git_prompt() {
    local branch=$(git_branch)
    if [[ -n $branch ]]; then
        local state=$(git_status)
        local color=$(git_color $state)
        echo -e "\x01$color\x02[$branch$state]\x01\033[00m\x02"
    fi
}

PROMPT='%* %{[01;32m%}bill%{[00m%}:%{[01;34m%}%~$(git_prompt)%{[00m%}
$ '

unalias rm 2>/dev/null
rm() {
    if [ $# -eq 0 ]; then
        echo -e "\e[31mrm: missing operand\e[0m"
        return 1
    fi

    local missing=0
    for f in "$@"; do
        # Skip options like -r, -f, etc
        if [[ "$f" == -* ]]; then
            continue
        fi
        if [ ! -e "$f" ]; then
            echo -e "\e[33mrm: cannot remove '$f': No such file or directory\e[0m"
            missing=1
        fi
    done

    command rm --verbose "$@"

    return $missing
}

alias edalias="nvim $ZSH_CUSTOM/aliases.zsh"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

bindkey '^[e' autosuggest-accept

# virtualenvwrapper setup
export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=$(command -v python3)
export VIRTUALENVWRAPPER_VIRTUALENV=$(command -v virtualenv)
source $HOME/.local/share/pipx/venvs/virtualenvwrapper/bin/virtualenvwrapper.sh
