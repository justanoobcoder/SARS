# Syaoran's Arch Ricing Script (SARS)

## What is SARS?

This is nothing to do with SARS-Cov. Syaoran's Arch Ricing Script (SARS) is a script that autoinstalls and sets up config files. SARS is based on [LARBS](https://github.com/LukeSmithxyz/LARBS). SARS is for Arch or Arch-based distros only. SARS will install [dwm-syaoran](https://gitlab.com/justanoobcoder/dwm-syaoran) as default window manager. SARS is not for anybody, it's mostly only for me. Unless you want to use all my config files, don't use this script, it will overwrite all your config files.

## Installation:

Log in as root user. Run the following:

    bash <(curl -Ls bit.do/sars-sh)

If the above command fails, then try one of these:

    bash <(curl -Ls tinyurl.com/sars-sh)
    bash <(curl -Ls cutt.ly/sars-sh)
    bash <(curl -s https://gitlab.com/justanoobcoder/SARS/-/raw/master/sars.sh)

## How to use
Read this [Wiki](https://gitlab.com/justanoobcoder/SARS/-/wikis/Home) page.

## Packages

Packages with a "M" are from Arch's main repository. Packages with an "A" are from AUR. Packages with a "G" are from git repository (which use Makefile to install), it will clone the repository then use `make` to install. Packages with a "Z" are from git repository (which use Makefile to install), it will download the zip file, unzip it and use `make` to install. If you want to install from git repository, "Z" is recommended because some git repos are quite heavy, download a zip file is way faster and sometimes git clone is so freaking slow. Packages with a "P" are from python pip.

| Source | Package name | Comment |
| :--- | :--- | :--- |
| M | xorg | includes Xorg server packages, packages from the xorg-apps group and fonts. |
| M | xorg-xinit | starts the graphical server. |
| M | ttf-linux-libertine | provides the sans and serif fonts. |
| M | arandr | is a UI for screen adjustment. |
| M | fzf | is command-line fuzzy finder. |
| M | picom | is for transparency and removing screen-tearing. |
| M | highlight | is a fast and flexible source code highlighter (CLI version). |
| M | xorg-xprop | is a tool for detecting window properties. |
| M | dosfstools | allows your computer to access dos-like filesystems. |
| M | libnotify | allows desktop notifications. |
| M | dunst | is a customizable and lightweight notification-daemon. |
| M | sxiv | is a minimalist image viewer. |
| M | htop | is an interactive process viewer. |
| M | pcmanfm | is an extremely fast and lightweight file manager. |
| M | xwallpaper | sets the wallpaper. |
| M | ffmpeg | can record and splice video and audio on the command line. |
| M | maim | is utility to take a screenshot using imlib2. |
| M | clang | is a C/C++/Objective C/CUDA compiler based on LLVM. |
| M | npm | is the official package manager for node.js. |
| M | nodejs | is a JavaScript runtime environment combined with useful libraries. |
| M | gnome-keyring | serves as the system keyring. |
| M | xdotool | is command-line X11 automation tool. |
| M | neovim | is a tidier vim with some useful features. |
| M | xcape | configures modifier keys to act as other keys when pressed and released on their own. |
| M | mpd | is a lightweight music daemon. |
| M | mpc | is a terminal interface for mpd. |
| M | mpv | is the patrician's choice video player. |
| M | man-db | lets you read man pages of programs. |
| M | pacman-contrib | contains contributed scripts and tools for pacman systems. |
| M | calcurse | is a lightweight terminal-based calendar. |
| M | ncmpcpp | is a ncurses interface for music with multiple formats and a powerful tag editor. |
| M | noto-fonts-emoji | is an emoji font. |
| M | pulseaudio | is a general purpose sound server intended to run as a middleware between your applications and your hardware devices, either using ALSA or OSS. |
| M | pulseaudio-alsa | is the audio system. |
| M | alsa-utils | contains (among other utilities) the alsamixer and amixer utilities |
| M | unrar | extracts rar's. |
| M | unzip | unzips zips. |
| M | numlockx | turns on the numlock key in X11. |
| M | wget | is a free software package for retrieving files using HTTP, HTTPS, FTP and FTPS. |
| M | openssh | is a set of computer programs providing encrypted communication sessions over a computer network using the Secure Shell (SSH) protocol. |
| M | xclip | allows for copying and pasting from the command line. |
| M | youtube-dl | can download any YouTube video (or playlist or channel) when given the link. |
| M | xorg-xbacklight | enables changing screen brightness levels. |
| M | zsh | is a powerful shell that operates as both an interactive shell and as a scripting language interpreter. |
| M | zsh-completions | for additional completion definitions. |
| M | zsh-syntax-highlighting | provides syntax highlighting in the shell. |
| M | ibus | is an input method framework, a system for entering non-Latin characters. |
| M | lxappearance | is feature-rich GTK+ theme switcher of the LXDE Desktop. |
| M | breeze-gtk | is widget theme for GTK 2 and 3. |
| M | qutebrowser | is a minimal web browser. |
| M | shotcut | is a simple video editor. |
| M | ttf-liberation | is a font. |
| M | ttf-font-awesome | is for awesome icons. |
| M | noto-fonts | is google noto font. |
| M | adobe-source-han-sans-kr-fonts | is Korean OpenType/CFF font. |
| M | adobe-source-han-sans-jp-fonts | is Japanese OpenType/CFF font. |
| M | adobe-source-han-sans-cn-fonts | is Simplified Chinese OpenType/CFF Sans font. |
| M | adobe-source-han-sans-tw-fonts | is Traditional Chinese OpenType/CFF Sans font. |
| M | adobe-source-han-serif-cn-fonts | is Simplified Chinese OpenType/CFF Serif font. |
| M | adobe-source-han-serif-tw-fonts | is Traditional Chinese OpenType/CFF Serif font. |
| A | ibus-bamboo | is a Vietnamese IME for ibus. |
| A | lf | is a terminal file manager inspired by ranger written in Go. |
| Z | https://gitlab.com/justanoobcoder/dwm-syaoran/-/archive/master/dwm-syaoran-master.zip | is a patched dwm (dynamic window manager) build. |
| Z | https://gitlab.com/justanoobcoder/st-syaoran/-/archive/master/st-syaoran-master.zip | is a patched st (suckless/simple terminal) build. |
| Z | https://gitlab.com/justanoobcoder/dwmblocks-syaoran/-/archive/master/dwmblocks-syaoran-master.zip | is dwm clickable status bar. |
| Z | https://gitlab.com/justanoobcoder/dmenu-syaoran/-/archive/master/dmenu-syaoran-master.zip | is a fast and lightweight dynamic menu for X. |
| Z | https://gitlab.com/justanoobcoder/srfetch/-/archive/master/srfetch-master.zip | is a modified neofetch script. |
