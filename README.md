# Syaoran's Arch Linux Auto Setup (SALAS)

## Installation:

Log in as root user. Run the following:

    curl -L bit.do/salas-sh -o salas.sh
    chmod +x salas.sh
    sh salas.sh

If the first command fails, then try one of these:

    curl -L tinyurl.com/salas-sh -o salas.sh
    curl -L cutt.ly/salas-sh -o salas.sh
    curl https://gitlab.com/justanoobcoder/SALAS/-/raw/master/salas.sh

## What is SALAS?
Syaoran's Arch Linux Auto Script (SALAS) is a script that autoinstalls and sets up config files. SALAS is for Arch or Arch-based distros only. SALAS will install [dwm-syaoran](https://gitlab.com/justanoobcoder/dwm-syaoran) as default window manager. SALAS is not for anybody, it's mostly only for me. Unless you want to use all my config files, don't use this script, it will overwrite all your config files.

## Packages

| Source | Package name | Comment |
| :--- | :--- | :--- |
| M | xorg | includes Xorg server packages, packages from the xorg-apps group and fonts. |
| M | xorg-xinit | starts the graphical server. |
| M | ttf-linux-libertine | provides the sans and serif fonts. |
| M | arandr | is a UI for screen adjustment. |
| M | dmenu | is a fast and lightweight dynamic menu for X. |
| M | picom | is for transparency and removing screen-tearing. |
| M | xorg-xprop | is a tool for detecting window properties. |
| M | dosfstools | allows your computer to access dos-like filesystems. |
| M | libnotify | allows desktop notifications. |
| M | sxiv | is a minimalist image viewer. |
| M | feh | sets the wallpaper. |
| M | ffmpeg | can record and splice video and audio on the command line. |
| M | gnome-keyring | serves as the system keyring. |
| M | neovim | a tidier vim with some useful features |
| M | mpd | is a lightweight music daemon. |
| M | mpc | is a terminal interface for mpd. |
| M | mpv | is the patrician's choice video player. |
| M | man-db | lets you read man pages of programs. |
| M | ncmpcpp | is a ncurses interface for music with multiple formats and a powerful tag editor. |
| M | noto-fonts-emoji | is an emoji font. |
| M | pulseaudio | is a general purpose sound server intended to run as a middleware between your applications and your hardware devices, either using ALSA or OSS. |
| M | pulseaudio-alsa | is the audio system. |
| M | alsa-utils | contains (among other utilities) the alsamixer and amixer utilities |
| M | unrar | extracts rar's. |
| M | unzip | unzips zips. |
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
| M | firefox | is a popular web browser. |
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
| Z | https://gitlab.com/justanoobcoder/dwm-syaoran/-/archive/master/dwm-syaoran-master.zip | is a patched dwm (dynamic window manager) build. |
| Z | https://gitlab.com/justanoobcoder/st-syaoran/-/archive/master/st-syaoran-master.zip | is a patched st (suckless/simple terminal) build. |
| Z | https://gitlab.com/justanoobcoder/dwmblocks-syaoran/-/archive/master/dwmblocks-syaoran-master.zip | is dwm clickable status bar. |
| Z | https://gitlab.com/justanoobcoder/scrcast/-/archive/master/scrcast-master.zip | is a simple screenshot and screencast script. |
| Z | https://gitlab.com/justanoobcoder/srfetch/-/archive/master/srfetch-master.zip | is a modified neofetch script. |
