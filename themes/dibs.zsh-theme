# ===================================================================================
# PROMPT
# ===================================================================================
# {

local current_date="%{$fg[green]%}%D%{$reset_color%}"
local dash="%{$fg[red]%}-%{$reset_color%}"
local current_time="%{$fg[magenta]%}%D{%I:%M:%S}%{$reset_color%}"
local username="%{$fg[yellow]%}%n%{$reset_color%}"
local at="%{$fg[red]%}@%{$reset_color%}"
local host="%{$fg[cyan]%}%m%{$reset_color%}"
local just_git_branch="%{$fg[white]%}[%{$fg[red]%}$(git branch 2>/dev/null | grep "^*" | colrm 1 2)%{$reset_color%}%{$fg[white]%}]%{$reset_color%}"
local arrow="%{$fg[blue]%}>%{$reset_color%}"
local current_dir="%{$fg[red]%}[%{$reset_color%}%{$fg[white]%}%~%{$fg[red]%}]%{$reset_color%}"
local dollar="%{$fg[blue]%}$%{$reset_color%}"

# PROMPT=$'\
# ┌  ${current_date} ${dash} ${current_time} ${username}${at}${host} ${just_git_branch}\
# └${arrow} ${current_dir} ${dollar} '

PROMPT=$'\
┌  ${current_date} ${dash} ${current_time} ${username}${at}${host} $(git_prompt_info)\
└${arrow} ${current_dir} ${dollar} '

    # https://github.com/magicmonty/bash-git-prompt
    # The command below shows a prompt which contains git branch and other git info
        # function git_prompt_command() 
        # {
        #     source ~/dibayendu/repositories/dotfiles/bash/gitprompt.sh
        # }
   
    ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[green]%}["
    ZSH_THEME_GIT_PROMPT_SUFFIX="]%{$reset_color%}"
    ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}*%{$fg[green]%}"
    ZSH_THEME_GIT_PROMPT_CLEAN=""
# }

# ===================================================================================
# directories shortcut using marks
# ===================================================================================
# {
    export MARKPATH=$HOME/.marks
    function jump { 
        cd -P $MARKPATH/$1 2>/dev/null || echo "No such mark: $1"
    }
    function mark { 
        mkdir -p $MARKPATH; ln -s $(pwd) $MARKPATH/$1
    }
    function unmark { 
        rm -i $MARKPATH/$1 
    }
    function marks {
        ls -l $MARKPATH | sed 's/  / /g' | cut -d' ' -f9- | sed 's/ -/ -/g' && echo
    }
# }
