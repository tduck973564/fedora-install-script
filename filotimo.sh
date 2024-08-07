#!/bin/bash

tmpfile=$(mktemp)

cat <<EOF > "$tmpfile"
dnf install dnf-plugins-core -y
echo 'fastestmirror=True' | tee -a /etc/dnf/dnf.conf
echo 'max_parallel_downloads=10' | tee -a /etc/dnf/dnf.conf
echo 'countme=false' | tee -a /etc/dnf/dnf.conf

dnf --refresh upgrade -y
flatpak update

dnf config-manager addrepo --add-repo "https://mirrorcache-au.opensuse.org/repositories/home:/tduck:/filotimolinux/Fedora_40/home:tduck:filotimolinux.repo"
dnf install -y --refresh filotimo-repos dnf5
rm -f "/etc/yum.repos.d/home:tduck:filotimolinux.repo"
yes | dnf install -y --refresh --best --allowerasing filotimo-atychia filotimo-backgrounds filotimo-branding filotimo-dnfdragora filotimo-environment* filotimo-grub-theme filotimo-kde-overrides filotimo-kde-theme filotimo-plymouth-theme filotimo-release-kde appimagelauncher
yes | dnf-3 --refresh upgrade -y
yes | dnf5 --refresh upgrade -y
dnf group upgrade -y core --allowerasing
dnf swap -y ffmpeg-free ffmpeg --allowerasing
dnf group upgrade multimedia -y --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin --allowerasing --with-optional
dnf group upgrade -y sound-and-video
dnf install -y rpmfusion-free-release-tainted
dnf install -y libdvdcss
dnf install -y rpmfusion-nonfree-release-tainted
dnf --repo=rpmfusion-nonfree-tainted install -y "*-firmware"
dnf install -y intel-media-driver libva-intel-driver nvidia-vaapi-driver libva-utils vdpauinfo libavcodec-freeworld
dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld
dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld
dnf install -y gstreamer1-plugin-openh264 mozilla-openh264
dnf install -y lame\* --exclude=lame-devel
dnf install -y libheif libheif-tools

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak remote-modify --enable flathub

sudo dnf5 install -y \
firewall-config \
openssl openssl-libs \
python3-pip \
nmap \
p7zip \
p7zip-plugins \
unzip \
unrar \
setroubleshoot \
steam-devices

sudo dnf5 install -y \
epson-inkjet-printer-escpr2 \
foomatic-db \
gutenprint \
hplip

sudo dnf5 install -y @printing

flatpak install -y flathub org.mozilla.Thunderbird
flatpak override --socket=wayland org.mozilla.Thunderbird
flatpak override --env=MOZ_ENABLE_WAYLAND=1 org.mozilla.Thunderbird

dnf copr enable -y jstaf/onedriver fedora-40-x86_64
dnf5 install -y onedriver

systemctl mask hibernate.target

sudo dnf5 install -y cabextract xorg-x11-font-utils fontconfig
sudo rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
sudo dnf5 install -y ibm-plex-fonts-all rsms-inter-fonts jetbrains-mono-fonts-all google-roboto* liberation-fonts

dnf5 remove -y akregator krusader konversation k3b kontact kmail korganizer kaddressbook *akonadi* krdc krfb kmousetool *abrt* mariadb mariadb-backup mariadb-common mariadb-cracklib-password-check mariadb-errmsg mariadb-gssapi-server mariadb-server mariadb-server-utils kmines kmahjongg kpat

dnf5 install -y kleopatra kclock kweather francis kget ktorrent krecorder libreoffice kdenetwork-filesharing kcolorchooser

systemctl enable smb
firewall-cmd --permanent --add-service samba

EOF
pkexec bash "$tmpfile"
