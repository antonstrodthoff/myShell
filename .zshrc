#Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# set up fzf keybindings
eval "$(fzf --zsh)"

# load powerlevel10k theme for alacritty and check if it
# has been configured run `p10k configure` or edit ~/.p10k.zsh.
source /usr/local/share/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# load zsh-autosuggestions package and set highlight color
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=4'
bindkey '§' autosuggest-accept

# load zsh-syntax-highlighting package and set highlight color
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=3'

# set an alias for eza so i can use it with the ls command
alias ls="eza --color=always --long --group-directories-first --sort=extension --no-filesize --icons=always --no-time --no-user --no-permissions"
alias tree="ls -RL 2"
alias list="\ls"

# a few personal shortcuts
alias domsky='cd ~/Documents/Arbeit/Domsky/New\ App/iDomWay; open iDomWay.xcworkspace; git pull; open -u https://mail.ls-it-media.de/owa; open -u https://track.toggl.com/timer; open -u https://chatgpt.com/'
alias master='cd ~/Documents/Uni/Masterarbeit; code ./; git pull'
alias pi='ssh anton@raspberrypi'
alias cat='cat -n'
alias hexdump='hexdump -vC'

