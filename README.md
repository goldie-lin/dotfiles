dotfiles
========

dotfiles in my home directory on Ubuntu.


.bash_aliases
-------------
My bash aliases, functions, environment variables,
and tab auto-completions sourcing.

Requirement:

1.  Bash-compatible tab auto-completion source files.
    * [git](https://github.com/git/git)
    * [Android git-repo](https://github.com/aartamonau/repo.bash_completion) (repo)
    * [Android tools](https://github.com/mbrubeck/android-completion) (adb, fastboot, etc.)
    * [crosstool-NG](http://crosstool-ng.org/git/crosstool-ng/)

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

Add external URxvt perl libs (extensions):  
e.g., [Bert Münnich's Perl extensions for URxvt](https://github.com/muennich/urxvt-perls).

```bash
git clone https://github.com/muennich/urxvt-perls.git

# Make a directory for placing custom urxvt perl libs:
mkdir ~/.urxvt
cd ~/.urxvt
ln -s /PATH/TO/urxvt-perls/{clipboard,keyboard-select,url-select} .

# Modify the .Xdefaults of urxvt:
vi ~/.Xdefaults
#--------------------8<--------------------#
URxvt.perl-lib:        /home/goldie/.urxvt
URxvt.perl-ext-common: default,matcher,tabbed,clipboard,selection-autotransform
! Clipboard: (M=Alt, C=Ctrl, S=Shift)
URxvt.keysym.M-c:   perl:clipboard:copy
URxvt.keysym.M-v:   perl:clipboard:paste
URxvt.keysym.M-C-v: perl:clipboard:paste_escaped
#--------------------8<--------------------#
```

p.s. `confirm-paste` URxvt perl lib only existed on Ubuntu 12.04 and 14.04+,
please remove it from `URxvt.perl-ext-common:` line if you are using other
Ubuntu version.
