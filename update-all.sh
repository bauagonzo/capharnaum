#!/bin/zsh
source ~/.zshrc
omz update
sudo dnf update -y
echo "Update CSI code 🦠"
ls -d ~csi/* |  xargs  -I{} git -C {} pull

