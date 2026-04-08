#!/bin/bash

# This is to be run on a mostly clean install of Archlinux
# Arguments:
# $1 System Type: Options {laptop, desktop}
# $2 Desktop Environment: Options {kde, hypr}

# Exit on any error
set -e

# Source utility functions
source ./utils.sh

# Source the package list
if [ ! -f "packages.conf" ]; then
  echo "Error: packages.conf not found!"
  exit 1
fi

# source ./packages.conf

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
	# install_packages "${LAPTOP_UTILS[@]}"
	# install_packages "${LAPTOP_DEV[@]}"
	# install_packages "${LAPTOP_MAINTENANCE[@]}"
	# if [ $2 = 'kde' ] 
	# then
	# 	install_packages "${KDE[@]}"
	# elseif [ $2 = 'hypr' ] 
	# then
	# 	install_packages "${HYPRLAND[@]}"
	# install_packages "${LAPTOP_MEDIA[@]}"
	# install_packages "${LAPTOP_FONTS[@]}"
	# install_packages "${LAPTOP_GAMES[@]}"
	# for service in "${LAPTOP_SERVICES[@]}" do
	# 	if ! systemctl is-enabled "$service" &> /dev/null; then
	# 		sudo systemctl enable "$service"
	# 	fi
	# done

elif [[ $1 = desktop ]]; then
	# Install packages by category
	# install_packages "${SYSTEM_UTILS[@]}"
	cat ./packages/utils.txt | xargs yay -S --needed --noconfirm 
	cat ./packages/dev.txt | xargs yay -S --needed --noconfirm 
	# install_packages "${DEV_TOOLS[@]}"
	# install_packages "${MAINTENANCE[@]}"
	if [[ $2 = kde ]]; then
		# install_packages "${KDE[@]}"
		cat ./packages/kde.txt | xargs yay -S --needed --noconfirm 
	elif [[ $2 = hypr ]]; then
		cat ./packages/hyprland.txt | xargs yay -S --needed --noconfirm 
		# install_packages "${HYPRLAND[@]}"
	# install_packages "${MEDIA[@]}"
	# install_packages "${FONTS[@]}"
	cat ./packages/fonts.txt | xargs yay -S --needed --noconfirm 
	# install_packages "${GAMES[@]}"
	cat ./packages/games.txt | xargs yay -S --needed --noconfirm 
	# for service in "${SERVICES[@]}"; do
  	# 	if ! systemctl is-enabled "$service" &> /dev/null; then
    # 			sudo systemctl enable "$service"
  	# 	fi
	sudo systemctl enable NetworkManager.service
	# done
	fi
fi

# Install flatpaks, unused rn
# . install-flatpaks.sh

# Use this wrapper to implement stow for dotfiles
# https://github.com/jpasquier/stoww
# Download dotfiles repository
cd ~/Documents/Code/
git clone git@github.com:Bashiho/dotfiles.git
cd dotfiles/
# Calls stow_dotfiles to stow all of the dotfiles I currently use
# Some are not used anymore, can always remove them (alacritty, tofi, wezterm)
# stow_dotfiles "${STOW[@]}"
cat stow.txt | xargs stow -vt ~ 
# If using hyprland, stows waybar config
if [[ $2 = hypr ]]; then
	stow -vt ~ waybar
fi


echo "Setup complete!"
