#!/bin/bash

### CHECK ROOT PERMISSION ###

[ $EUID -ne 0 ] && echo "Permission denied!
Run this script as user root." && exit

### VARIABLES ###

dotfiles="https://gitlab.com/justanoobcoder/dotfiles.git"
packageslist="https://gitlab.com/justanoobcoder/SARS/-/raw/master/README.md"
aurhelper="yay"

### FUNCTIONS ###

error() {
    clear
    printf "ERROR:\\n%s\\n" "$1"
    exit
}

pacmaninstall() {
    pacman -S "$1" --noconfirm --needed >/dev/null 2>&1
}

welcomemsg() {
    dialog --title "Welcome!" --msgbox "Welcome to SARS - Syaoran's Arch Ricing Script!\\n\\nThis script is based on Luke Smith's LARBS.\\nThis script will automatically install and setup a full-featured Arch linux desktop, which I use as my main machine." 10 60
    dialog --title "Attention[!]" --yes-label "Next" --no-label "Exit" --yesno "This script will install and set up dwm-syaoran (my suckless's dwm build). Alsa it will overwrite all your config files, so if you don't want to continue then choose < Exit > to exit this script." 8 80 || { clear; exit; }
}

getuserandpass() {
    username=$(dialog --inputbox "Enter a name for the user account. You can enter a user name that already exists or doesn't exist yet. It will create a new user if that user doesn't exist." 10 60 3>&1 1>&2 2>&3 3>&1) || exit
    while ! echo "$username" | grep "^[a-z_][a-z0-9_-]*$" >/dev/null 2>&1; do
        username=$(dialog --no-cancel --inputbox "Username not valid. Give a username beginning with a letter, with only lowercase letters, - or _" 10 60 3>&1 1>&2 2>&3 3>&1)
    done
    id -u "$username" >/dev/null 2>&1 && user_exist="true" || {
    pass1=$(dialog --no-cancel --passwordbox "Enter a password for that user." 10 60 3>&1 1>&2 2>&3 3>&1);
    pass2=$(dialog --no-cancel --passwordbox "Retype password." 10 60 3>&1 1>&2 2>&3 3>&1);
    while ! [ "$pass1" = "$pass2" ]; do
        unset pass2
        pass1=$(dialog --no-cancel --passwordbox "Passwords do not match.\\n\\nEnter password again." 10 60 3>&1 1>&2 2>&3 3>&1)
        pass2=$(dialog --no-cancel --passwordbox "Retype password." 10 60 3>&1 1>&2 2>&3 3>&1)
    done ; }
}

userchoice() {
    curl -Ls "$packageslist" | sed 's/  */ /g' | eval grep "\|" | sed '1,2d;s/ | /,/g;s/| //g;s/ |//g' > /tmp/temp.list
    choice="$(dialog --title "Option" --menu "Choose one of these options:" 0 0 0 1 "Full installation (recommend)" 2 "Minimal installation" 3 "Custom installation" 3>&1 1>&2 2>&3 3>&1)"
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
            dialog --title "Attention[!]" --msgbox "There are some packages which are selected by default. Those are important packages for SARS. DO NOT uncheck them!\nUse arrow keys to move the pointer. Press Space bar to check/uncheck package." 10 50
            [ -f /tmp/options.list ] && rm /tmp/options.list
            while IFS=, read -r source program comment; do
                n=$((n+1))
                [ "${source#?}" = "@" ] && echo "$n $program on" >> /tmp/options.list || echo "$n $program off" >> /tmp/options.list
            done < /tmp/temp.list
            checklist=(dialog --separate-output --checklist "Select packages that you want to install.\nChoose <Cancel> to go back." 0 0 0)
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

preinstallmsg() {
    dialog --title "Note" --yes-label "Next" --no-label "Exit" --yesno "From now on, the installation will be automated, it won't ask for any input so you can sit back, have some coffee and relax.\\n\\nIt will take some time, but when done, you can relax even more with your complete system.\\n\\nNow just press < Next > and the system will begin installation!" 13 60 || { clear; exit; }
}

adduserandpass() {
    dialog --infobox "Adding user \"$username\"..." 4 50
    useradd -m -G wheel,audio,video,optical,storage -s /bin/bash "$username" >/dev/null 2>&1 ||
    usermod -aG wheel,audio,video,optical,storage "$username" && mkdir -p /home/"$username" && chown "$username":"$username" /home/"$username"
    echo "$username:$pass1" | chpasswd
    # Unset password variables after applying password
    unset pass1 pass2
}

refreshkeys() { \
    dialog --infobox "Refreshing Arch Keyring..." 4 40
    pacman --noconfirm -Sy archlinux-keyring >/dev/null 2>&1
}

appendsudoers() {
    sed -i "/#SARS/d" /etc/sudoers
    echo "$* #SARS" >> /etc/sudoers
}

maininstall() {
    dialog --title "SARS Installation" --infobox "Installing \`$1\` ($n of $total). $1 $2" 5 70
    pacmaninstall "$1"
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
    pacmaninstall unzip
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

manualinstall() {
    [ -f "/usr/bin/$1" ] || (
    dialog --title "SARS Installation" --infobox "Installing \`$1\`, an AUR helper..." 4 50
    cd /tmp || exit
    rm -rf /tmp/"$1"*
    curl -sO https://aur.archlinux.org/cgit/aur.git/snapshot/"$1".tar.gz &&
    sudo -u "$username" tar -xvf "$1".tar.gz >/dev/null 2>&1 &&
    cd "$1" &&
    sudo -u "$username" makepkg --noconfirm -si >/dev/null 2>&1
    cd /tmp || return)
}

aurinstall() {
    dialog --title "SARS Installation" --infobox "Installing \`$1\` ($n of $total) from the AUR. $1 $2" 5 70
    echo "$aurinstalled" | grep "^$1$" >/dev/null 2>&1 && return
    sudo -u "$username" $aurhelper -S --noconfirm "$1" >/dev/null 2>&1
}

pipinstall() {
    dialog --title "SARS Installation" --infobox "Installing the Python package \`$1\` ($n of $total). $1 $2" 5 70
    command -v pip || pacmaninstall python-pip >/dev/null 2>&1
    yes | pip install "$1"
}

installationloop() {
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

downloadconfig() {
    dialog --infobox "Downloading and installing config files..." 4 60
    dir=$(mktemp -d)
    [ ! -d "$2" ] && mkdir -p "$2"
    chown -R "$username":"$username" "$dir" "$2"
    sudo -u "$username" git clone --recursive -b master --depth 1 "$1" "$dir" >/dev/null 2>&1
    sudo -u "$username" cp -rfT "$dir" "$2"
}

neovim() {
    # Dependencies
    dialog --title "Neovim" --infobox "Downloading and installing dependencies..." 4 50
    pacmaninstall neovim
    pacmaninstall nodejs
    pacmaninstall npm
    pacmaninstall python-pip
    pip3 install pynvim >/dev/null 2>&1
    sudo -u "$username" npm i -g neovim >/dev/null 2>&1
    # Plugins
    dialog --title "Neovim" --infobox "Downloading and installing plugins..." 4 50
    sudo -u "$username" mv /home/$username/.config/nvim/init.vim /home/$username/.config/nvim/init.vim.tmp
    echo "source ~/.config/nvim/vim-plugins.vim" > /home/$username/.config/nvim/init.vim
    chown -R "$username":"$username" /home/$username/.config/nvim/init.vim
    sudo -u "$username" nvim --headless +PlugInstall +qall > /dev/null 2>&1
    sudo -u "$username" mv /home/$username/.config/nvim/init.vim.tmp /home/$username/.config/nvim/init.vim
}

systembeepoff() {
    dialog --infobox "Getting rid of that retarded error beep sound..." 10 50
    rmmod pcspkr
    echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf
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

finalmsg(){
    dialog --title "All done!" --msgbox "Congrats! If you see this dialog then the installation gave no errors, the script completed successfully and all the programs and configuration files should be in place. Enjoy!" 12 80
}

### MAIN FUNCTION ###

main() {
    # Install dialog.
    echo "Installing dialog package." && pacmaninstall dialog || error "Are you sure you have an internet connection?"

    # Welcome user.
    welcomemsg || error "User exited."

    # Get and verify username and password.
    getuserandpass || error "User exited."

    # Touchpad tap to click
    touchpad

    # Get user's install option
    userchoice || error "User exited."

    # Last chance for user to back out before install.
    preinstallmsg || error "User exited."

    # Add user and password if not exist.
    [ "$user_exist" != "true" ] && { adduserandpass || error "Error adding username and/or password."; }

    # Create repository directory
    repodir="/home/$username/user/work/repo" && mkdir -p "$repodir" && chown -R "$username":"$username" $(dirname "$repodir")

    # Refresh Arch keyrings.
    refreshkeys || error "Error automatically refreshing Arch keyring. Consider doing so manually."

    dialog --title "SARS Installation" --infobox "Installing \`base-devel\` and \`git\` for installing other software required for the installation of other programs." 5 70
    pacmaninstall curl
    pacmaninstall base-devel
    pacmaninstall git

    # Allow user to run sudo without password. Since AUR programs must be installed
    # in a fakeroot environment, this is required for all builds with AUR.
    appendsudoers "%wheel ALL=(ALL) NOPASSWD: ALL"

    # Make pacman and yay colorful and adds eye candy on the progress bar because why not.
    grep "^Color" /etc/pacman.conf >/dev/null || sed -i "s/^#Color$/Color/" /etc/pacman.conf
    grep "ILoveCandy" /etc/pacman.conf >/dev/null || sed -i "/#VerbosePkgLists/a ILoveCandy" /etc/pacman.conf

    # Use all cores for compilation.
    sed -i "s/-j2/-j$(nproc)/;s/^#MAKEFLAGS/MAKEFLAGS/" /etc/makepkg.conf

    # Install aur helper.
    manualinstall $aurhelper || error "Failed to install AUR helper."

    # Install all packages in packageslist.
    installationloop

    # Install libxft-bgra. This is important package for suckless programs like dwm or st, they will crash without it.
    dialog --title "SARS Installation" --infobox "Finally, installing \`libxft-bgra\` to enable color emoji in suckless software without crashes." 5 70
    n=1
    while true
    do
        pacman -Q libxft-bgra >/dev/null 2>&1 && break || yes | sudo -u "$username" $aurhelper -S libxft-bgra >/dev/null 2>&1
        [ $n -eq 3 ] && error "Cannot install libxft-bgra from AUR!"
        n=$((n+1))
    done

    # Download dot files and put them in home directory.
    downloadconfig "$dotfiles" "/home/$username" master

    # Download and configure neovim
    neovim

    # Most important command! Get rid of the beep!
    systembeepoff

    # Make zsh the default shell for the user.
    [ -d /etc/zsh ] || mkdir -p /etc/zsh
    echo 'export ZDOTDIR="$HOME/.config/zsh"' > /etc/zsh/zshenv
    chsh -s /bin/zsh $username >/dev/null 2>&1
    sudo -u "$username" mkdir -p "/home/$username/.cache/zsh/"
    rm /home/$username/.bash*

    appendsudoers "
%wheel ALL=(ALL) NOPASSWD: /usr/bin/shutdown,/usr/bin/reboot,/usr/bin/systemctl suspend,/usr/bin/systemctl hibernate,/usr/bin/systemctl suspend-then-hibernate,/usr/bin/mount,/usr/bin/umount,/usr/bin/pacman,/usr/bin/systemctl restart NetworkManager,/usr/bin/yay,/usr/bin/make
Defaults editor=/usr/bin/nvim"

    # Start/Restart pulseaudio
    pidof pulseaudio >/dev/null 2>&1 && killall pulseaudio; sudo -u "$name" pulseaudio --start

    # Time
    timedatectl set-ntp true

    # Customize grub
    dialog --title "SARS Installation" --infobox "\nCustomizing grub..." 5 30
    sed -i "s/#GRUB_THEME.*/GRUB_THEME=\/home\/$username\/.local\/share\/sars\/grub\/themes\/Tela\/theme.txt/g" /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg >/dev/null 2>&1

    # Create user's directories
    createdirs

    # Remove go folder in home
    [ -d "/home/$username/go" ] && rm -rf "/home/$username/go"

    # Last message! Install complete!
    finalmsg

    # Reboot
    dialog --title "SARS Installation" --yesno "Do you want to reboot now?" 0 0 && reboot

    clear
}

main
