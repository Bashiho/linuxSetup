FLATPAKS=(
	"spotify"
	"discord"
)

for pak in "${FLATPAKS[@]}"; do
	if ! flatpak list | grep -i "$pak" &> /dev/null; then
		echo "installing Flatpak: $pak"
		flatpak install --noninteractive "$pak"
	else
		echo "Flatpak $pak already installed"
	fi
done
