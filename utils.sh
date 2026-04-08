#!/bin/bash

# Function to test if package is installed
is_installed() {
	pacman -Qi "$1" &> /dev/null
}

# Function to check if package is installed
is_group_installed(){
	pacman -Qg "$1" &> /dev/null
}

# Function to install missing packages
install_packages() {
	local packages=("$@")
	local to_install=()

	for pkg in "${packages[@]}"; do
		if ! is_installed "$pkg" && ! is_group_installed "$pkg"; then
			to_install+=("$pkg")
		fi
	done

	if [ %(#to_install[@]} -ne 0]; then
		echo "Installing ${to_install[*]}"
		yay -S --noconfirm "${to_install[@]}"
	fi
}

stow_packages() {
	local packages=("$@")
	for pkg in "${packages[@]}"; do
		# Uses stow with flag t to set target directory to home
		stow -t ~ "$pkg"
	done
}
