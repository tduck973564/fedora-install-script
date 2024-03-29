#!/usr/bin/env bash

rpm-ostree install kmod-nvidia xorg-x11-drv-nvidia nvidia-vaapi-driver
rpm-ostree kargs --append=rd.driver.blacklist=nouveau --append=modprobe.blacklist=nouveau --append=nvidia-drm.modeset=1

echo "\n\nRun systemctl reboot to apply changes"
