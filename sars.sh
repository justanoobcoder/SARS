#!/bin/bash

### CHECK ROOT PERMISSION ###

[ $EUID -ne 0 ] && echo "Permission denied!
Run this script as user root." && exit

### VARIABLES ###

config="https://gitlab.com/justanoobcoder/my-config.git"
packagelist="https://gitlab.com/justanoobcoder/SARS/-/raw/master/README.md"
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
    dialog --title "Welcome!" --msgbox "Welcome to SARS - Syaoran's Arch Ricing Script!\\n\\nThis script is based on Luke Smith's LARBS.\\nThis script will automatically install and setup a fully-featured Arch linux desktop, which I use as my main machine." 10 60
    dialog --title "Attention" --yes-label "Next" --no-label "Exit" --yesno "This script will install and set up dwm-syaoran (my suckless's dwm build). Alsa it will overwrite all your config files, so if you don't want to continue then choose < Exit > to exit this script." 8 80 || { clear; exit; }
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
    dialog --infobox "Installing \"$1\", an AUR helper..." 4 50
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
    curl -Ls "$packagelist" |  eval grep "\|" | sed '1,2d;s/ | /,/g;s/| //g;s/ |//g' > /tmp/package.list
    total=$(wc -l < /tmp/package.list)
    aurinstalled=$(pacman -Qqm)
    while IFS=, read -r tag program comment; do
        n=$((n+1))
        case "$tag" in
            "M") maininstall "$program" "$comment" ;;
            "A") aurinstall "$program" "$comment" ;;
            "G") gitmakeinstall "$program" "$comment" ;;
            "Z") zipmakeinstall "$program" "$comment" ;;
            "P") pipinstall "$program" "$comment" ;;
        esac
    done < /tmp/package.list
}

downloadconfig() {
    dialog --infobox "Downloading and installing config files..." 4 60
    dir=$(mktemp -d)
    [ ! -d "$2" ] && mkdir -p "$2"
    chown -R "$username":"$username" "$dir" "$2"
    sudo -u "$username" git clone --recursive -b master --depth 1 "$1" "$dir" >/dev/null 2>&1
    sudo -u "$username" cp -rfT "$dir" "$2"
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
EndSection'
}

createdirs() {
    cd "/home/$username"
    sudo -u "$username" mkdir -p user/{downloads,documents,music,videos/screencast,pictures/{wallpapers,screenshots}}
}

finalize(){
    dialog --title "All done!" --msgbox "Congrats! If you see this dialog then the installation gave no errors, the script completed successfully and all the programs and configuration files should be in place.\\n\\nTo run the new graphical environment, log out and log back in as your new user. Enjoy!" 12 80
}

### MAIN FUNCTION ###

main() {
    # Install dialog.
    echo "Installing dialog package." && pacmaninstall dialog || error "Are you sure you have an internet connection?"

    # Welcome user.
    welcomemsg || error "User exited."

    # Get and verify username and password.
    getuserandpass || error "User exited."

    # Last chance for user to back out before install.
    preinstallmsg || error "User exited."

    # Add user and password if not exist.
    [ "$user_exist" != "true" ] && { adduserandpass || error "Error adding username and/or password."; }

    # Create repository directory
    repodir="/home/$username/user/work/repo" && mkdir -p "$repodir" && chown -R "$username":"$username" $(dirname "$repodir")

    # Refresh Arch keyrings.
    refreshkeys || error "Error automatically refreshing Arch keyring. Consider doing so manually."

    dialog --title "SARS Installation" --infobox "Installing \`basedevel\` and \`git\` for installing other software required for the installation of other programs." 5 70
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

    # Install all packages in packagelist.
    installationloop

    # Install libxft-bgra. This is important package for suckless programs like dwm or st, they will crash without it.
    dialog --title "SARS Installation" --infobox "Finally, installing \`libxft-bgra\` to enable color emoji in suckless software without crashes." 5 70
    pacman -Q libxft-bgra >/dev/null 2>&1 || yes | sudo -u "$username" $aurhelper -S libxft-bgra >/dev/null 2>&1

    # Download config files and put them in home directory.
    downloadconfig "$config" "/home/$username" master

    # Most important command! Get rid of the beep!
    systembeepoff

    # Make zsh the default shell for the user.
    chsh -s /bin/zsh $username >/dev/null 2>&1
    sudo -u "$username" mkdir -p "/home/$username/.cache/zsh/"

    appendsudoers "
    %wheel ALL=(ALL) NOPASSWD: /usr/bin/shutdown,/usr/bin/reboot,/usr/bin/systemctl suspend,/usr/bin/systemctl hibernate,/usr/bin/systemctl suspend-then-hibernate,/usr/bin/mount,/usr/bin/umount,/usr/bin/pacman,/usr/bin/systemctl restart NetworkManager,/usr/bin/yay,/usr/bin/make
    Defaults editor=/usr/bin/nvim"

    # Create user's directories
    createdirs

    # Last message! Install complete!
    finalize

    clear
}

main
