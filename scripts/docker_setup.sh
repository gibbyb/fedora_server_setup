!#/bin/bash

echo
echo "Making Directories and moving files"
echo
mkdir -p ~/Documents/Web/
mkdir ~/Documents/3D_Printer/
mkdir ~/Documents/compose_files/
mkdir ~/Documents/Wireguard/
mkdir ~/Documents/Minecraft/
mkdir -p ~/media/
mkdir ~/Documents/Web/GibsWebsite/
mkdir ~/Documents/Web/WiredWorld/
echo 
echo 
read -p "You need to make sure your external driver for plex is mounted. If so press enter. If not, cancel this script, add to fstab and reboot and restart the script. it will not harm anything.\n\n\n"

cp ../docker/Caddyfile ~/Documents/Caddyfile
cp ../docker/user_variables.env ~/Documents/compose_files/user_variables.env
cp -r ../docker/compose_files ~/Documents/compose_files/


echo "Relevant files and Volumes will be in Documents."
echo 
echo "Plex and it's related containers are in ~/Media as that is \ 
    an external drive mapped to Media in fstab."
echo "You can change all of this in the plex_media_server compose file. \
    For now, the directories are not created, and files are not moved as \
    I do not plan on clearing the drive any time soon so the volumes should \
    just work for me, and you will need to change the paths either way, \
    but I would follow my template as well as you can, as it will save \
    you some time."

