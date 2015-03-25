#!/usr/bin/env bash
# My custom Bash environment

### Aliases
alias ..='up'
alias cp="cp -i"
alias mv="mv -i"
alias rm='rm -i'
alias du='du -h'
alias df='df -hT'
alias ls='ls --color=auto --quoting-style=shell'
alias ll='ls -alF --time-style="+%Y-%m-%d_%H-%M-%S"'
alias la='ls -AF'
alias l='ls -CF'
alias cgitroot='git rev-parse --is-inside-work-tree >/dev/null && cd "$(git rev-parse --show-toplevel)"'
alias repo_clean='repo status -o; repo branch; read -p "Really? It will git reset hard!"; rm -vf .ccienv_default makeMtk.ini {checkenv,auto_sync_android}.log; rm -rf out; repo forall -c "git clean -dfx; git reset --hard"'
alias repo_list_stashed_git="repo forall -c 'if git rev-parse --verify --quiet refs/stash >/dev/null; then echo has_stashed_changes: \$REPO_PATH; fi'"
#alias man='man -S 2:3:1'  # add C function manual
alias vi="vim"
alias vimenc="vim -u ~/.vimrc_encrypt -x"
alias vless='/usr/share/vim/vimcurrent/macros/less.sh'
alias grep='grep --color=auto --exclude-dir=.repo --exclude-dir=.git --exclude-dir=.svn --exclude-dir=.bzr --exclude-dir=.hg --exclude=cscope.files --exclude=cscope.out --exclude=cscope.in.out --exclude=cscope.po.out --exclude=tags'
alias minicom='LC_ALL=C minicom -w -c on' # English-language, linewrap, colorful
alias udev_monitor_usb='udevadm monitor --subsystem-match=usb --udev --property'
alias udev_reload_rules='sudo udevadm control --reload'  # Trigger systemd-udevd to reload rules files and databases
alias sudo='sudo '  # Last blank character will make bash to check for alias expansion in the next command following this alias

### Source Bash-compatible tab auto-completion
source_list=( \
  "${HOME}/opt/git/contrib/completion/git-completion.bash"
  "${HOME}/opt/hub/etc/hub.bash_completion.sh"
  "${HOME}/opt/repo.bash_completion/repo.bash_completion"
  "${HOME}/opt/android-completion/android"
  "${HOME}/opt/crosstool-ng/src/ct-ng.comp"
  "${HOME}/opt/git/contrib/completion/git-prompt.sh"
)
for i in "${source_list[@]}"; do
  [ -f "$i" ] && . "$i"
done
unset i source_list

__set_prompt() {
  local -r last_cmd_rc="$?"  # Must come first!
  local -r fancyX='×'     # or: '\342\234\227'
  local -r checkmark='v'  # or: '\342\234\223'
  local prompt_pre=""
  local prompt_post=""

  if [[ "${last_cmd_rc}" -eq 0 ]]; then
    prompt_pre='\[\e[0m\][\[\e[1;34m\]'"$(date +%m-%d,%H:%M:%S)"'\[\e[0m\]][\[\e[1;32m\]'"${checkmark}"'\[\e[0m\]] \[\e[1;32m\]\u\[\e[1;33m\]@\[\e[1;32m\]\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]'
    prompt_post='\$ '
  else
    prompt_pre='\[\e[0m\][\[\e[1;34m\]'"$(date +%m-%d,%H:%M:%S)"'\[\e[0m\]][\[\e[1;31m\]'"${fancyX}"'\[\e[0m\]] \[\e[1;32m\]\u\[\e[1;33m\]@\[\e[1;32m\]\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]'
    prompt_post=' (\[\e[1;33;41m\]'"${last_cmd_rc}"'\[\e[0m\])\$ '
  fi

  if hash __git_ps1 2>/dev/null; then
    export GIT_PS1_SHOWDIRTYSTATE=1        # *#
    export GIT_PS1_SHOWUNTRACKEDFILES=1    # %
    export GIT_PS1_SHOWSTASHSTATE=1        # $
    export GIT_PS1_SHOWCOLORHINTS=1
    export GIT_PS1_DESCRIBE_STYLE="branch"
    export GIT_PS1_SHOWUPSTREAM="auto git"
    __git_ps1 "${prompt_pre}" "${prompt_post}"
  else
    PS1="${prompt_pre}${prompt_post}"
  fi
}
PROMPT_COMMAND='__set_prompt'

### Colorful man page
export PAGER="$(which less) -s -R"
export BROWSER="${PAGER}"
export LESS_TERMCAP_mb=$'\e[0;34m'
export LESS_TERMCAP_md=$'\e[0;34m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[0;33;44m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[0;33m'

### Setup proxy
#export no_proxy="localhost,127.0.0.1,.compalcomm.com,.compal.com"
#export http_proxy="http://127.0.0.1:3128/"
#export https_proxy="${http_proxy}"
#export ftp_proxy="${http_proxy}"
#export all_proxy="${http_proxy}"
#export rsync_proxy="${http_proxy}"

### Add more PATHs
prepend_path_list=( \
  "${HOME}/bin"
  "${HOME}/opt/crosstool-ng/bin/bin"
)
for i in "${prepend_path_list[@]}"; do
  if [[ "${UID}" -ge 1000 && -d "$i" ]] && ! grep -q "$i" <<< "${PATH}"; then
    export PATH="$i:$PATH"
  fi
done
unset i prepend_path_list

### Program settings
## Default text editor for: crontab, git
export EDITOR="vim"
## Ccache
export CCACHE_MAX_SIZE="30G"
export CCACHE_DIR="${HOME}/.ccache"
## XZ (also affect "tar -J")
export XZ_OPT="--x86 --lzma2=preset=9e,dict=128MiB"

### Functions
## Get Linux distro name. (Beta, potentially unstable!)
_get_linux_distro_name() {
  local -r _os="$(uname -s)"

  if [ "${_os}" = "Linux" ]; then
    if [ -f /etc/lsb-release ]; then
      # TODO: Should we trust the lsb_release command?
      lsb_release -s -i
    elif [ -f /etc/arch-release ]; then
      echo "Arch"
    elif [ -f /etc/debian_version ]; then
      echo "Debian"
    elif [ -f /etc/redhat-release ]; then
      echo "RedHat"
    elif [ -f /etc/SuSE-release ]; then
      echo "SuSE"
    else
      echo "Unknown"
    fi
  else
    echo "NonLinux"
  fi
}
## Find the package name of a specific command
whichpkg() {
  local -r _distro="$(_get_linux_distro_name)"

  case "${_distro}" in
  "Arch")
    readlink -f "$(which "$1")" | xargs --no-run-if-empty pacman -Qo ;;
  "Ubuntu")
    readlink -f "$(which "$1")" | xargs --no-run-if-empty dpkg -S ;;
  *)
    echo >&2 "Error: Unsupported distro: '${_distro}'!" ;;
  esac
}
## cd up
up() {
  if [ -z "${1//[0-9]/}" ]; then
    local i='' P='./'
    for (( i=0; i<${1:-1}; i++ )); do
      P="${P}../"
    done
    cd $P
  else
    echo "usage: up N"
  fi
}
## Clear memory cache
# https://www.kernel.org/doc/Documentation/sysctl/vm.txt
clear_cache() {
  # Mark more objects as clean objects to minimize the number of dirty objects
  sync
  # Free pagecache and reclaimable slab objects (includes dentries and inodes)
  sudo sysctl -w vm.drop_caches=3
}
## Ccache toggle for Android codebase
# Disable ccache
ccache_disable() {
  unset USE_CCACHE
  #unset CCACHE_DIR
}
# Enable ccache
ccache_enable() {
  export USE_CCACHE="1"
  if [ -f Makefile ]; then
    if [ -f ./prebuilt/linux-x86/ccache/ccache ]; then
      ./prebuilt/linux-x86/ccache/ccache -M "${CCACHE_MAX_SIZE}"
    elif [ -f ./prebuilts/misc/linux-x86/ccache/ccache ]; then
      ./prebuilts/misc/linux-x86/ccache/ccache -M "${CCACHE_MAX_SIZE}"
    else
      echo "Prebuilt ccache binary not found!" >&2
    fi
  else
    echo "Makefile not found! (Please execute in Android root directory)" >&2
  fi
}
# Clear ccache cache directory
ccache_clearcache() {
  if [ -f Makefile ]; then
    if [ -f ./prebuilt/linux-x86/ccache/ccache ]; then
      ./prebuilt/linux-x86/ccache/ccache -C
    elif [ -f ./prebuilts/misc/linux-x86/ccache/ccache ]; then
      ./prebuilts/misc/linux-x86/ccache/ccache -C
    else
      echo "Prebuilt ccache binary not found!" >&2
    fi
  else
    echo "Makefile not found! (Please execute in Android root directory)" >&2
  fi
}
## GCC downgrade
# Set GCC downgrade
gcc_downgrade_set() {
  sudo ln -sf  gcc-4.5 /usr/bin/gcc
  sudo ln -sf  g++-4.5 /usr/bin/g++
  sudo ln -sf  cpp-4.5 /usr/bin/cpp
  sudo ln -sf gcov-4.5 /usr/bin/gcov
  ls -l /usr/bin/{gcc,g++,cpp,gcov}
}
# Unset GCC downgrade
gcc_downgrade_unset() {
  sudo ln -sf  gcc-4.6 /usr/bin/gcc
  sudo ln -sf  g++-4.6 /usr/bin/g++
  sudo ln -sf  cpp-4.6 /usr/bin/cpp
  sudo ln -sf gcov-4.6 /usr/bin/gcov
  ls -l /usr/bin/{gcc,g++,cpp,gcov}
}
