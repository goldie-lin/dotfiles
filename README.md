dotfiles
========

dotfiles in my home directory on Ubuntu.


.bash_aliases
-------------

My bash aliases, functions, environment variables,
and tab auto-completions sourcing.

Requirements:

1.  Bash-compatible tab auto-completion source files.
    * [git](https://github.com/git/git)
    * [hub](https://github.com/github/hub/releases)
    * [Android git-repo](https://github.com/aartamonau/repo.bash_completion) (repo)
    * [Android tools](https://github.com/mbrubeck/android-completion) (adb, fastboot, etc.)
    * [crosstool-NG](http://crosstool-ng.org/git/crosstool-ng/)

2.  Need a symlink for alias `vless`.

```bash
cd /usr/share/vim/
sudo ln -s vim74 vimcurrent
```


.bash_sunjdk
------------

Manually sourcing for exporting Oracle (Sun) JDK to `$PATH`.

Usage: (use it only when you need)

```bash
. ~/.bash_sunjdk
```

Requirements:

* Create several symlinks linked to full version number, e.g.,

```bash
$ cd ~/opt/java/
$ ll
[...]
jdk-5 -> jdk-5u22-x64/
jdk-5u22-x64/
jdk-6 -> jdk-6u45-x64/
jdk-6u45-x64/
jdk-7 -> jdk-7u72-x64/
jdk-7u72-x64/
jdk-8 -> jdk-8u25-x64/
jdk-8u25-x64/
[...]
```


.curlrc
-------

Proxy setting for curl tool.


.gitconfig
----------

My personal git configuration.

Required packages:

1.  `diff-highlight` for pagers.  
    It located at official [git](https://github.com/git/git.git) repository.
    You need to git clone it,  And symlink it
    ([contrib/diff-highlight/diff-highlight](https://github.com/git/git/tree/master/contrib/diff-highlight)) into your $PATH.

2.  `vim` and `vimdiff` for editor and diff tool.  
    `sudo apt-get install vim`


.gitconfig.local
----------------

A private .gitconfig sample, please copy to home directory and edit it to add username/email, ..., etc.

```bash
cp .gitconfig.local ~/
vi ~/.gitconfig.local
```


.git_ignore
-----------

My personal global `.gitignore` file.

Requirements:

* Create a symlink `~/.config/git/ignore`.

```bash
mkdir -p ~/.config/git
ln -s /PATH/TO/dotfiles/.git_ignore ~/.config/git/ignore
```


.minirc.*
---------

My regularly used configurations of
[minicom](https://en.wikipedia.org/wiki/Minicom),
using with UART console.

* Create several symlinks pointed to them in home directory:

```bash
ln -s /PATH/TO/dotfiles/.minirc.* ~
```


.tmux.conf
----------

My preferred [tmux](https://tmux.github.io/) settings, included some vi-like
key-bindings.

Tmux is a terminal multiplexer, useful in localhost and remote server,
especially when ssh to remote server via a shaky and unstable connection.


.Xdefaults
----------

My preferred URxvt (rxvt-unicode) settings, included font, font-size, color
definitions, url launcher, selection autotransforms.  With regard to the
font, I preferred the bitmap fonts, like the Terminus.  Additionally, I had
mixed the CJK and the english fonts, e.g., Terminus + AR PL UMing (文鼎明體).
See the file content for more details.

Install URxvt:

```bash
sudo apt-get install rxvt-unicode-256color
```

`rxvt-unicode-256color` is only existed on Ubuntu 12.04 and 14.04+,
please install `rxvt-unicode` instead if you are using other Ubuntu version.

```bash
sudo apt-get install rxvt-unicode
```

Required packages:

```bash
sudo apt-get install xsel xclip
sudo apt-get install xfonts-terminus
sudo apt-get install fonts-arphic-uming
```

To apply the change:

```bash
xrdb -merge ~/.Xdefaults
```

Create a directory for URxvt perl libs look-up path:

```bash
mkdir -p ~/.urxvt/ext
```

Add the [Bert Münnich's URxvt perl libs](https://github.com/muennich/urxvt-perls)
via symlinks. (optional)

```bash
mkdir ~/opt && cd $_
git clone https://github.com/muennich/urxvt-perls.git
cd ~/.urxvt/ext
ln -s ../../opt/urxvt-perls/{clipboard,keyboard-select,url-select} .
```

p.s. `confirm-paste` URxvt perl lib only existed on Ubuntu 12.04 and 14.04+,
please remove it from `URxvt.perl-ext-common:` line if you are using other
Ubuntu version.
