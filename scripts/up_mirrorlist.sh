#/bin/sh

if ! command -v rate-mirrors >/dev/null 2>&1
then
    sudo pacman -S rate-mirrors
fi

rate-mirrors arch | sudo tee /etc/pacman.d/mirrorlist 
