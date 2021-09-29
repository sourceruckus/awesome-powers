# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory extendedglob nomatch notify
unsetopt autocd beep
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '~/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Set/unset shell options
setopt pushdtohome
setopt globdots
setopt correct
setopt correctall
setopt autolist
setopt longlistjobs
setopt histignoredups
setopt clobber
setopt autoremoveslash
setopt autocontinue
unsetopt bgnice

#setopt autoresume
#setopt rcquotes
#setopt pushdignoredups
#setopt printeightbit
#unsetopt autoparamslash

# /etc/zprofile sources /etc/profile.d files which sets LANG...  arg
#
#unset LANG
LANG=C
export LANG


# set up limits
unlimit
if [ $USERNAME = "root" ]; then
    # we don't want core files for root
    limit core 0
else
    # and let's use a smaller stack size for normal users
    # NOTE: the default zshrc did this...
    limit stack 8192
fi
limit -s

# set umask
#umask 022

# set up aliases
alias mv='nocorrect mv'       # no spelling correction on mv
alias cp='nocorrect cp'       # no spelling correction on cp
alias mkdir='nocorrect mkdir' # no spelling correction on mkdir
alias touch='nocorrect touch' # no spelling correction on touch
alias j=jobs
#alias pu=pushd
#alias po=popd
alias d='dirs -v'
alias h=history
#alias grep='nocorrect egrep --color=auto'
alias grep='nocorrect grep -E --color=auto'
alias ls='ls --color=auto -FC'
#alias ec='emacsclient -n'
#alias vi='vim -N'
alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'

# Global aliases -- These do not have to be
# at the beginning of the command line.
alias -g L='|less'
alias -g M='|more'
alias -g H='|head'
alias -g T='|tail'
alias -g Tf='|tail -f'


# Set prompts
# the left prompt is color coded
# dark cyan = username
# bright yellow = username (warning, you are root!!)
# bright green = hostname (don't forget which system you're on!)
if [ $USERNAME = "root" ]; then
    PROMPT=$'\n%{\e[0;32m%}%D{%Y-%m-%d %H:%M:%S} dev=%y ret=%? hist=%! \n[%{\e[1;33m%}%n@%{\e[1;32m%}%m%{\e[0;32m%}]%# %{\e[0m%}'
else
    PROMPT=$'\n%{\e[0;32m%}%D{%Y-%m-%d %H:%M:%S} dev=%y ret=%? hist=%! \n[%{\e[0;36m%}%n@%{\e[1;32m%}%m%{\e[0;32m%}]%# %{\e[0m%}'
fi

RPROMPT=$' %{\e[0;32m%}%~%{\e[0m%}'

watch=(notme)                   # watch for everybody but me
#LOGCHECK=300                    # check every 5 min for login/logout activity
WATCHFMT='%n %a %l from %m at %t.'



# Autoload zsh modules when they are referenced
#
#zmodload -a zsh/stat stat
#zmodload -a zsh/zpty zpty
#zmodload -a zsh/zprof zprof
#zmodload -ap zsh/mapfile mapfile

bindkey '^Xa' _expand_alias

bindkey ' ' magic-space    # also do history expansion on space
#bindkey '^I' complete-word # complete on tab, leave expansion to _expand

if [ "$TERM" = "linux" ]; then
    # home/end on terminal
    bindkey '^[[1~' beginning-of-line
    bindkey '^[[4~' end-of-line
    
    # Ctrl-left/right on terminal
    #bindkey '^[[D' backward-word
    #bindkey '^[[C' forward-word
    
elif [ "$TERM" = "xterm" ]; then
    # home/end in xterm
    bindkey '^[[H' beginning-of-line
    bindkey '^[[F' end-of-line
    
    # home/end in gnome-terminal (LSP3)
    #bindkey '^[OH' beginning-of-line
    #bindkey '^[OF' end-of-line
    
    # Ctrl-left/right in xterm
    bindkey '^[[1;5D' backward-word
    bindkey '^[[1;5C' forward-word
    
    # Ctrl-left/right in gnome-terminal (LSP3)
    #bindkey '^[[5D' backward-word
    #bindkey '^[[5C' forward-word
fi 

# delete key
bindkey '^[[3~' delete-char

# Esc-left/right to jump back/forward by word
bindkey '^[^[[D' backward-word
bindkey '^[^[[C' forward-word


# set DISPLAY equal to whatever machine we're logging in from if we're
# in X and if DISPLAY isn't already set.
if [ "$TERM" = "linux" ]; then
    unset DISPLAY
elif [ -z "$DISPLAY" ]; then
    DISPLAY=$(who -m | awk '{print $NF}')
    DISPLAY=${DISPLAY#\(}
    DISPLAY=${DISPLAY%\)}
    DISPLAY+=:0.0
    export DISPLAY
fi

export LINGUAS=English
#export MAILCHECK=300
export PAGER='less'
#export MAIL=/var/spool/mail/$USERNAME
#export LESS=-cx3MR
#export LESS=-cMR
export LESS=-MRFSX
#export SHELL=`which zsh`

#export CVS_RSH=ssh
#export RSYNC_RSH=ssh
#export RSH=ssh
export EDITOR=emacs

export CPUCOUNT=`grep processor /proc/cpuinfo | wc -l`


# this function will update the titlebar of your terminal with your
# current working directory prior to displaying each command prompt
#
# FIXME: would be nice if we could get this undone upon
#        logout... zshexit doesn't seem to do it. oh well.
#
precmd()
{
    [[ -t 1 ]] || return
    case $TERM in
	*xterm*|rxvt|kterm|Eterm)
	    print -Pn "\e]2;%n@%m:%~\a"
	    ;;
    esac
}

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# time for our user specific settings
if [ -f ~/.zshrc_user ]; then
    echo ".zshrc_user"
    . ~/.zshrc_user
fi
