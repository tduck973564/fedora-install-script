#!/usr/bin/bash

# Fedora Install Script by tduck973564
# for kenan

echo "CD into home directory"
cd ~

echo "Speed up DNF"
sudo dnf install dnf-plugins-core -y
sudo echo 'fastestmirror=True' | sudo tee -a /etc/dnf/dnf.conf
sudo echo 'max_parallel_downloads=10' | sudo tee -a /etc/dnf/dnf.conf
sudo echo 'deltarpm=true' | sudo tee -a /etc/dnf/dnf.conf
sudo echo 'countme=false' | sudo tee -a /etc/dnf/dnf.conf

echo "Installation of RPMFusion"
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf groupupdate -y core
sudo dnf groupupdate -y multimedia --setop="install_weak_deps=False"

echo "Update system before continuing"
sudo dnf --refresh upgrade -y

echo "Installation of Oh My Zsh!"
sudo dnf install -y util-linux-user zsh git
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended"
chsh -s /usr/bin/zsh
sed -e s/robbyrussell/lukerandall/ ~/.zshrc > ~/.zshrc.tmp && mv ~/.zshrc.tmp ~/.zshrc
echo "setopt NO_NOMATCH" >> ~/.zshrc

echo "Installation of apps"
sudo dnf remove -y \
fedora-bookmarks \
mediawriter

sudo dnf install -y \
ffmpeg \
firewall-config \
discord \
pavucontrol

sudo sh -c "echo \"[Desktop Entry]
Name=Discord
StartupWMClass=discord
Comment=All-in-one voice and text chat for gamers that's free, secure, and works on both your desktop and phone.
GenericName=Internet Messenger
Exec=/usr/bin/Discord --enable-features=WaylandWindowDecorations --ozone-platform-hint=auto
Icon=discord
Type=Application
Categories=Network;InstantMessaging;
Path=/usr/bin
X-Desktop-File-Install-Version=0.26\" > /usr/share/applications/discord.desktop"

flatpak install -y flathub \
com.github.tchx84.Flatseal \
org.musescore.MuseScore \
com.github.wwmm.easyeffects

echo "Install onedrive"
sudo dnf install -y onedrive
echo "#########\nYou will need to enable OneDrive later\n#########"

echo "Download icon theme and fonts"
sudo dnf install -y ibm-plex-fonts-all rsms-inter-fonts

echo "Dotfiles"
git clone https://github.com/tduck973564/dotfiles ~/.dotfiles
echo ". ~/.dotfiles/.aliases" >> ~/.zshrc

echo "Install AppImageLauncher"
sudo dnf install -y https://github.com/TheAssassin/AppImageLauncher/releases/download/v2.2.0/appimagelauncher-2.2.0-travis995.0f91801.x86_64.rpm

echo "Installation of GNOME Apps"
sudo dnf remove -y \
gnome-terminal \
rhythmbox \
eog

sudo dnf install -y \
gnome-tweaks \
seahorse \
gnome-console \
gnome-backgrounds-extras

flatpak install -y flathub \
com.mattjakeman.ExtensionManager \
io.github.realmazharhussain.GdmSettings \
io.bassi.Amberol \
com.github.huluti.Curtail \
com.belmoussaoui.Decoder \
com.adrienplazas.Metronome \
com.github.alexhuntley.Plots \
org.gnome.SoundRecorder \
org.gnome.Solanum \
com.github.liferooter.textpieces \
com.github.hugolabe.Wike \
io.posidon.Paper \
com.github.finefindus.eyedropper \
app.drey.Dialect \
org.gnome.Geary \
com.github.maoschanz.drawing \
ca.desrt.dconf-editor \
com.github.unrud.VideoDownloader \
org.gnome.Loupe

echo "Fix inconsistent GNOME theming"
sudo dnf copr enable nickavem/adw-gtk3 -y
sudo dnf install -y adw-gtk3
flatpak install -y flathub org.gtk.Gtk3theme.adw-gtk3 org.gtk.Gtk3theme.adw-gtk3-dark

echo "Install shell extensions"
gsettings set org.gnome.shell disable-extension-version-validation true

array=( https://extensions.gnome.org/extension/5237/rounded-window-corners/ https://extensions.gnome.org//extension/3733/tiling-assistant/ )

for i in "${array[@]}"
do
    EXTENSION_ID=$(curl -s $i | grep -oP 'data-uuid="\K[^"]+')
    VERSION_TAG=$(curl -Lfs "https://extensions.gnome.org/extension-query/?search=$EXTENSION_ID" | jq '.extensions[0] | .shell_version_map | map(.pk) | max')
    wget -O ${EXTENSION_ID}.zip "https://extensions.gnome.org/download-extension/${EXTENSION_ID}.shell-extension.zip?version_tag=$VERSION_TAG"
    gnome-extensions install --force ${EXTENSION_ID}.zip
    if ! gnome-extensions list | grep --quiet ${EXTENSION_ID}; then
        busctl --user call org.gnome.Shell.Extensions /org/gnome/Shell/Extensions org.gnome.Shell.Extensions InstallRemoteExtension s ${EXTENSION_ID}
    fi
    gnome-extensions enable ${EXTENSION_ID}
    rm ${EXTENSION_ID}.zip
done

gnome-extensions disable background-logo@fedorahosted.org
gnome-extensions enable rounded-window-corners@yilozt
gnome-extensions enable tiling-assistant@leleat-on-github

echo "Fractional scaling"
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
gsettings set org.gnome.mutter experimental-features "['x11-randr-fractional-scaling']"

echo "Set theme settings"
gsettings set org.gnome.desktop.interface clock-show-weekday true

gsettings set org.gnome.desktop.interface document-font-name 'Inter 11'
gsettings set org.gnome.desktop.interface font-name 'Inter 11'
gsettings set org.gnome.desktop.interface monospace-font-name 'IBM Plex Mono 11'

gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'

gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true

gsettings set org.gnome.shell had-bluetooth-devices-setup true

gsettings set org.gnome.software packaging-format-preference "['flatpak:flathub', 'rpm', 'flatpak:fedora-testing', 'flatpak:fedora']"

gsettings set org.gnome.desktop.notifications.application:/org/gnome/desktop/notifications/application/org-freedesktop-problems-applet/ enable false

echo "Install firefox theme"
git clone https://github.com/rafaelmardojai/firefox-gnome-theme
cd firefox-gnome-theme
./scripts/auto-install.sh
cd ~

echo "Battery optimisation"
sudo dnf remove power-profiles-daemon

sudo systemctl mask systemd-rfkill.service
sudo systemctl mask systemd-rfkill.socket
sudo systemctl enable --now NetworkManager-dispatcher

sudo dnf install tlp tlp-rdw powertop

sudo sh -c "echo 'PCIE_ASPM_ON_BAT=powersupersave
PLATFORM_PROFILE_ON_BAT=low-power
NMI_WATCHDOG=0
CPU_PERF_POLICY_ON_BAT=power
DEVICES_TO_DISABLE_ON_STARTUP=\"bluetooth nfc wwan\"
DEVICES_TO_ENABLE_ON_STARTUP=\"wifi\"
RADEON_DPM_PERF_LEVEL_ON_BAT=auto
RADEON_DPM_STATE_ON_BAT=battery
CPU_SCALING_GOVERNOR_ON_BAT=schedutil
CPU_BOOST_ON_BAT=0
' >> /etc/tlp.conf"

sudo systemctl enable --now tlp
sudo tlp-rdw enable

sudo powertop --auto-tune
sudo systemctl enable --now powertop

echo "Cleanup"
rm -rf firefox-gnome-theme