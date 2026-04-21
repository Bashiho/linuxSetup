#!/bin/bash

# This is to be run on a mostly clean install of Archlinux
# Arguments:
# $1 System Type: Options {laptop, desktop}
# $2 Desktop Environment: Options {kde, hypr}

# Exit on any error
set -e

# Source utility functions
source ./utils.sh

# Update the system first
echo "Updating before setup"
sudo pacman -Syu --noconfirm

echo "Starting installs"

# Install yay AUR helper if not present
if ! command -v yay &> /dev/null; then
  echo "Installing yay"
  sudo pacman -S --needed git base-devel --noconfirm
  git clone https://aur.archlinux.org/yay.git
  cd yay
  echo "building yay"
  makepkg -si --noconfirm
  # Clean up files
  cd ..
  rm -rf yay
else
  echo "yay is already installed"
fi

# First argument determines which kind of system I am trying to set up, laptop vs desktop
if $1 == 'laptop'; then
	echo "Installing laptop packages"
	# Install packages by category
	cat ./packages/laptop/utils.txt | xargs yay -S --needed --noconfirm 
	cat ./packages/laptop/dev.txt | xargs yay -S --needed --noconfirm
	if [[ $2 = kde ]]; then
		cat ./packages/kde.txt | xargs yay -S --needed --noconfirm 
	elif [[ $2 = hypr ]]; then
		cat ./packages/hyprland.txt | xargs yay -S --needed --noconfirm
		sudo systemctl enable sddm.service
	cat ./packages/fonts.txt | xargs yay -S --needed --noconfirm 
	cat ./packages/laptop/games.txt | xargs yay -S --needed --noconfirm 
	fi

elif [[ $1 = desktop ]]; then
	echo "Installing desktop packages"
	# Install packages by category
	cat ./packages/desktopp/utils.txt | xargs yay -S --needed --noconfirm 
	cat ./packages/desktop/dev.txt | xargs yay -S --needed --noconfirm
	if [[ $2 = kde ]]; then
		cat ./packages/kde.txt | xargs yay -S --needed --noconfirm 
	elif [[ $2 = hypr ]]; then
		cat ./packages/hyprland.txt | xargs yay -S --needed --noconfirm
		sudo systemctl enable sddm.service
	cat ./packages/fonts.txt | xargs yay -S --needed --noconfirm 
	cat ./packages/desktop/games.txt | xargs yay -S --needed --noconfirm 
	fi
fi

# Install flatpaks, unused rn
# . install-flatpaks.sh

# Download dotfiles repository
mkdir ~/Documents
mkdir ~/Documents/Code
cd ~/Documents/Code/
git clone https://github.com/bashiho/dotfiles.git
cd dotfiles/
# Calls stow_dotfiles to stow all of the dotfiles I currently use
# Some are not used anymore, can always remove them (alacritty, tofi, wezterm)
cat ~/linuxsetup/packages/stow.txt | xargs stow -vt ~ 
# If using hyprland, stows waybar config
if [[ $2 = hypr ]]; then
	stow -vt ~ waybar
fi

# https://tmak2002.dev/blog/how-to-configure-japanese-input-on-hyprland/
# echo "Installing Japanese Keyboard packages"
# sudo pacman -Sy fcitx5-im fcitx5-mozc fcitx5-configtool adobe-source-han-sans-jp-fonts adobe-source-han-serif-jp-fonts noto-fonts-cjk

echo "Cleaning up linuxsetup files"
cd ~
rm -rf linuxsetup

echo "Setup complete, please reboot"
