#!/bin/bash

### CHECK ROOT PERMISSION ###

[ $EUID -ne 0 ] && echo -e "Permission denied!\nRun this script as root" && exit

### VARIABLES ###

dotfiles="https://gitlab.com/justanoobcoder/dotfiles.git"
packageslist="https://gitlab.com/justanoobcoder/SARS/-/raw/master/README.md"
aurhelper="yay"

### FUNCTIONS ###

error() { clear ; echo "ERROR: $1" ; exit; }

pacman_install() {
    while [ -n "$1" ]; do
        pacman -S "$1" --noconfirm --needed >/dev/null 2>&1
        shift
    done
}

greeting() {
    dialog --title "SARS Installation" --yes-label "Next" --no-label "Exit" --yesno "Welcome to SARS - Syaoran's Arch Ricing Script!\\nThis script will help you install and setup a full-featured Arch linux desktop, which I use as my main machine.\\n\\nIt will overwrite all your config files, so think carefully. Choose < Exit > to exit this script or < Next > to continue." 10 80 || { clear; exit; }
}

get_username_pw() {
    [ "$(ls /home | wc -l)" = "1" ] && def_user="$(ls /home)"
    username=$(dialog --title "SARS Installation" --inputbox "Enter username.\\nIt will create a new user if that user doesn't exist." 10 60 "$def_user" 3>&1 1>&2 2>&3 3>&1) || exit
    while ! echo "$username" | grep "^[a-z_][a-z0-9_-]*$" >/dev/null 2>&1; do
        username=$(dialog --title "SARS Installation" --no-cancel --inputbox "This username is not valid. Give username beginning with a letter, with only lowercase letters, - or _" 10 60 3>&1 1>&2 2>&3 3>&1)
    done
    id -u "$username" >/dev/null 2>&1 && user_exist="true" || {
    pass1=$(dialog --title "SARS Installation" --no-cancel --insecure --passwordbox "Enter $username's password." 10 60 3>&1 1>&2 2>&3 3>&1);
    pass2=$(dialog --title "SARS Installation" --no-cancel --insecure --passwordbox "Retype password." 10 60 3>&1 1>&2 2>&3 3>&1);
    while ! [ "$pass1" = "$pass2" ]; do
        unset pass2
        pass1=$(dialog --title "SARS Installation" --no-cancel --insecure --passwordbox "Passwords do not match.\\n\\nEnter password again." 10 60 3>&1 1>&2 2>&3 3>&1)
        pass2=$(dialog --title "SARS Installation" --no-cancel --insecure --passwordbox "Retype password." 10 60 3>&1 1>&2 2>&3 3>&1)
    done ; }
}

get_option() {
    curl -Ls "$packageslist" | sed 's/  */ /g' | eval grep "\|" | sed '1,2d;s/ | /,/g;s/| //g;s/ |//g' > /tmp/temp.list
    choice="$(dialog --title "SARS Installation" --menu "Choose one of these options:" 0 0 0 1 "Full installation (recommend)" 2 "Minimal installation" 3 "Custom installation" 3>&1 1>&2 2>&3 3>&1)"
    [ -f /tmp/packages.list ] && rm /tmp/packages.list
    case "$choice" in
        "1")
            cp /tmp/temp.list /tmp/packages.list ;;
        "2")
            while IFS=, read -r source program comment; do
                n=$((n+1))
                [ "${source#?}" = "@" ] && sed -n "${n}p" /tmp/temp.list >> /tmp/packages.list
            done < /tmp/temp.list
            unset n
            ;;
        "3")
            dialog --title "SARS Installation" --msgbox "There are some packages which are selected by default. Those are important packages for SARS. DO NOT uncheck them!\nUse arrow keys to move the pointer. Press Space bar to check/uncheck package." 10 50
            [ -f /tmp/options.list ] && rm /tmp/options.list
            while IFS=, read -r source program comment; do
                n=$((n+1))
                [ "${source#?}" = "@" ] && echo "$n $program on" >> /tmp/options.list || echo "$n $program off" >> /tmp/options.list
            done < /tmp/temp.list
            checklist=(dialog --title "SARS Installation" --separate-output --checklist "Select packages that you want to install.\nChoose <Cancel> to go back." 0 0 0)
            [ -z "$checklist" ] && userchoice
            options=(`cat /tmp/options.list`)
            selections=$("${checklist[@]}" "${options[@]}" 3>&1 1>&2 2>&3 3>&1)
            for selection in $selections
            do
                sed -n "${selection}p" /tmp/temp.list >> /tmp/packages.list
            done
            unset n
            ;;
    esac
}

last_waring() {
    dialog --title "SARS Installation" --yes-label "Next" --no-label "Exit" --yesno "Last chance for you to quit SARS. Choose < Exit > to exit this script.\\n\\nFrom now on, the installation will be automated, it won't ask for any input so you can sit back, have some coffee and relax.\\n\\nIt will take some time, but when done, you can relax even more with your complete system.\\n\\nNow just press < Next > and the installation will begin!" 13 80 || { clear; exit; }
}

add_user_pw() {
    dialog --title "SARS Installation" --infobox "Adding user \"$username\"..." 4 50
    useradd -m -G wheel,audio,video,optical,storage,power -s /bin/bash "$username" >/dev/null 2>&1 ||
    usermod -aG wheel,audio,video,optical,storage,power "$username" && mkdir -p /home/"$username" && chown "$username":"$username" /home/"$username"
    echo "$username:$pass1" | chpasswd
    unset pass1 pass2
}

refresh_keys() {
    dialog --title "SARS Installation" --infobox "Refreshing Arch Keyring..." 4 40
    pacman --noconfirm -Sy archlinux-keyring >/dev/null 2>&1
}

install_dependencies() {
    dialog --title "SARS Installation" --infobox "Installing \`base-devel\` and \`git\` for installing other software required for the installation of other programs." 5 70
    pacman_install base-devel git
}

append_sudoers() {
    sed -i "/#SARS/d" /etc/sudoers
    echo "$* #SARS" >> /etc/sudoers
}

install_aurhelper() {
    [ -f "/usr/bin/$1" ] || {
    dialog --title "SARS Installation" --infobox "Installing \`$1\` - an AUR helper..." 4 50
    cd /tmp || exit
    rm -rf /tmp/"$1"
    sudo -u "$username" git clone https://aur.archlinux.org/"$1".git >/dev/null 2>&1 &&
    cd "$1" &&
    sudo -u "$username" makepkg --noconfirm -si >/dev/null 2>&1
    cd /tmp || return; }
}

maininstall() {
    dialog --title "SARS Installation" --infobox "Installing \`$1\` ($n of $total). $1 $2" 5 70
    pacman_install "$1"
}

gitmakeinstall() {
    progname="$(basename "$1" .git)"
    dir="$repodir/$progname"
    dialog --title "SARS Installation" --infobox "Installing \`$progname\` ($n of $total) via \`git\` and \`make\`. $progname $2" 5 70
    sudo -u "$username" git clone --depth 1 "$1" "$dir" >/dev/null 2>&1 || { cd "$dir" || return ; sudo -u "$username" git pull --force origin master;}
    cd "$dir" || exit
    make >/dev/null 2>&1
    make install >/dev/null 2>&1
    cd /tmp || return
}

zipmakeinstall() {
    progname="$(basename "$1")"
    dialog --title "SARS Installation" --infobox "Installing \`$progname\` ($n of $total) via a zip file from \`git\` and \`make\`. $progname $2" 5 70
    pacman_install unzip
    echo "$1" | grep github >/dev/null 2>&1 && \
        sudo -u "$username" curl -L "$1/archive/master.zip" -o "$repodir/${progname}.zip" >/dev/null 2>&1 || \
        sudo -u "$username" curl -L "$1/-/archive/master/${progname}-master.zip" -o "$repodir/${progname}.zip" >/dev/null 2>&1
    cd "$repodir"
    sudo -u "$username" unzip "${progname}.zip" >/dev/null 2>&1
    rm *.zip ; sudo -u "$username" mv "${progname}-master" "$progname"
    cd "$progname" || exit
    make >/dev/null 2>&1
    make install >/dev/null 2>&1
    cd /tmp || return
}

aurinstall() {
    dialog --title "SARS Installation" --infobox "Installing \`$1\` ($n of $total) from the AUR. $1 $2" 5 70
    echo "$aurinstalled" | grep "^$1$" >/dev/null 2>&1 && return
    sudo -u "$username" $aurhelper -S --noconfirm "$1" >/dev/null 2>&1
}

pipinstall() {
    dialog --title "SARS Installation" --infobox "Installing the Python package \`$1\` ($n of $total). $1 $2" 5 70
    command -v pip || pacman_install python-pip >/dev/null 2>&1
    yes | pip install "$1"
}

installation_loop() {
    total=$(wc -l < /tmp/packages.list)
    aurinstalled=$(pacman -Qqm)
    while IFS=, read -r source program comment; do
        n=$((n+1))
        case "${source:0:1}" in
            "M") maininstall "$program" "$comment" ;;
            "A") aurinstall "$program" "$comment" ;;
            "G") gitmakeinstall "$program" "$comment" ;;
            "Z") zipmakeinstall "$program" "$comment" ;;
            "P") pipinstall "$program" "$comment" ;;
        esac
    done < /tmp/packages.list
}

install_libxftbgra() {
    dialog --title "SARS Installation" --infobox "Finally, installing \`libxft-bgra-git\` to enable color emoji in suckless softwares without crashes." 5 70
    n=1
    while true
    do
        pacman -Q libxft-bgra-git >/dev/null 2>&1 && break || yes | sudo -u "$username" $aurhelper -S libxft-bgra-git >/dev/null 2>&1
        [ $n -eq 3 ] && error "Can't install libxft-bgra-git from AUR!"
        n=$((n+1))
    done
}

download_config() {
    dialog --title "SARS Installation" --infobox "Downloading config files..." 4 40
    dir=$(mktemp -d)
    [ ! -d "$2" ] && mkdir -p "$2"
    chown -R "$username":"$username" "$dir" "$2"
    sudo -u "$username" git clone --recursive -b master --depth 1 "$1" "$dir" >/dev/null 2>&1
    sudo -u "$username" cp -rfT "$dir" "$2"
}

neovim() {
    # Dependencies
    dialog --title "Neovim" --infobox "Downloading and installing dependencies..." 4 50
    pacman_install neovim nodejs npm python-pip
    pip3 install pynvim >/dev/null 2>&1
    sudo -u "$username" npm i -g neovim >/dev/null 2>&1
    # Plugins
    dialog --title "Neovim" --infobox "Downloading and installing plugins..." 4 50
    sudo -u "$username" mv /home/$username/.config/nvim/init.vim /home/$username/.config/nvim/init.vim.tmp
    echo "source ~/.config/nvim/vim-plugins.vim" > /home/$username/.config/nvim/init.vim
    chown -R "$username":"$username" /home/$username/.config/nvim/init.vim
    sudo -u "$username" nvim --headless +PlugInstall +qall > /dev/null 2>&1
    sudo -u "$username" mv /home/$username/.config/nvim/init.vim.tmp /home/$username/.config/nvim/init.vim
    [ -d /home/$username/.npm ] && rm -rf /home/$username/.npm
}

ch_shell_zsh() {
    [ -d /etc/zsh ] || mkdir -p /etc/zsh
    echo 'export ZDOTDIR="$HOME/.config/zsh"' > /etc/zsh/zshenv
    chsh -s /bin/zsh $username >/dev/null 2>&1
    sudo -u "$username" mkdir -p "/home/$username/.cache/zsh/"
    rm /home/$username/.bash*
}

snapper_for_btrfs() {
    dialog --title "SARS Installation" --infobox "\nInstalling and configuring snapper..." 5 45
    if cat /etc/fstab | grep btrfs > /dev/null; then
        pacman_install snapper
        if [ -d /.snapshots ]; then
            if mount | grep /.snapshots > /dev/null; then
                umount /.snapshots
            fi
            rm -rf /.snapshots
        fi
        snapper -c root create-config /
        sed -i "s/ALLOW_USERS=\"\"/ALLOW_USERS=\"$username\"/g" /etc/snapper/configs/root
        chmod a+rx /.snapshots
        systemctl enable --now snapper-timeline.timer > /dev/null 2>&1
        systemctl enable --now snapper-cleanup.timer > /dev/null 2>&1
    fi
}

custom_grub() {
    dialog --title "SARS Installation" --infobox "\nCustomizing grub..." 5 30
    sed -i "s/#GRUB_THEME.*/GRUB_THEME=\/home\/$username\/.local\/share\/sars\/grub\/themes\/Tela\/theme.txt/g" /etc/default/grub
    if cat /etc/fstab | grep btrfs >/dev/null; then
        pacman_install grub-btrfs
        systemctl enable --now grub-btrfs.path > /dev/null 2>&1
    fi
    grub-mkconfig -o /boot/grub/grub.cfg > /dev/null 2>&1
}

touchpad() {
    dialog --yes-label "Yes" --no-label "No" --yesno "Is your machine a laptop with touchpad?" 5 45 || return
    echo 'Section "InputClass"
    Identifier "devname"
    Driver "libinput"

	Option "Tapping" "on"
EndSection' > /etc/X11/xorg.conf.d/30-touchpad.conf
}

createdirs() {
    cd "/home/$username"
    sudo -u "$username" mkdir -p .config/gtk-2.0 user/{downloads,documents,music,videos/screencast,pictures/screenshots}
}

last_message(){
    dialog --title "SARS Installation" --msgbox "Congrats! If you see this dialog then the installation gave no errors, the script completed successfully and all the programs and configuration files should be in place. Enjoy!" 8 60
}

main() {
    # Install dependencies
    echo "Installing dependencies..." && pacman_install dialog curl || error "Are you sure you have an internet connection?"

    # Greeting dialog
    greeting

    # Get username and password
    get_username_pw

    # Get option
    get_option

    # Last warning before the installation
    last_waring

    # Add user and password if not exist.
    [ "$user_exist" != "true" ] && { add_user_pw || error "Can't add username and password."; }

    # Create repo directory
    repodir="/home/$username/user/work/repo" && mkdir -p "$repodir" && chown -R "$username":"$username" $(dirname "$repodir")

    # Refresh Arch keyrings.
    refresh_keys || error "Error automatically refreshing Arch keyring. Consider doing so manually."

    # Install dependencies
    install_dependencies || error "Can't install dependencies."

    # Allow user to run sudo without password. Since AUR programs must be installed
    #in a fakeroot environment, this is required for all builds with AUR.
    append_sudoers "%wheel ALL=(ALL) NOPASSWD: ALL"

    # Make pacman and yay colorful and adds eye candy on the progress bar because why not.
    grep "^Color" /etc/pacman.conf >/dev/null || sed -i "s/^#Color$/Color/" /etc/pacman.conf
    grep "ILoveCandy" /etc/pacman.conf >/dev/null || sed -i "/#VerbosePkgLists/a ILoveCandy" /etc/pacman.conf

    # Use all cores for compilation.
    sed -i "s/-j2/-j$(nproc)/;s/^#MAKEFLAGS/MAKEFLAGS/" /etc/makepkg.conf

    # Install AUR helper
    install_aurhelper "$aurhelper" || error "Can't install $aurhelper."

    # Install all packages in packageslist.
    installation_loop

    # Install libxft-bgra. This is important package for suckless programs like dwm or st, they will crash without it.
    install_libxftbgra

    # Download dotfiles and put them in home directory.
    download_config "$dotfiles" "/home/$username" master

    # Download and configure neovim
    neovim

    # Change default shell to zsh
    ch_shell_zsh

    # Custom sudoers file
    append_sudoers "
%wheel ALL=(ALL) NOPASSWD: /usr/bin/shutdown,/usr/bin/reboot,/usr/bin/systemctl suspend,/usr/bin/systemctl hibernate,/usr/bin/systemctl suspend-then-hibernate,/usr/bin/mount,/usr/bin/umount,/usr/bin/pacman,/usr/bin/systemctl restart NetworkManager,/usr/bin/yay,/usr/bin/make
Defaults editor=/usr/bin/nvim"

    # Start/Restart pulseaudio
    pidof pulseaudio >/dev/null 2>&1 && killall pulseaudio; sudo -u "$username" pulseaudio --start

    # Time
    timedatectl set-ntp true
    timedatectl set-local-rtc 1 --adjust-system-clock

    # Snapper
    snapper_for_btrfs || error "Can't install or configure snapper."

    # Customize grub
    custom_grub || error "Can't customize grub."

    # Create user's directories
    createdirs

    # Remove go folder in home
    [ -d "/home/$username/go" ] && rm -rf "/home/$username/go"

    # Touchpad tap to click
    touchpad

    # Remove gitrestore script if username is not syaoran
    [ "$username" != "syaoran" ] && rm /home/$username/.local/bin/gitrestore

    # Last message! Install complete!
    last_message

    clear
}

### RUN MAIN FUNCTION ###

main

exit 0
