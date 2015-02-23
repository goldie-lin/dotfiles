#!/bin/bash
# My custom Bash environment

### Aliases
alias ..='up'
alias cp="${HOME}/bin/cp_g -ig"
alias mv="${HOME}/bin/mv_g -ig"
alias rm='rm -i'
alias du='du -h'
alias df='df -hT'
alias ls='ls --color=auto --quoting-style=shell'
alias ll='ls -alF --time-style="+%Y-%m-%d_%H-%M-%S"'
alias la='ls -AF'
alias l='ls -CF'
alias cgitroot='git rev-parse --is-inside-work-tree >/dev/null && cd "$(git rev-parse --show-toplevel)"'
alias cleanrepo='repo status; repo branch; read -p "Really? It will git reset hard!"; rm -vf .ccienv_default makeMtk.ini {checkenv,auto_sync_android}.log; rm -rf out; repo forall -c "git reset --hard; git clean -dfx"'
alias man='man -S 2:3:1'  # add C function manual
alias vimenc="vim -u '${HOME}/.vimrc_encrypt' -x"
alias vless='/usr/share/vim/vimcurrent/macros/less.sh'
alias grep='grep --color=auto --exclude-dir=.repo --exclude-dir=.git --exclude-dir=.svn --exclude-dir=.bzr --exclude-dir=.hg --exclude=cscope.files --exclude=cscope.out --exclude=cscope.in.out --exclude=cscope.po.out --exclude=tags'
alias minicom='LC_ALL=C minicom' # English-language
alias udevmonitor_usb='udevadm monitor --subsystem-match=usb --udev --property'

### Source Bash-compatible tab auto-completion
## git
source "${HOME}/opt/git/contrib/completion/git-completion.bash"
## hub
source "${HOME}/opt/hub/etc/hub.bash_completion.sh"
## repo
source "${HOME}/opt/repo.bash_completion/repo.bash_completion"
## Android tools (adb, fastboot, android, emulator)
source "${HOME}/opt/android-completion/android"
## crosstool-NG
source "${HOME}/opt/crosstool-ng/src/ct-ng.comp"

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

### Export PATH
## crosstool-NG
export PATH="${HOME}/opt/crosstool-ng/bin/bin:${PATH}"
## My private bin
export PATH="${HOME}/bin:${PATH}"

### Program settings
## Default text editor for: crontab, git
export EDITOR="vim"
## Ccache
export CCACHE_MAX_SIZE="30G"
export CCACHE_DIR="${HOME}/.ccache"
## Minicom: linewrap, colorful
export MINICOM="-w -c on"
## XZ (also affect "tar -J")
export XZ_OPT="--x86 --lzma2=preset=9e,dict=128MiB"

### Functions
## Find the package name of a specific command
whichpkg() {
  readlink -f "$(which "$1")" | xargs --no-run-if-empty dpkg -S
}
## cd up
up() {
  if [ -z "${1//[0-9]/}" ]; then
    local P='./'
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
