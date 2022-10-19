# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/home/elian/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
 ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-z sudo docker docker-compose tmux)

source $ZSH/oh-my-zsh.sh

bindkey '^ ' autosuggest-accept

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias ide="bash ~/ide.sh"
alias up="~/Documents/Trabajo/OneEasyStopNew/up.sh"
alias server="~/Documents/Trabajo/OneEasyStopNew/server.sh"
alias cloud_db="/home/elian/Documents/Trabajo/Hubster/scripts/cloud_db"
alias cat='/bin/bat'
alias catn='/bin/cat'
alias catnl='/bin/bat --paging=never'

alias ll='lsd -lh --group-dirs=first'
alias la='lsd -a --group-dirs=first'
alias l='lsd --group-dirs=first'
alias lla='lsd -lha --group-dirs=first'
alias ls='lsd --group-dirs=first'
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
# export HIPS_DB_NAME=hips2
# export HIPS_DB_USERNAME=elian
# export HIPS_DB_PASSWORD=1007
export PATH=$PATH:/var/lib/flatpak/app
export PATH=$PATH:/home/elian/.local/bin

#ruby with rvm
export PATH=$PATH:/home/elian/.rvm/gems/ruby-2.7.1/bin:/home/elian/.rvm/gems/ruby-2.7.1@global/bin:/usr/share/rvm/rubies/ruby-2.7.1/bin:/usr/share/rvm/bin
export GEM_PATH=/home/elian/.rvm/gems/ruby-2.7.1:/home/elian/.rvm/gems/ruby-2.7.1@global
export GEM_HOME=/home/elian/.rvm/gems/ruby-2.7.1

#node and npm
# export NPM_CONFIG_PREFIX=~/.npm-global
# export PATH=$PATH:Documentos/2020-2/Ingesoft2/hips-project/liquibase/
# export LIQUIBASE_HOME=Documentos/2020-2/Ingesoft2/hips-project/liquibase/
# alias hips=Documentos/2020-2/Ingesoft2/hips-project/
# alias 21=~/Documentos/2021-1/
alias v=lvim
alias k="/snap/bin/kubectl"
export JWT_SECRET=secreto
#source $HOME/.cargo/env
# alias exercism=~/snap/exercism/5/exercism
fpath=(~/.zsh.d/ $fpath)
export EDITOR=lvim
# export SONAR_TOKEN=0905eecc18d2e9ad340cb9803fd5db280ac881e9
#bindkey -v
# setxkbmap -layout us -variant dvorak
# setxkbmap us
fpath=(~/.zsh.d/ $fpath)
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^[[A" history-beginning-search-backward-end
bindkey "^[[B" history-beginning-search-forward-end

#fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
source /etc/zsh/zprofile
# export _JAVA_AWT_WM_NONREPARENTING=1 #java application fix GUI problems
#hubster project
export GCLOUD_PROJECT="hubster-305121"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
