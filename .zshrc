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
source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# load zsh-autosuggestions package and set highlight color
# source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/Cellar/zsh-autosuggestions/0.7.1/share/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=4'
bindkey '§' autosuggest-accept

# load zsh-syntax-highlighting package and set highlight color
# source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /opt/homebrew/Cellar/zsh-syntax-highlighting/0.8.0/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=3'

# set an alias for eza so i can use it with the ls command
alias ls="eza --color=always --long --group-directories-first --sort=extension --no-filesize --icons=always --no-time --no-user --no-permissions"
alias tree="ls -RL 2"
alias list="\ls"
alias pi="ssh anton@raspberrypi"
alias cat="cat -n"
alias hexdump="hexdump -vC"
alias activate="source .venv/bin/activate"
alias setup="nvim ~/.zshrc"
alias reload="source ~/.zshrc && source ~/.zprofile && echo '\n   Reloaded .zshrc and .zprofile!'"
alias back="cd .. && ls"
alias cog="ssh anton@cpln1"
alias plot="python plotter.py"
alias spot="spotify_player"

alias home="clear && cd ~"
alias docs="clear && cd ~/Documents/"
alias uni="clear && cd ~/Documents/Uni/"
alias apps="clear && cd /Applications/"
alias desk="clear && cd ~/Desktop/"
alias down="clear && cd ~/Downloads/"
alias finder="open ./"
alias domsky="clear && cd ~/Documents/Arbeit/Domsky/New\ App/iDomWay"
alias master="clear && cd ~/Documents/Uni/Masterarbeit"
alias model="clear && cd ~/Documents/Uni/Masterarbeit/Model/Numerically/"

# Adds function "trash file.txt" that moves file.txt to ~/.Trash/ instead of removing it.
function trash {
    mv "$@" ~/.Trash
    echo "Moved to Trash: $*"
}

# show: open the most recently modified PDF in ~/test
show() {
  local dir="$HOME/Documents/Uni/Masterarbeit/Plots/Numerically in C"
  local opener files

  # opener lookup
  if   command -v open     &>/dev/null; then opener=open
  elif command -v xdg-open &>/dev/null; then opener=xdg-open
  else
    echo "No PDF opener found." >&2
    return 1
  fi

  # glob qualifiers: (.) = files only, (om[1]) = sort by mtime, first entry
  setopt null_glob
  files=( "$dir"/*.pdf(om[1]) )
  if (( ${#files} == 0 )); then
    echo "No PDFs in $dir"
    return 1
  fi

  echo "Opening ${files[1]}"
  "$opener" "${files[1]}"
}

# This function creates a new command "run" that compiles and executes a .c file
# If no .c files are specified it automatically execeutes the first .c file in the current folder
# Flags behind the "run" command are passed to the execution of the compiled c file
function run() {
  local src bin
  local exec_args=()

  # Determine source vs. exec-flags
  if (( $# == 0 )) || [[ $1 == -* ]]; then
    # no args or first arg is a flag → default to first .c in lex order
    setopt localoptions nullglob
    local cfiles=( *.c )
    (( ${#cfiles[@]} )) || {
      echo "Error: no .c files found in $(pwd)" >&2
      return 1
    }
    src=${cfiles[1]}
    exec_args=( "$@" )
  else
    # first arg isn’t a flag → should be your .c
    src=$1; shift
    exec_args=( "$@" )
  fi

  # sanity check
  [[ $src == *.c && -f $src ]] || {
    echo "Error: '$src' is not a valid .c file" >&2
    return 1
  }

  bin=${src%.c}

  # compile
  gcc "$src" -o "$bin" || {
    echo "Compile failed for $src" >&2
    return 1
  }

  # execute with whatever flags you passed
  ./"$bin" "${exec_args[@]}"

  plot

  show
}


# I generated the following function using chatgpt. Every time you use cd it automatically checks
# the folder you just cd'ed into and its parent folder for virtual environment (specifically
# a folder called .venv) and if it exists executes "source (path-to-.venv)/bin/activate"to 
# activate the environment. If there is no .venv folder found it automatically deactivates the environment.
function cd {
  local silent=false
  for arg in "$@"; do
      if [[ "$arg" == "-s" ]]; then
          silent=true
          break
      fi
  done

  # Call the original cd command
  builtin cd "$@" || return

  # Function to find the nearest .venv directory in parent directories
  function find_venv {
      local dir="$PWD"
      local home_dir="/Users/anton/"
      while [ "$dir" != "$home_dir" ] && [ "$dir" != "/" ]; do
          if [ -d "$dir/.venv" ]; then
              echo "$dir/.venv"
              return
          fi
          dir=$(dirname "$dir")
      done
      return
  }

  # Check if a .venv folder is found in any parent directory
  venv_dir=$(find_venv)

  # If a virtual environment was found and not activated, activate it
  if [ -n "$venv_dir" ] && [ "$VIRTUAL_ENV" != "$venv_dir" ]; then
      if [ -f "$venv_dir/bin/activate" ]; then
          source "$venv_dir/bin/activate"
          if [[ "$silent" == false ]]; then
              echo "   Activated virtual Environment with $(eval python --version)"
          fi
      fi
  # If no .venv was found and a virtual environment is active, deactivate it
  elif [ -z "$venv_dir" ] && [ -n "$VIRTUAL_ENV" ]; then
      deactivate
      if [[ "$silent" == false ]]; then
          echo "   Deactivated virtual Environment."
      fi
  fi
}

# Execute the find_venv function once when a new shell is created
# in case you are already in a .venv environment
cd -s .
