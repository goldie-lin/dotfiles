#!/usr/bin/env bash
#
# ~/.bashrc
#

# if not running interactively, don't do anything.
[[ $- != *i* ]] && return

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# don't put lines matched following pattern in the history.
HISTIGNORE=$'@(l|l[sal]|[bf]g|jobs|exit|clear|reset|pwd|?(u)mount)*([ \t])'

# set history length.
HISTSIZE=2000
HISTFILESIZE=5000

# add timestamp to each entry displayed by the history builtin.
HISTTIMEFORMAT='%F,%T '

# append to the history file, don't overwrite it.
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# enable extended pattern matching.
shopt -s extglob

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files.
[[ -x /usr/bin/lesspipe ]] && eval "$(lesspipe)"        # for Ubuntu
[[ -x /usr/bin/lesspipe.sh ]] && eval "$(lesspipe.sh)"  # for Arch Linux

# language fallback if in linux virtual termianl.
[[ "$TERM" == linux ]] && export LANG=C LC_ALL=C

# set variable identifying the chroot you work in for Ubuntu. (used in the prompt below)
[[ -z "${debian_chroot:-}" && -r /etc/debian_chroot ]] && debian_chroot=$(cat /etc/debian_chroot)

# enable color support of ls/tree commands.
if [[ -x /usr/bin/dircolors ]]; then
  if [[ -r ~/.dir_colors ]]; then
    eval "$(dircolors -b ~/.dir_colors)"
  else
    eval "$(dircolors -b)"
  fi
fi

# enable system-wide bash-completion.
if ! shopt -oq posix; then
  if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    . /usr/share/bash-completion/bash_completion
  elif [[ -f /etc/bash_completion ]]; then
    . /etc/bash_completion
  fi
fi

# my git ps1 prompt.
# ref: https://github.com/josuah/config/blob/master/.local/bin/git-prompt
__my_git_ps1() {
  local -i _color_on="$1"

  # shellcheck disable=SC2015
  git rev-parse &>/dev/null && \
    ( [[ "$(git rev-parse --is-bare-repository)" == true ]] && (echo '&' ; echo "# branch.head $(git rev-parse --abbrev-ref HEAD)") || \
      [[ "$(git rev-parse --is-inside-git-dir)"  == true ]] && echo '@' || \
      (git rev-parse --verify -q refs/stash >/dev/null && echo '$' ; git status --porcelain=v2 -b --ignored) \
    ) | gawk -v "coloron=${_color_on}" '

  /^&$/              { bare++;      next; }
  /^@$/              { insidegit++; next; }
  /^\$$/             { stashed++;   next; }
  /^# branch\.head / { head = $0; sub(/# branch\.head /, "", head); next; }
  /^# branch\.ab /   { match($0, /^# branch\.ab \+([0-9]+) -([0-9]+)$/, ab); ahead = ab[1]; behind = ab[2]; next; }
  /^! /              { ignored++;   next; }
  /^\? /             { untracked++; next; }
  /^[12] U. /        { conflicts++; next; }
  /^[12] .U /        { conflicts++; next; }
  /^[12] DD /        { conflicts++; next; }
  /^[12] AA /        { conflicts++; next; }
  /^[12] .M /        { changed++;         }
  /^[12] .D /        { changed++;         }
  /^[12] [^.]. /     { staged++;          }

  END {
    printf(" (");

    if (bare != 0) {
      printf((coloron != 1) ? "%s:%s" : "\\[\033[1;32m\\]%s\\[\033[0m\\]:\\[\033[0;32m\\]%s\\[\033[0m\\]", "BARE", head);
    } else if (insidegit != 0) {
      printf((coloron != 1) ? "%s" : "\\[\033[1;32m\\]%s\\[\033[0m\\]", "GIT_DIR");
    } else {
      printf((coloron != 1) ? "%s" : "\\[\033[0;32m\\]%s\\[\033[0m\\]", head);
      if (stashed + ignored + untracked + conflicts + changed + staged != 0) {
        printf(" ");
        if (stashed  ) printf((coloron != 1) ? "$"    : "\\[\033[1;34m\\]$\\[\033[0m\\]"                );
        if (staged   ) printf((coloron != 1) ? "+%d"  : "\\[\033[0;32m\\]+%d\\[\033[0m\\]",    staged   );
        if (changed  ) printf((coloron != 1) ? "*%d"  : "\\[\033[0;31m\\]*%d\\[\033[0m\\]",    changed  );
        if (untracked) printf((coloron != 1) ? "%%%d" : "\\[\033[0;35m\\]%%%d\\[\033[0m\\]",   untracked);
        if (ignored  ) printf((coloron != 1) ? "i%d"  : "\\[\033[1;30m\\]i%d\\[\033[0m\\]",    ignored  );
        if (conflicts) printf((coloron != 1) ? "!%d"  : "\\[\033[1;41;30m\\]!%d\\[\033[0m\\]", conflicts);
      }
      if (behind + ahead != 0) {
        if (behind   ) printf((coloron != 1) ? "↓%d"  : "\\[\033[1;40;31m\\]↓%d\\[\033[0m\\]", behind   );
        if (ahead    ) printf((coloron != 1) ? "↑%d"  : "\\[\033[1;40;36m\\]↑%d\\[\033[0m\\]", ahead    );
      } else {
        printf((coloron != 1) ? "=" : "\\[\033[0m\\]=");
      }
    }

    printf((coloron != 1) ? ")" : "\\[\033[0m\\])");
  }'
}

# ref: https://github.com/jichu4n/bash-command-timer
__prompt_start_time=0
__is_at_prompt=1
__is_first_prompt=1
__pre_prompt() {
  if [[ -z "${__is_at_prompt}" ]]; then
    return
  fi
  unset -v __is_at_prompt
  __prompt_start_time="$(date '+%s')"
}
trap '__pre_prompt' DEBUG

# git-prompt.
__set_prompt() {
  local -r last_cmd_rc="$?"  # Must come first!
  local prompt_pre=""
  local prompt_post=""
  local -i color_on=0
  local r_str=""
  local -i start_time_secs=0
  local -i end_time_secs=0
  local -i elapsed_secs=0
  local -i elapsed_d=0
  local -i elapsed_h=0
  local -i elapsed_m=0
  local -i elapsed_s=0

  __is_at_prompt=1
  start_time_secs="${__prompt_start_time}"
  end_time_secs=$(date '+%s')
  elapsed_secs=$((end_time_secs - start_time_secs))
  elapsed_d=$((elapsed_secs/86400))
  elapsed_h=$((elapsed_secs%86400/3600))
  elapsed_m=$((elapsed_secs%3600/60))
  elapsed_s=$((elapsed_secs%60))
  printf -v r_str "%ds" "${elapsed_s}"
  [[ ${elapsed_m} -gt 0 ]] && printf -v r_str "%dm%s" "${elapsed_m}" "${r_str}"
  [[ ${elapsed_h} -gt 0 ]] && printf -v r_str "%dh%s" "${elapsed_h}" "${r_str}"
  [[ ${elapsed_d} -gt 0 ]] && printf -v r_str "%dd, %s" "${elapsed_d}" "${r_str}"

  # detect terminal color support
  if [[ -x /usr/bin/tput ]] && tput setaf 1 >&/dev/null; then
    color_on=1
  fi

  prompt_pre="${debian_chroot:+"($debian_chroot)"}"
  if [[ color_on -eq 1 ]]; then
    prompt_pre+='\[\e[1;32m\]\u\[\e[1;33m\]@\[\e[1;32m\]\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]'
  else
    prompt_pre+='\u@\h:\w'
  fi
  if [[ -n "${__is_first_prompt}" ]]; then
    unset -v __is_first_prompt
  else
    if [[ ${elapsed_secs} -gt 0 ]]; then
      prompt_post+=' (\[\e[33m\]'"${r_str}"'\[\e[0m\])'
    fi
  fi
  if [[ "${last_cmd_rc}" -ne 0 ]]; then
    if [[ color_on -eq 1 ]]; then
      prompt_post+=' (\[\e[1;33;41m\]'"${last_cmd_rc}"'\[\e[0m\])'
    else
      prompt_post+=" (${last_cmd_rc})"
    fi
  fi
  prompt_post+='\$ '

  if hash __my_git_ps1 &>/dev/null; then
    PS1="${prompt_pre}$(__my_git_ps1 "${color_on}")${prompt_post}"
  elif hash __git_ps1 &>/dev/null; then
    export GIT_PS1_SHOWDIRTYSTATE=1        # *#
    export GIT_PS1_SHOWUNTRACKEDFILES=1    # %
    export GIT_PS1_SHOWSTASHSTATE=1        # $
    if [[ color_on -eq 1 ]]; then
      export GIT_PS1_SHOWCOLORHINTS=1
    else
      unset -v GIT_PS1_SHOWCOLORHINTS
    fi
    export GIT_PS1_DESCRIBE_STYLE="branch"
    export GIT_PS1_SHOWUPSTREAM="auto git"
    __git_ps1 "${prompt_pre}" "${prompt_post}"
  else
    PS1="${prompt_pre}${prompt_post}"
  fi

  #if [[ -n "${__is_first_prompt}" ]]; then
  #  unset -v __is_first_prompt
  #else
  #  if [[ ${elapsed_secs} -gt 0 ]]; then
  #    echo -e "\e[${COLUMNS}C\e[${#r_str}D${r_str}"
  #  fi
  #fi
}
PROMPT_COMMAND='__set_prompt'

# colorful man page.
PAGER="$(which less) -s -R -i"
export PAGER
#export BROWSER="${PAGER}"
export LESS_TERMCAP_mb=$'\e[0;34m'      # begin blink
export LESS_TERMCAP_md=$'\e[0;34m'      # begin bold
export LESS_TERMCAP_me=$'\e[0m'         # reset bold/blink
export LESS_TERMCAP_so=$'\e[0;33;44m'   # begin reverse video
export LESS_TERMCAP_se=$'\e[0m'         # reset reverse video
export LESS_TERMCAP_us=$'\e[0;33m'      # begin underline
export LESS_TERMCAP_ue=$'\e[0m'         # reset underline

# env vars
# --------

# fzf default command/options.
export FZF_DEFAULT_OPTS="--reverse --inline-info"
export FZF_DEFAULT_COMMAND="
  (git ls-tree -r --name-only HEAD ||
    fd --color never --type f --follow --hidden --exclude .git --exclude .repo ||
    rg --color never --files --follow --hidden --glob '!.git/' --glob '!.repo/' ||
    ag --nocolor --hidden -f -g '' ||
    find -L . \\( -fstype dev -o -fstype proc \\) -prune -o -type f -print -o -type l -print | sed s/^..//
  ) 2>/dev/null"
export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"

# skim (sk) default command/options.
export SKIM_DEFAULT_OPTIONS="--reverse --inline-info"
export SKIM_DEFAULT_COMMAND="
  (git ls-tree -r --name-only HEAD ||
    fd --color never --type f --follow --hidden --exclude .git --exclude .repo ||
    rg --color never --files --follow --hidden --glob '!.git/' --glob '!.repo/' ||
    ag --nocolor --hidden -f -g '' ||
    find -L . \\( -fstype dev -o -fstype proc \\) -prune -o -type f -print -o -type l -print | sed s/^..//
  ) 2>/dev/null"

# functions
# ---------

# get Linux distro name. (beta, potentially unstable!)
__get_linux_distro_name() {
  local _os=""

  _os="$(uname -s)"

  if [[ "${_os}" = "Linux" ]]; then
    if hash "lsb_release" &>/dev/null; then
      lsb_release -s -i
    elif [[ -r /etc/lsb-release ]]; then
      ( source /etc/lsb-release && echo "$DISTRIB_ID")
    elif [[ -f /etc/arch-release ]]; then
      echo "Arch"
    elif [[ -f /etc/debian_version ]]; then
      echo "Debian"
    elif [[ -f /etc/fedora-release ]]; then
      echo "Fedora"
    elif [[ -f /etc/redhat-release ]]; then
      echo "RedHat"
    elif [[ -f /etc/centos-release ]]; then
      echo "CentOS"
    elif [[ -f /etc/oracle-release ]]; then
      echo "Oracle"
    elif [[ -f /etc/SuSE-release ]]; then
      echo "SuSE"
    elif [[ -r /etc/os-release ]]; then
      ( source /etc/os-release && echo "$ID")
    else
      echo "Unknown"
    fi
  else
    echo "NonLinux"
  fi
}

# find the package name of a specific command.
whichpkg() {
  local _distro=""

  _distro="$(__get_linux_distro_name)"

  case "${_distro}" in
  "Arch")
    readlink -f "$(which "$1")" | xargs --no-run-if-empty pacman -Qo ;;
  "Ubuntu")
    readlink -f "$(which "$1")" | xargs --no-run-if-empty dpkg -S ;;
  *)
    echo "Error: Unsupported distro: '${_distro}'!" >&2 ;;
  esac
}
complete -c command whichpkg

# cd up.
__up() {
  if [[ -z "${1//[0-9]/}" ]]; then
    local i='' P='./'
    for (( i=0; i<${1:-1}; i++ )); do
      P="${P}../"
    done
    cd "$P" || exit 1
  else
    echo "usage: __up N"
  fi
}

# clear memory cache.
# https://www.kernel.org/doc/Documentation/sysctl/vm.txt
clear_cache() {
  # Mark more objects as clean objects to minimize the number of dirty objects.
  sync
  # Free pagecache and reclaimable slab objects. (includes dentries and inodes.)
  sudo sysctl -w vm.drop_caches=3
}

# ccache toggle for Android codebase.
# disable ccache.
ccache_disable() {
  unset -v USE_CCACHE
  #unset -v CCACHE_DIR
}

# enable ccache.
ccache_enable() {
  local -r top_file="build/core/envsetup.mk"
  local -r ccache1="./prebuilt/linux-x86/ccache/ccache"  # Android 4.0 (ICS) or older.
  local -r ccache2="./prebuilts/misc/linux-x86/ccache/ccache"  # Android 4.1 (JB) or newer.

  export USE_CCACHE="1"

  if [[ ! -f "${top_file}" ]]; then
    echo "Error: Please cd to Android root and run again." >&2
    return 1
  fi

  if [[ -f "${ccache1}" && -x "${ccache1}" ]]; then
    "${ccache1}" -M "${CCACHE_MAX_SIZE}"
  elif [[ -f "${ccache2}" && -x "${ccache2}" ]]; then
    "${ccache2}" -M "${CCACHE_MAX_SIZE}"
  else
    echo "Error: Android prebuilt executable 'ccache' not found!" >&2
    return 2
  fi
}

# clear ccache cache directory.
ccache_clearcache() {
  local -r top_file="build/core/envsetup.mk"
  local -r ccache1="./prebuilt/linux-x86/ccache/ccache"  # Android 4.0 (ICS) or older.
  local -r ccache2="./prebuilts/misc/linux-x86/ccache/ccache"  # Android 4.1 (JB) or newer.

  if [[ ! -f "${top_file}" ]]; then
    echo "Error: Please cd to Android root and run again." >&2
    return 1
  fi

  if [[ -f "${ccache1}" && -x "${ccache1}" ]]; then
    "${ccache1}" -C
  elif [[ -f "${ccache2}" && -x "${ccache2}" ]]; then
    "${ccache2}" -C
  else
    echo "Error: Android prebuilt executable 'ccache' not found!" >&2
    return 2
  fi
}

# aliases
# -------

alias ..='__up'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias du='du -h'
alias df='df -hT'
# shellcheck disable=SC2010
__gnu_coreutils_version="$(ls --version | grep -Po '(?<=ls \(GNU coreutils\) )[0-9.]+')"
if [[ "${__gnu_coreutils_version}" == "$(echo -e "${__gnu_coreutils_version}\\n8.25" | sort -rV | head -n1)" ]]; then
  alias ls='ls --color=auto --quoting-style=shell-escape'  # required GNU coreutils version >= 8.25
else
  alias ls='ls --color=auto --quoting-style=shell'
fi
unset -v __gnu_coreutils_version
alias ll='ls -alF --time-style="+%Y-%m-%d_%H-%M-%S"'
alias la='ls -ACF'
alias l='ls -CF'
alias tree='tree -a --dirsfirst'
alias free='free -hltw'
alias cgitroot='git rev-parse --is-inside-work-tree >/dev/null && cd "$(git rev-parse --show-toplevel)"'
alias bash_disable_git_prompt='unset -f __git_ps1 __my_git_ps1'
alias git_unstage_added="cgitroot ; git status --porcelain=v1 -z | grep -zZ '^A[ MD] ' | sed -z 's/^...//' | xargs -0 --no-run-if-empty git reset HEAD -- ; cd -"
alias git_unstage_updated="cgitroot ; git status --porcelain=v1 -z | grep -zZ '^M[ MD] ' | sed -z 's/^...//' | xargs -0 --no-run-if-empty git reset HEAD -- ; cd -"
alias git_undo_renamed="cgitroot ; git status --porcelain=v1 | grep '^R[ MD] ' | sed -r 's/^...//;s/(.*) -> (.*)/git mv -v \"\\2\" \"\\1\"/' | sh ; cd -"
alias repo_clean='repo status -o; repo branch; read -p "Really? It will git reset hard!"; rm -vf .ccienv_default makeMtk.ini {checkenv,auto_sync_android}.log; rm -rf out; repo forall -c "git clean -dfx; git reset --hard"'
alias repo_list_stashed_git="repo forall -c 'if git rev-parse --verify --quiet refs/stash >/dev/null; then echo has_stashed_changes: \$REPO_PATH; fi'"
alias repo_list_ignored_git="repo forall -c 'if git status --porcelain=v2 --ignored | grep \"^! \" &>/dev/null; then echo has_ignored_files: \$REPO_PATH; fi'"
alias repo_list_untracked_git="repo forall -c 'if git status --porcelain=v2 | grep \"^? \" &>/dev/null; then echo has_untracked_files: \$REPO_PATH; fi'"
alias repo_list_changed_git="repo forall -c 'if ! git diff --no-ext-diff --quiet ; then echo has_changed_files: \$REPO_PATH; fi'"
alias repo_list_staged_git="repo forall -c 'if ! git diff --no-ext-diff --cached --quiet ; then echo has_staged_files: \$REPO_PATH; fi'"
#alias repo_list_unpushed_git="repo forall -c 'if git status --porcelain=v1 -b | grep \"^##.*\\.\\.\\.\" | grep -Eq \"\\[(ahead|behind)\" ; then echo has_unpushed_commits: \$REPO_PATH; fi'"
alias repo_list_unbalanced_git="repo forall -c 'branch_ab=\"\$(git status --porcelain=v2 -b | grep -Po \"(?<=^# branch\\.ab )(\\+[0-9]+ -[0-9]+)$\")\" ; if [[ \"\${branch_ab}\"  != \"+0 -0\" ]] ; then echo \"has_unbalanced_branch: \$REPO_PATH (\${branch_ab})\" ; fi'"
alias docker_stop_all_running_containers="docker ps -q -f 'status=running' -f 'status=restarting' -f 'status=paused' | xargs --no-run-if-empty docker stop"
alias docker_rm_all_stopped_containers="docker ps -q -f 'status=exited' | xargs --no-run-if-empty docker rm"
alias docker_rmi_all_dangling_images="docker images -q -f 'dangling=true' | xargs --no-run-if-empty docker rmi"
#alias man='man -S 2:3:1'  # add C function manual.
alias gpg='gpg2'
alias gpgv='gpgv2'
#alias nvim='nvim -p'
alias nvimdiff='nvim -d'
#alias vim='vim -p'
alias vi='vim'
alias vimenc='vim -u ~/.vimrc_encrypt -x'

__vim_or_nvim_less_sh_path() {
  local _distro=
  local _pkgname=
  local _vim_or_nvim="${1:-vim}"
  _distro="$(__get_linux_distro_name)"
  case "${_distro}" in
    Arch)
      case "${_vim_or_nvim}" in
        vim)  _pkgname="vim-runtime";;
        nvim) _pkgname="neovim";;
      esac
      if pacman -Qs "${_pkgname}" &> /dev/null; then
        pacman -Ql "${_pkgname}" | grep -o '/usr/share/.*/macros/less\.sh' | uniq
      fi
      ;;
    Ubuntu)
      case "${_vim_or_nvim}" in
        vim)  _pkgname="vim-runtime";;
        nvim) _pkgname="neovim-runtime";;
      esac
      if [[ "$(dpkg-query -W --showformat='${db:Status-Abbrev}' "${_pkgname}")" =~ ii ]]; then
        dpkg -L "${_pkgname}" | grep -o '/usr/share/.*/macros/less\.sh' | uniq
      fi
      ;;
  esac
}
# shellcheck disable=SC2139
alias vless="$(__vim_or_nvim_less_sh_path vim)"
# shellcheck disable=SC2139
alias nvless="$(__vim_or_nvim_less_sh_path nvim)"
unset -f __vim_or_nvim_less_sh_path

alias diff='diff --color=auto'
alias grep='grep --color=auto --exclude-dir=.repo --exclude-dir=.git --exclude-dir=.svn --exclude-dir=.bzr --exclude-dir=.hg --exclude=cscope.* --exclude=tags --exclude=GTAGS --exclude=GRTAGS --exclude=GPATH'
alias egrep='egrep --color=auto --exclude-dir=.repo --exclude-dir=.git --exclude-dir=.svn --exclude-dir=.bzr --exclude-dir=.hg --exclude=cscope.* --exclude=tags --exclude=GTAGS --exclude=GRTAGS --exclude=GPATH'
alias fgrep='fgrep --color=auto --exclude-dir=.repo --exclude-dir=.git --exclude-dir=.svn --exclude-dir=.bzr --exclude-dir=.hg --exclude=cscope.* --exclude=tags --exclude=GTAGS --exclude=GRTAGS --exclude=GPATH'
alias ag='ag --column --smart-case --color-line-number="0;32" --color-path="0;35" --color-match="1;31"'
alias rg='rg --column --smart-case --colors "path:fg:magenta" --colors "path:style:nobold" --colors "line:fg:green" --colors "line:style:nobold" --colors "column:fg:cyan" --colors "column:style:nobold" --colors "match:fg:red" --colors "match:style:bold"'
alias attach-tmux='tmux attach\; choose-tree'
alias mux='tmuxinator'
alias youtube-dl-video='youtube-dl --format "bestvideo+bestaudio/best" --sub-lang "zh-Hant,en" --write-sub --write-auto-sub --embed-subs --convert-subs srt --merge-output-format mkv'
alias youtube-dl-audio='youtube-dl --format "bestaudio/best" --extract-audio --audio-quality 0'
alias youtube-dl-mp3='youtube-dl --format "bestaudio/best" --extract-audio --audio-quality 0 --audio-format mp3 --embed-thumbnail'
alias minicom='LC_ALL=C minicom'
alias udev_monitor_usb='udevadm monitor --subsystem-match=usb --udev --property'
alias udev_reload_rules='sudo udevadm control --reload'  # Trigger systemd-udevd to reload rules files and databases.
alias sudo='sudo '  # Last blank character will make bash to check for alias expansion in the next command following this alias.

# load ~/.bashrc.local
if [[ -f ~/.bashrc.local && -r ~/.bashrc.local ]]; then
  eval source ~/.bashrc.local
fi
