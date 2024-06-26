echo "Uninstall nvidia driver"
sudo dnf remove -y xorg-x11-drv-nvidia\* akmod-nvidia
sudo rm /etc/modprobe.d/blacklist-nouveau.conf
sudo dnf copr remove -y kwizart/nvidia-driver-rawhide
sudo dnf config-manager --disable rpmfusion-nonfree-rawhide
sudo grubby --update-kernel=ALL --remove-args='nvidia-drm.modeset=1'
sudo dracut --regenerate-all --force
