export PATH=~/.local/bin:$PATH

export EDITOR=emacs

if [[ $(uname --kernel-release) =~ -Microsoft$ ]];
then
    if [[ -z $(cmd.exe /c tasklist | grep vcxsrv.exe) ]];
    then
        /mnt/c/Program\ Files/VcXsrv/vcxsrv.exe -keyhook -multiwindow -wgl&!
    fi
    export DISPLAY=127.0.0.1:0.0
    export LIBGL_ALWAYS_REDIRECT=1
    invoke_batch() {
        cmd.exe /c "$@"
    }
    for batchFile in /mnt/m/tools/scripts/developer_machine_utils/*.bat; do
        filename=${batchFile##*/}
        if [[ $batchFile =~ "^/mnt/([a-z])/" ]]
        then
            windowsDrive=$match[1]
            windowsFullFilename=${batchFile/\/mnt\/${windowsDrive}/${windowsDrive}:}
            alias ${filename%.*}="invoke_batch ${windowsFullFilename}"
            alias sudo${filename%.*}="powershell.exe -Command \"Start-Process cmd -ArgumentList \\\'/c \\\"${windowsFullFilename} & pause\\\"\\\' -Verb RunAs\""
        else
            echo "Error: Batch file ${batchFile} is not visible outside WSL."
        fi
    done
elif [[ $(uname) == "Darwin" ]]; then
    alias emacs="/Applications/Emacs.app/Contents/MacOS/Emacs"
    export EDITOR="/Applications/Emacs.app/Contents/MacOS/Emacs"
else
    alias docker="sudo docker"
fi

if [[ $TERM == "dumb" ]]
then
  unsetopt zle
  unsetopt prompt_cr
  unsetopt prompt_subst
  unfunction precmd
  unfunction preexec
  export PS1='$ '
fi

VIRTUALENVWRAPPER_SCRIPT=/usr/share/virtualenvwrapper/virtualenvwrapper.sh
if [[ -e ${VIRTUALENVWRAPPER_SCRIPT} ]]; then
    export WORKON_HOME=$HOME/.virtualenvs
    export PROJECT_HOME=$HOME/Devel
    source ${VIRTUALENVWRAPPER_SCRIPT}
fi

export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000

setopt PROMPT_SUBST

autoload -U select-word-style
select-word-style bash

autoload -Uz vcs_info
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr ' unstaged'
zstyle ':vcs_info:*' check-for-staged-changes true
zstyle ':vcs_info:*' stagedstr ' staged'
zstyle ':vcs_info:*' actionformats \
    '%{%F{green}%}%b %{%f%F{red}%}%a%{%f%}'
zstyle ':vcs_info:*' formats       \
    '%{$fg[green]%}%b%c%u%{$reset_color%}'
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'

    autoload -Uz colors
colors

function precmd() {
    vcs_info
    print -rP "
%{%F{blue}%}%n%{%f%F{white}%}@%{%f%F{yellow}%}%m%{%f%F{white}%}:%{%f%F{cyan}%}${PWD/$HOME/~} ${vcs_info_msg_0_}"
}
PROMPT='> '

function setTitle()
{
    echo "\033];$*\07"
}
