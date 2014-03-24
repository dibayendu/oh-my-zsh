#!/bin/sh

# assume the gitstatus.py is in the same directory as this script
# code thanks to http://stackoverflow.com/questions/59895
if [ -z "${__GIT_PROMPT_DIR}" ]; then
  SOURCE="${BASH_SOURCE[0]}"
  while [ -h "${SOURCE}" ]; do
    DIR="$( cd -P "$( dirname "${SOURCE}" )" && pwd )"
    SOURCE="$(readlink "${SOURCE}")"
    [[ $SOURCE != /* ]] && SOURCE="${DIR}/${SOURCE}"
  done
  __GIT_PROMPT_DIR="$( cd -P "$( dirname "${SOURCE}" )" && pwd )"
fi

function git_prompt_config()
{
  # Colors
  ResetColor="%{$reset_color%}"            # Text reset

  # Bold
  local BoldGreen="%{$fg_bold[green]%}"    # Green
  local BoldBlue="%{$fg_bold[blue]%}"     # Blue

  # High Intensty
  local IntenseBlack="%{$fg_no_bold[black]%}" # Grey

  # Bold High Intensty
  local Magenta="%{$fg_no_bold[magenta]%}"      # Purple

  # Regular Colors
  local Yellow="%{$fg_no_bold[yellow]%}"
  local White="%{$fg_no_bold[white]%}"
  local Red="%{$fg_no_bold[red]%}"
  Blue="%{$fg_no_bold[blue]%}]"

  # Default values for the appearance of the prompt. Configure at will.
  GIT_PROMPT_PREFIX="["
  GIT_PROMPT_SUFFIX="]"
  GIT_PROMPT_SEPARATOR="|"
  GIT_PROMPT_BRANCH="${Magenta}"
  GIT_PROMPT_STAGED="${Red}● "
  GIT_PROMPT_CONFLICTS="${Red}✖ "
  GIT_PROMPT_CHANGED="${Blue}✚ "
  GIT_PROMPT_REMOTE=" "
  GIT_PROMPT_UNTRACKED="…"
  GIT_PROMPT_CLEAN="${BoldGreen}✔"

  # Various variables you might want for your PS1 prompt instead
  local Time12a="%T"
  # local Time12a="(\$(date +%H:%M:%S))"
  # local Time12a="(\@))"
  local PathShort="%~"

  if [ "x${GIT_PROMPT_START}" == "x" ]; then
    PROMPT_START="${Yellow}${PathShort}${ResetColor}"
  else
    PROMPT_START="${GIT_PROMPT_START}"
  fi

  if [ "x${GIT_PROMPT_END}" == "x" ]; then
    PROMPT_END=" \n${White}${Time12a}${ResetColor} $ "
  else
    PROMPT_END="${GIT_PROMPT_END}"
  fi

EMPTY_PROMPT=$'\
┌  ${current_date} ${dash} ${current_time} ${username}${at}${host} $(git_prompt_info)\
└${arrow} ${current_dir} ${dollar} '

  EMPTY_PROMPT="$NewLine$Purple\[\342\224\214\342\224\200\]\$([[ \$? != 0 ]] && echo \"$Color_Off [$Color_Off$On_Red\[\342\234\227\] $Last_Command$Color_Off]\") $Cyan$Date $Red- $Purple$Time12h $Yellow$User$BRed@$Green$Host $Cyan[$Color_Off$On_Black\$(git branch 2>/dev/null | grep '^*' | colrm 1 2)$Cyan]$NewLine$Purple\[\342\224\224\]> $Red[$Color_Off$On_Blue$PathShort$Red] $Color_Off\$ "

  # fetch remote revisions every other $GIT_PROMPT_FETCH_TIMEOUT (default 5) minutes
  GIT_PROMPT_FETCH_TIMEOUT=${1-5}
  if [ "x$__GIT_STATUS_CMD" == "x" ]
  then
    __GIT_STATUS_CMD="${__GIT_PROMPT_DIR:-${HOME}/.bash}/gitstatus.py"
  fi
}

function setGitPrompt() {

  local GIT_PROMPT_PREFIX
  local GIT_PROMPT_SUFFIX
  local GIT_PROMPT_SEPARATOR
  local GIT_PROMPT_BRANCH
  local GIT_PROMPT_STAGED
  local GIT_PROMPT_CONFLICTS
  local GIT_PROMPT_CHANGED
  local GIT_PROMPT_REMOTE
  local GIT_PROMPT_UNTRACKED
  local GIT_PROMPT_CLEAN
  local PROMPT_START
  local PROMPT_END
  local EMPTY_PROMPT
  local ResetColor
  local Blue
  local GIT_PROMPT_FETCH_TIMEOUT
  local __GIT_STATUS_CMD

  git_prompt_config

  local repo=`git rev-parse --show-toplevel 2> /dev/null`
  if [[ ! -e "${repo}" ]]; then
    PS1="${EMPTY_PROMPT}"
    return
  fi

  local FETCH_HEAD="${repo}/.git/FETCH_HEAD"
  # Fech repo if local is stale for more than $GIT_FETCH_TIMEOUT minutes
  if [[ ! -e "${FETCH_HEAD}"  ||  -e `find ${FETCH_HEAD} -mmin +${GIT_PROMPT_FETCH_TIMEOUT}` ]]
  then
    [[ -n $(git remote show) ]] && git fetch --quiet
  fi

  local -a GitStatus
  GitStatus=($("${__GIT_STATUS_CMD}" 2>/dev/null))

  local GIT_BRANCH=${GitStatus[0]}
  local GIT_REMOTE=${GitStatus[1]}
  if [[ "." == "$GIT_REMOTE" ]]; then
    unset GIT_REMOTE
  fi
  local GIT_STAGED=${GitStatus[2]}
  local GIT_CONFLICTS=${GitStatus[3]}
  local GIT_CHANGED=${GitStatus[4]}
  local GIT_UNTRACKED=${GitStatus[5]}
  local GIT_CLEAN=${GitStatus[6]}

  if [[ -n "${GitStatus}" ]]; then
    local STATUS=" ${GIT_PROMPT_PREFIX}${GIT_PROMPT_BRANCH}${GIT_BRANCH}${ResetColor}"

    if [[ -n "${GIT_REMOTE}" ]]; then
      STATUS="${STATUS}${GIT_PROMPT_REMOTE}${GIT_REMOTE}${ResetColor}"
    fi

    STATUS="${STATUS}${GIT_PROMPT_SEPARATOR}"
    if [ "${GIT_STAGED}" -ne "0" ]; then
      STATUS="${STATUS}${GIT_PROMPT_STAGED}${GIT_STAGED}${ResetColor}"
    fi

    if [ "${GIT_CONFLICTS}" -ne "0" ]; then
      STATUS="${STATUS}${GIT_PROMPT_CONFLICTS}${GIT_CONFLICTS}${ResetColor}"
    fi
    
    if [ "${GIT_CHANGED}" -ne "0" ]; then
      STATUS="${STATUS}${GIT_PROMPT_CHANGED}${GIT_CHANGED}${ResetColor}"
    fi
    
    if [ "${GIT_UNTRACKED}" -ne "0" ]; then
      STATUS="${STATUS}${GIT_PROMPT_UNTRACKED}${GIT_UNTRACKED}${ResetColor}"
    fi
    
    if [ "${GIT_CLEAN}" -eq "1" ]; then
      STATUS="${STATUS}${GIT_PROMPT_CLEAN}"
    fi
    
    STATUS="${STATUS}${ResetColor}${GIT_PROMPT_SUFFIX}"

    PS1="$NewLine$Purple\[\342\224\214\342\224\200\]\$([[ \$? != 0 ]] && echo \"$Color_Off [$Color_Off$On_Red\[\342\234\227\] $Last_Command$Color_Off]\") $Cyan$Date $Red- $Purple$Time12h $Yellow$User$BRed@$Green$Host $Color_Off${STATUS}$Color_Off$NewLine$Purple\[\342\224\224\]> $Red[$Color_Off$On_Blue$PathShort$Red] $Color_Off\$ "

    # PS1="${PROMPT_START}${STATUS}${PROMPT_END}"
    if [[ -n "${VIRTUAL_ENV}" ]]; then
      PS1="${Blue}($(basename "${VIRTUAL_ENV}"))${ResetColor} ${PS1}"
    fi

  else
    PS1="${EMPTY_PROMPT}"
  fi
}

if [ -z "$PROMPT_COMMAND" ]; then
  PROMPT_COMMAND=setGitPrompt
else
  # before the setGitPrompt, the echo is for returning the current directory.
  # this is cause when a new tab needs to be opened, it should start from the previous directory
  PROMPT_COMMAND='echo -ne "\033]0;${PWD}\007";setGitPrompt'
fi
