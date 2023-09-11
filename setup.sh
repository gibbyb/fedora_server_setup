#!/bin/bash
# FEDORA SERVER INSTALL SCRIPT

# Environment Variables
source ./docker/compose_files/user_variables.env

echo "Fedora Server Install Script"
echo "-----------------------------"
echo
echo "Run this script from the cloned directory without sudo."
read - p "Press enter to continue"
echo
echo "Change the root password"
sudo passwd
echo
echo "Importing most of the key bindings"
# WM keybindings
dconf load /org/gnome/desktop/wm/keybindings/ < ./shortcuts/shortcuts-wm.txt
# Media keybindings
dconf load /org/gnome/settings-daemon/plugins/media-keys/ < ./shortcuts/shortcuts-media.txt
# Mutter keybindings
dconf load /org/gnome/mutter/keybindings/ < ./shortcuts/shortcuts-mutter.txt
# Power settings
dconf load /org/gnome/settings-daemon/plugins/power/ < ./shortcuts/shortcuts-power.txt
# Shell keybindings
dconf load /org/gnome/shell/keybindings/ < ./shortcuts/shortcuts-shell.txt
# Wayland keybindings
dconf load /org/gnome/mutter/wayland/keybindings/ < ./shortcuts/shortcuts-wayland.txt
echo

echo "Changing some settings"
# Add maximize and minimize buttons to windows
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
# Set gtk theme to Adwaita-dark 
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
# Add weekday to clock in top bar 
gsettings set org.gnome.desktop.interface clock-show-weekday true
# Center new windows on screen
gsettings set org.gnome.mutter center-new-windows true
echo

echo "Installing gnome-tweaks & Important Flatpaks for Gnome Theme."
sudo dnf install -y gnome-tweaks adw-gtk3-theme
flatpak install flathub -y com.mattjakeman.ExtensionManager \
    com.bitwarden.desktop com.github.GradienceTeam.Gradience


echo "Making DNF better..."
sudo echo "fastestmirror=True" | sudo tee -a /etc/dnf/dnf.conf
sudo echo "max_parallel_downloads=10" | sudo tee -a /etc/dnf/dnf.conf
sudo echo "defaultyes=True" | sudo tee -a /etc/dnf/dnf.conf
sudo echo "keepcache=True" | sudo tee -a /etc/dnf/dnf.conf
echo

echo "We will update the system for the first time now."
sudo dnf update -y --refresh

echo
echo "Installing Flatpak packages..."
echo
flatpak install flathub -y com.mattjakeman.ExtensionManager org.gnome.gThumb \
    de.haeckerfelix.Fragments org.videolan.VLC 
echo
echo "Done!"
echo

echo "Installing RPM Fusion, Microsoft repo & Flatpak..."
echo
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm 
sudo dnf groupupdate core -y
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo dnf config-manager --add-repo https://packages.microsoft.com/yumrepos/edge
printf "[vscode]\nname=packages.microsoft.com\nbaseurl=https://packages.microsoft.com/yumrepos/vscode/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc\nmetadata_expire=1h" | sudo tee -a /etc/yum.repos.d/vscode.repo
echo

echo "Installing necessary packages..."
echo 

sudo dnf install -y ./apps/jdk-20_linux-x64_bin.rpm

sudo dnf groupinstall -y "C Development Tools and Libraries"
sudo dnf groupinstall -y "Development Tools"

sudo dnf install -y neovim xclip git curl wget python3 python3-pip nodejs npm \
    gcc g++ make cmake clang clang-tools-extra clang-analyzer htop neofetch \
    kitty powerline powerline-fonts nautilus-python php-fpm composer \
    kernel-devel gh qemu-kvm-core libvirt virt-manager java-latest-openjdk-devel \
    gparted timeshift jetbrains-mono-fonts-all kmodtool akmods mokutil openssl \
    maven cargo dotnet microsoft-edge-stable code wine go gem luarocks texlive \
    python3-tkinter dnf-plugins-core python3-dnf-plugin-versionlock \
    xkill mangohud airtv dia firewall-config godot scratch texstudio winetricks \
    wireshark seahorse gnome-connections dia dotnet-sdk-7.0 wine-mono \
    python-pygit2 meld nautilus-extensions python-requests python3-gobject 
echo
echo "All DNF packages installed."
echo

echo "Replacing .bashrc file."
cp ./config/.bashrc ~/.bashrc
source ~/.bashrc
echo

echo "Setting up Kitty Terminal..."
# Make kitty config directory if it doesn't exist 
if [ ! -d "~/.config/kitty" ]; then
    echo "Creating ~/.config/kitty directory"
    mkdir ~/.config/kitty
fi

# Copy needed wallpapers and kitty config file
mkdir -p ~/Pictures/Wallpapers/Best_of_the_best
cp ./Wallpapers/* ~/Pictures/Wallpapers/Best_of_the_best/
cp ./config/kitty/kitty.conf ~/.config/kitty/kitty.conf

# Copy JetBrains Mono Nerd Font to fonts folder
sudo mv ./config/kitty/JetBrainsMono /usr/share/fonts/JetBrainsMono

# Make nautilus extension directory if it doesn't exist 
if [ ! -d "/usr/share/nautilus-python/extensions" ]; then
    echo "Creating /usr/share/nautilus-python/extensions directory"
    sudo mkdir -p /usr/share/nautilus-python/extensions
fi

# Add nautilus extensions
sudo cp ./config/kitty/open_any_terminal_extension.py \
    /usr/share/nautilus-python/extensions/open_any_terminal_extension.py
git clone https://gitlab.gnome.org/philippun1/turtle ~/Downloads/turtle
cd ~/Downloads/turtle
python install.py install --user
pip3 install . --user
nautilus -q
nautilus --no-desktop
cd ~/Downloads/fedora_setup

echo 
echo "Installing Python packages..."
pip install matplotlib numpy appdirs datetime pygame
echo 

echo 
echo "Installing Node packages..."
sudo npm install -g typescript tailwind live-server pm2 create-react-app express \
    mysql2 
echo 

echo "Setting up Neovim..."
sudo cp ./config/nvim/neovim.desktop /usr/share/applications/neovim.desktop
# Make nvim config directory if it doesn't exists
if [ ! -d "~/.config/nvim" ]; then
    echo "Creating ~/.config/nvim directory"
    mkdir ~/.config/nvim
fi
mkdir -p ~/.config/coc/extensions/coc-stylua-data
echo "Copying init.lua, coc-settings, & lua directory to ~/.config/nvim"
cp ./config/nvim/init.lua ~/.config/nvim/init.lua
cp ./config/nvim/coc-settings.json ~/.config/nvim/coc-settings.json
mkdir -p ~/.config/nvim/lua/gib_nvim
mkdir -p ~/.config/nvim/after/plugin
cp ./config/nvim/lua/gib_nvim/* ~/.config/nvim/lua/gib_nvim/
# Install packer.nvim 
echo "Installing packer.nvim"
git clone --depth 1 https://github.com/wbthomason/packer.nvim \
    ~/.local/share/nvim/site/pack/packer/start/packer.nvim
echo
echo "Opening packer.lua. Source the file and run \":PackerSync\""
echo "to install all plugins."
echo
echo "Once complete, close the window."
kitty -1 -e bash -c "nvim ~/.config/nvim/lua/gib_nvim/packer.lua"
read -p "Press enter to continue."
echo echo "Copying after directory to ~/.config/nvim" 
cp ./config/nvim/after/plugin/* ~/.config/nvim/after/plugin/ 
echo
echo "Opening neovim. Run \":Copilot setup\" to setup GitHub Copilot."
echo
echo "Once complete, close the window."
echo
kitty -1 -e "nvim"
git config --global core.editor "nvim"
echo "Neovim setup complete."
echo

echo "Replacing Nanorc file."
sudo cp ./config/nanorc /etc/nanorc
echo

echo "Setting up Git/GitHub..."
git config --global user.name "gibbyb"
git config --global user.email "gib@gibbyb.com"
git config --global core.editor "nvim"
git config --global init.defaultBranch "main"
gh auth login
echo

echo "Installing NVIDIA Drivers..."
echo
sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda
echo
echo "Remove the duplicate lines \"rd.driver.blacklist=nouveau, \
    modprobe.blacklist=nouveau, and nvidia-drm.modeset=1\""
echo
kitty -1 -e bash -c "sudo nvim /etc/default/grub"
# kitty -1 -e bash -c "sudo nvim /etc/gdm/custom.conf"
read -p "Once complete, close neovim and press enter to continue."
sudo grub2-mkconfig -o /etc/grub2-efi.cfg 
echo
echo "############## WARNING ################"
echo "Wait 5 minutes before rebooting!"
echo "Nividia drivers MUST finish building!"
echo "############## WARNING ################" 
read -p "Press enter once the drivers have finished building."
echo
echo "Enabling Nvidia system services"
sudo systemctl enable nvidia-hibernate.service nvidia-suspend.service \
    nvidia-resume.service

read -p "Do you want to disable Wayland? (y/n) " answer_wayland
if [ "$answer_wayland" == "y" ]; then
    echo "Disabling Wayland"
    sudo sed -i 's/#WaylandEnable=false/WaylandEnable=false/' \
        /etc/gdm/custom.conf
    echo "Enabling VNCServer service..."
    sudo systemctl enable --now vncserver-x11-serviced.service
fi
echo

echo
echo "Enrolling Key to MOK"
echo
sudo mokutil --import /etc/pki/akmods/certs/public_key.der
echo
echo "Enroll the key once you reboot."
echo

echo "Enabling Libvirt service now." 
sudo systemctl enable --now libvirtd.service

# SETTING UP DOCKER

# Making sure we do not have old Docker installed.
echo
echo "Removing old Docker packages..."
echo
sudo dnf remove -y docker docker-client docker-client-latest \
    docker-common docker-latest docker-latest-logrotate docker-logrotate \
    docker-selinux, docker-engine, docker-engine-selinux
echo
echo "Installing Docker packages..."
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose

sudo systemctl enable --now docker.service
sudo systemctl enable --now containerd.service

echo "Docker installed & enabled."
echo
echo "Creating MacVLAN Network for Docker..."
sudo docker network create -d macvlan --subnet ${SUBNET} \
    --gateway ${GATEWAY} -o parent=${PARENT} ${NETWORK_NAME}
sudo ip link set enp0s20f0u2 promisc on

echo "This script is complete."
echo "You must reboot to make changes to promisc mode as well as enable the \
    NVIDIA drivers, extensions, changes to the themes, etc."



