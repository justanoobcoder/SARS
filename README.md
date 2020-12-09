# Syaoran's Arch Ricing Script (SARS)

## What is SARS?

This is nothing to do with SARS-Cov. Syaoran's Arch Ricing Script (SARS) is a script that autoinstalls and sets up config files. SARS is based on [LARBS](https://github.com/LukeSmithxyz/LARBS). SARS is for Arch or Arch-based distros only. SARS will install [dwm-syaoran](https://gitlab.com/justanoobcoder/dwm-syaoran) as default window manager. SARS is not for anybody, it's mostly only for me. Unless you want to use all my config files, don't use this script, it will overwrite all your config files.

## Installation:

Log in as root user. Run the following:

    bash <(curl -Ls bit.ly/sars-sh)

## Packages

Packages with a "M" are from Arch's main repository. Packages with an "A" are from AUR. Packages with a "G" are from git repository (github or gitlab), it will clone the repository then use `make` to install. Packages with a "Z" are from git repository (github or gilab), it will download the zip file, unzip it and use `make` to install. If you want to install from git repository, "Z" is recommended because some git repos are quite heavy, download a zip file is way faster and sometimes git clone is so freaking slow. Packages with a "P" are from python pip.<br>
Note: packages from github or gitlab must have `Makefile` to use `make`.

| Source | Package name                                        | Comment                                                                                                                                          |
| :----- | :-------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------- |
| M@     | xorg                                                | is the most popular display server among Linux users.                                                                                            |
| M@     | xorg-xinit                                          | starts the graphical server.                                                                                                                     |
| M@     | xorg-xprop                                          | is a tool for detecting window properties.                                                                                                       |
| M@     | fzf                                                 | is command-line fuzzy finder.                                                                                                                    |
| M@     | networkmanager                                      | is a program for providing detection and configuration for systems to automatically connect to networks.                                         |
| M@     | network-manager-applet                              | is an applet for managing network connections.                                                                                                   |
| M@     | libnotify                                           | allows desktop notifications.                                                                                                                    |
| M@     | xwallpaper                                          | sets the wallpaper.                                                                                                                              |
| M@     | ffmpeg                                              | can record and splice video and audio on the command line.                                                                                       |
| M@     | maim                                                | is utility to take a screenshot using imlib2.                                                                                                    |
| M@     | clang                                               | is a C/C++/Objective C/CUDA compiler based on LLVM.                                                                                              |
| M@     | npm                                                 | is the official package manager for node.js.                                                                                                     |
| M@     | nodejs                                              | is a JavaScript runtime environment combined with useful libraries.                                                                              |
| M@     | gnome-keyring                                       | serves as the system keyring.                                                                                                                    |
| M@     | xdotool                                             | is command-line X11 automation tool.                                                                                                             |
| M@     | bc                                                  | is an arbitrary precision calculator language.                                                                                                   |
| M@     | neovim                                              | is a tidier vim with some useful features.                                                                                                       |
| M@     | xcape                                               | configures modifier keys to act as other keys when pressed and released on their own.                                                            |
| M@     | mpd                                                 | is a lightweight music daemon.                                                                                                                   |
| M@     | man-db                                              | lets you read man pages of programs.                                                                                                             |
| M@     | pacman-contrib                                      | contains contributed scripts and tools for pacman systems.                                                                                       |
| M@     | noto-fonts-emoji                                    | is an emoji font.                                                                                                                                |
| M@     | pulseaudio                                          | is a general purpose sound server intended to run as a middleware between your applications and your hardware devices, either using ALSA or OSS. |
| M@     | pulseaudio-alsa                                     | is the audio system.                                                                                                                             |
| M@     | alsa-utils                                          | contains (among other utilities) the alsamixer and amixer utilities                                                                              |
| M@     | numlockx                                            | turns on the numlock key in X11.                                                                                                                 |
| M@     | ripgrep                                             | is a search tool that combines the usability of ag with the raw speed of grep.                                                                   |
| M@     | openssh                                             | is a set of computer programs providing encrypted communication sessions over a computer network using the Secure Shell (SSH) protocol.          |
| M@     | xclip                                               | allows for copying and pasting from the command line.                                                                                            |
| M@     | youtube-dl                                          | can download any YouTube video (or playlist or channel) when given the link.                                                                     |
| M@     | xorg-xbacklight                                     | enables changing screen brightness levels.                                                                                                       |
| M@     | zsh                                                 | is a powerful shell that operates as both an interactive shell and as a scripting language interpreter.                                          |
| M@     | zsh-completions                                     | for additional completion definitions.                                                                                                           |
| M@     | zsh-syntax-highlighting                             | provides syntax highlighting in the shell.                                                                                                       |
| M@     | ibus                                                | is an input method framework, a system for entering non-Latin characters.                                                                        |
| M@     | ttf-liberation                                      | is a font.                                                                                                                                       |
| M@     | ttf-font-awesome                                    | is for awesome icons.                                                                                                                            |
| M@     | noto-fonts                                          | is google noto font.                                                                                                                             |
| M@     | xdg-user-dirs                                       | is a tool to help manage "well known" user directories like the desktop folder and the music folder.                                             |
| M      | arandr                                              | is a UI for screen adjustment.                                                                                                                   |
| M      | highlight                                           | is a fast and flexible source code highlighter (CLI version).                                                                                    |
| M      | dosfstools                                          | allows your computer to access dos-like filesystems.                                                                                             |
| M      | ttf-linux-libertine                                 | provides the sans and serif fonts.                                                                                                               |
| M      | sxiv                                                | is a minimalist image viewer.                                                                                                                    |
| M      | htop                                                | is an interactive process viewer.                                                                                                                |
| M      | pcmanfm                                             | is an extremely fast and lightweight file manager.                                                                                               |
| M      | mpc                                                 | is a terminal interface for mpd.                                                                                                                 |
| M      | mpv                                                 | is the patrician's choice video player.                                                                                                          |
| M      | calcurse                                            | is a lightweight terminal-based calendar.                                                                                                        |
| M      | pavucontrol                                         | is a graphical pulseaudio volume controller.                                                                                                     |
| M      | ncmpcpp                                             | is a ncurses interface for music with multiple formats and a powerful tag editor.                                                                |
| M      | unrar                                               | extracts rar's.                                                                                                                                  |
| M      | unzip                                               | unzips zips.                                                                                                                                     |
| M      | wget                                                | is a free software package for retrieving files using HTTP, HTTPS, FTP and FTPS.                                                                 |
| M      | python-pip                                          | is PyPA recommended tool for installing Python packages.                                                                                         |
| M      | lxappearance                                        | is feature-rich GTK+ theme switcher of the LXDE Desktop.                                                                                         |
| M      | deepin-gtk-theme                                    | is Deepin GTK theme.                                                                                                                             |
| M      | deepin-icon-theme                                   | is Deepin icon theme.                                                                                                                            |
| M      | qutebrowser                                         | is a minimal web browser.                                                                                                                        |
| M      | shotcut                                             | is a simple video editor.                                                                                                                        |
| M      | adobe-source-han-sans-kr-fonts                      | is Korean OpenType/CFF font.                                                                                                                     |
| M      | adobe-source-han-sans-jp-fonts                      | is Japanese OpenType/CFF font.                                                                                                                   |
| M      | adobe-source-han-sans-cn-fonts                      | is Simplified Chinese OpenType/CFF Sans font.                                                                                                    |
| M      | adobe-source-han-sans-tw-fonts                      | is Traditional Chinese OpenType/CFF Sans font.                                                                                                   |
| M      | adobe-source-han-serif-cn-fonts                     | is Simplified Chinese OpenType/CFF Serif font.                                                                                                   |
| M      | adobe-source-han-serif-tw-fonts                     | is Traditional Chinese OpenType/CFF Serif font.                                                                                                  |
| A@     | microsoft-edge-dev-bin                              | is Microsoft Edge browser.                                                                                                                       |
| A@     | notify-osd-git                                      | is a patched notify-osd.                                                                                                                         |
| A@     | srfetch                                             | is a modified neofetch script for SARS.                                                                                                          |
| A@     | picom-jonaburg-git                                  | is for transparency and removing screen-tearing.                                                                                                 |
| A@     | light-git                                           | is a program that can easily change brightness on backlight-controllers.                                                                         |
| A@     | ttf-ms-fonts                                        | is core TTF Fonts from Microsoft.                                                                                                                |
| A@     | starship                                            | is a minimal, blazing-fast, and infinitely customizable prompt for any shell.                                                                    |
| A      | lf                                                  | is a terminal file manager inspired by ranger written in Go.                                                                                     |
| A      | screenkey-git                                       | is a screencast tool to display your keys on the screen.                                                                                         |
| A      | bamboo-ibus-git                                     | is a Vietnamese IME for ibus.                                                                                                                    |
| Z@     | https://gitlab.com/justanoobcoder/dwm-syaoran       | is a patched dwm (dynamic window manager) build.                                                                                                 |
| Z@     | https://gitlab.com/justanoobcoder/st-syaoran        | is a patched st (suckless/simple terminal) build.                                                                                                |
| Z@     | https://gitlab.com/justanoobcoder/dwmblocks-syaoran | is dwm clickable status bar like i3blocks.                                                                                                       |
| Z@     | https://gitlab.com/justanoobcoder/dmenu-syaoran     | is a dynamic menu for X, originally designed for dwm. It manages large numbers of user-defined menu items efficiently.                           |
