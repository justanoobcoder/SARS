#!/bin/bash

[ $EUID != 0 ] && echo -e "Permission denied!
Run this script as root" && exit

### OPTIONS AND VARIABLES ###

while getopts ":a:h" o; do case "${o}" in
	h) printf "Optional arguments:\\n  -a: AUR helper\\n  -h: Show this message\\n" && exit ;;
	a) aurhelper=${OPTARG} ;;
	*) printf "Invalid option: -%s\\n" "$OPTARG" && exit ;;
esac done

dotfilesrepo="https://gitlab.com/justanoobcoder/my-config.git"
repobranch="master"
progsfile="https://gitlab.com/justanoobcoder/SALAS/-/raw/master/progs.csv"
[ -z "$aurhelper" ] && aurhelper="yay"
grepseq="\"^[PGAZ]*,\""

### FUNCTIONS ###

installpkg(){ pacman --noconfirm --needed -S "$1" >/dev/null 2>&1 ;}

error() { clear; printf "ERROR:\\n%s\\n" "$1"; exit;}

welcomemsg() { 
	dialog --title "Welcome!" --msgbox "Welcome to SALAS - Syaoran's Arch Linux Auto Setup!\\n\\nThis script will automatically install a fully-featured Linux desktop, which I use as my main machine." 10 60
    dialog --title "Attention" --yes-label "Next" --no-label "Exit" --yesno "This script sets up dwm-syaoran (my suckless's dwm build). So if you use other WM or DE then choose <Exit> to exit this script." 8 80 || { clear; exit; }
}

getuserandpass() { 
	# Prompts user for new username an password.
	name=$(dialog --inputbox "First, please enter a name for the user account." 10 60 3>&1 1>&2 2>&3 3>&1) || exit
	while ! echo "$name" | grep "^[a-z_][a-z0-9_-]*$" >/dev/null 2>&1; do
		name=$(dialog --no-cancel --inputbox "Username not valid. Give a username beginning with a letter, with only lowercase letters, - or _." 10 60 3>&1 1>&2 2>&3 3>&1)
	done
	id -u "$name" >/dev/null 2>&1 && user_exist="true" && repodir="/home/$name/user/Workspace/repo" && mkdir -p "$repodir" && chown -R "$name":"$name" $(dirname "$repodir") || {
	pass1=$(dialog --no-cancel --passwordbox "Enter a password for that user." 10 60 3>&1 1>&2 2>&3 3>&1);
	pass2=$(dialog --no-cancel --passwordbox "Retype password." 10 60 3>&1 1>&2 2>&3 3>&1);
	while ! [ "$pass1" = "$pass2" ]; do
		unset pass2
		pass1=$(dialog --no-cancel --passwordbox "Passwords do not match.\\n\\nEnter password again." 10 60 3>&1 1>&2 2>&3 3>&1)
		pass2=$(dialog --no-cancel --passwordbox "Retype password." 10 60 3>&1 1>&2 2>&3 3>&1)
	done ; }
}

preinstallmsg() { 
	dialog --title "Let's get this party started!" --yes-label "Let's go!" --no-label "No, nevermind!" --yesno "The rest of the installation will now be totally automated, so you can sit back and relax.\\n\\nIt will take some time, but when done, you can relax even more with your complete system.\\n\\nNow just press <Let's go!> and the system will begin installation!" 13 60 || { clear; exit; }
}

adduserandpass() { \
	# Adds user `$name` with password $pass1.
	dialog --infobox "Adding user \"$name\"..." 4 50
	useradd -m -g wheel -s /bin/bash "$name" >/dev/null 2>&1 ||
	usermod -a -G wheel "$name" && mkdir -p /home/"$name" && chown "$name":"$name" /home/"$name"
	repodir="/home/$name/user/Workspace/repo"; mkdir -p "$repodir"; chown -R "$name":"$name" $(dirname "$repodir")
	echo "$name:$pass1" | chpasswd
	unset pass1 pass2 ;
}

refreshkeys() { \
	dialog --infobox "Refreshing Arch Keyring..." 4 40
	pacman --noconfirm -Sy archlinux-keyring >/dev/null 2>&1
}

newperms() { # Set special sudoers settings for install (or after).
	#sed -i "/#SALAS/d" /etc/sudoers
	echo "$*" >> /etc/sudoers
}

maininstall() { # Installs all needed programs from main repo.
	dialog --title "SALAS Installation" --infobox "Installing \`$1\` ($n of $total). $1 $2" 5 70
	installpkg "$1"
}

gitmakeinstall() {
	progname="$(basename "$1" .git)"
	dir="$repodir/$progname"
	dialog --title "SALAS Installation" --infobox "Installing \`$progname\` ($n of $total) via \`git\` and \`make\`. $progname $2" 5 70
	sudo -u "$name" git clone --depth 1 "$1" "$dir" >/dev/null 2>&1 || { cd "$dir" || return ; sudo -u "$name" git pull --force origin master;}
	cd "$dir" || exit
	make >/dev/null 2>&1
	make install >/dev/null 2>&1
	cd /tmp || return 
}

gitzipmakeinstall() {
	progname="$(basename "$1" -master.zip)"
	zipname="$(basename "$1" .zip)"
	dialog --title "SALAS Installation" --infobox "Installing \`$progname\` ($n of $total) via a zip file from \`git\` and \`make\`. $progname $2" 5 70
    installpkg wget
    installpkg unzip
	sudo -u "$name" wget "$1" -O "$repodir/${zipname}.zip" >/dev/null 2>&1
    cd "$repodir"
    sudo -u "$name" unzip "${zipname}.zip" >/dev/null 2>&1
    rm *.zip ; sudo -u "$name" mv "$zipname" "$progname"
    cd "$progname" || exit
	make >/dev/null 2>&1
	make install >/dev/null 2>&1
	cd /tmp || return 
}

manualinstall() { # Installs $1 manually if not installed. Used only for AUR helper here.
	[ -f "/usr/bin/$1" ] || (
	dialog --infobox "Installing \"$1\", an AUR helper..." 4 50
	cd /tmp || exit
	rm -rf /tmp/"$1"*
	curl -sO https://aur.archlinux.org/cgit/aur.git/snapshot/"$1".tar.gz &&
	sudo -u "$name" tar -xvf "$1".tar.gz >/dev/null 2>&1 &&
	cd "$1" &&
	sudo -u "$name" makepkg --noconfirm -si >/dev/null 2>&1
	cd /tmp || return) 
}

aurinstall() {
	dialog --title "SALAS Installation" --infobox "Installing \`$1\` ($n of $total) from the AUR. $1 $2" 5 70
	echo "$aurinstalled" | grep "^$1$" >/dev/null 2>&1 && return
	sudo -u "$name" $aurhelper -S --noconfirm "$1" >/dev/null 2>&1
}

pipinstall() { 
	dialog --title "SALAS Installation" --infobox "Installing the Python package \`$1\` ($n of $total). $1 $2" 5 70
	command -v pip || installpkg python-pip >/dev/null 2>&1
	yes | pip install "$1"
}

installationloop() { 
	([ -f "$progsfile" ] && cp "$progsfile" /tmp/progs.csv) || curl -Ls "$progsfile" | sed '/^#/d' | eval grep "$grepseq" > /tmp/progs.csv
	total=$(wc -l < /tmp/progs.csv)
	aurinstalled=$(pacman -Qqm)
	while IFS=, read -r tag program comment; do
		n=$((n+1))
		echo "$comment" | grep "^\".*\"$" >/dev/null 2>&1 && comment="$(echo "$comment" | sed "s/\(^\"\|\"$\)//g")"
		case "$tag" in
			"A") aurinstall "$program" "$comment" ;;
			"G") gitmakeinstall "$program" "$comment" ;;
			"Z") gitzipmakeinstall "$program" "$comment" ;;
			"P") pipinstall "$program" "$comment" ;;
			*) maininstall "$program" "$comment" ;;
		esac
	done < /tmp/progs.csv
}

putgitrepo() { # Downloads a gitrepo $1 and places the files in $2 only overwriting conflicts
	dialog --infobox "Downloading and installing config files..." 4 60
	[ -z "$3" ] && branch="master" || branch="$repobranch"
	dir=$(mktemp -d)
	[ ! -d "$2" ] && mkdir -p "$2"
	chown -R "$name":"$name" "$dir" "$2"
	sudo -u "$name" git clone --recursive -b "$branch" --depth 1 "$1" "$dir" >/dev/null 2>&1
	sudo -u "$name" cp -rfT "$dir" "$2"
}

systembeepoff() { 
    dialog --infobox "Getting rid of that retarded error beep sound..." 10 50
	rmmod pcspkr
	echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf 
}

createdirs() {
    cd "/home/$name"
    sudo -u "$name" mkdir -p user/{Downloads,Documents,Music,Videos/ScreenCaptures,Pictures/Screenshots}
}

xorgconfig() {
    dialog --title "Attention" --yes-label "Yes" --no-label "No" --yesno "Is your machine an Intel laptop?" 5 40 || return

    echo 'Section "Device"
  	Identifier 	"Intel Graphics"
  	Driver 		"intel"

	Option 		"DRI" 			"2"
	Option      "AccelMethod"  	"uxa"
  	Option 		"TearFree" 		"true"
EndSection' > /etc/X11/xorg.conf.d/20-intel.conf
    
    echo 'Section "InputClass"
    Identifier "devname"
    Driver "libinput"

	Option "Tapping" "on"
EndSection' > /etc/X11/xorg.conf.d/30-touchpad.conf
}

finalize(){ 
	dialog --infobox "Preparing welcome message..." 4 50

	dialog --title "All done!" --msgbox "Congrats! Provided there were no hidden errors, the script completed successfully and all the programs and configuration files should be in place.\\n\\nTo run the new graphical environment, log out and log back in as your new user, then run the command \"startx\" to start the graphical environment (it will start automatically in tty1)." 12 80
}

### THE ACTUAL SCRIPT ###

### This is how everything happens in an intuitive format and order.

# Check if user is root on Arch distro. Install dialog.
installpkg dialog || error "Are you sure you're running this as the root user and have an internet connection?"

# Welcome user.
welcomemsg || error "User exited."

# Get and verify username and password.
getuserandpass || error "User exited."

# Last chance for user to back out before install.
preinstallmsg || error "User exited."

### The rest of the script requires no user input.
[ "$user_exist" != "true" ] && { adduserandpass || error "Error adding username and/or password."; }

# Refresh Arch keyrings.
refreshkeys || error "Error automatically refreshing Arch keyring. Consider doing so manually."

dialog --title "SALAS Installation" --infobox "Installing \`basedevel\` and \`git\` for installing other software required for the installation of other programs." 5 70
installpkg curl
installpkg base-devel
installpkg git

[ -f /etc/sudoers.pacnew ] && cp /etc/sudoers.pacnew /etc/sudoers # Just in case

# Allow user to run sudo without password. Since AUR programs must be installed
# in a fakeroot environment, this is required for all builds with AUR.
#newperms "%wheel ALL=(ALL) NOPASSWD: ALL"

# Make pacman and yay colorful and adds eye candy on the progress bar because why not.
grep "^Color" /etc/pacman.conf >/dev/null || sed -i "s/^#Color$/Color/" /etc/pacman.conf
grep "ILoveCandy" /etc/pacman.conf >/dev/null || sed -i "/#VerbosePkgLists/a ILoveCandy" /etc/pacman.conf

# Use all cores for compilation.
sed -i "s/-j2/-j$(nproc)/;s/^#MAKEFLAGS/MAKEFLAGS/" /etc/makepkg.conf

manualinstall $aurhelper || error "Failed to install AUR helper."

# The command that does all the installing. Reads the progs.csv file and
# installs each needed program the way required. Be sure to run this only after
# the user has been created and has priviledges to run sudo without a password
# and all build dependencies are installed.
installationloop

dialog --title "SALAS Installation" --infobox "Finally, installing \`libxft-bgra\` to enable color emoji in suckless software without crashes." 5 70
yes | sudo -u "$name" $aurhelper -S libxft-bgra >/dev/null 2>&1

# Install the dotfiles in the user's home directory
putgitrepo "$dotfilesrepo" "/home/$name" "$repobranch"
rm -f "/home/$name/README.md" "/home/$name/LICENSE"
# make git ignore deleted LICENSE & README.md files
git update-index --assume-unchanged "/home/$name/README.md"
git update-index --assume-unchanged "/home/$name/LICENSE"

# Most important command! Get rid of the beep!
systembeepoff

# Make zsh the default shell for the user.
chsh -s /bin/zsh $name >/dev/null 2>&1
sudo -u "$name" mkdir -p "/home/$name/.cache/zsh/"

# Start/restart PulseAudio.
killall pulseaudio; sudo -u "$name" pulseaudio --start

newperms "
%wheel ALL=(ALL) NOPASSWD: /usr/bin/shutdown,/usr/bin/reboot,/usr/bin/systemctl suspend,/usr/bin/systemctl hibernate,/usr/bin/systemctl suspend-then-hibernate,/usr/bin/mount,/usr/bin/umount,/usr/bin/pacman,/usr/bin/systemctl restart NetworkManager,/usr/bin/yay,/usr/bin/make
Defaults editor=/usr/bin/nvim"

xorgconfig

# Create user's directories
createdirs

# Last message! Install complete!
finalize

clear
