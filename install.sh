#!/bin/bash

mkdir -p ~/bin
mkdir -p ~/tools

git clone https://github.com/radareorg/radare2 ~/tools/radare2
~/tools/radare2/sys/user.sh

source ~/.profile

r2pm init
r2pm update
r2pm -i r2ghidra-dec

curl -L https://github.com/radareorg/cutter/releases/download/v1.10.0/Cutter-v1.10.0-x64.Linux.appimage -o ~/bin/Cutter
chmod +x ~/bin/Cutter

cd ~/tools

curl -LO https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.5%2B10/OpenJDK11U-jdk_x64_linux_hotspot_11.0.5_10.tar.gz
tar xvf OpenJDK11U-jdk_x64_linux_hotspot_11.0.5_10.tar.gz

echo '
if [ -d "$HOME/tools/jdk-11.0.5+10/bin" ] ; then
    PATH="$HOME/tools/jdk-11.0.5+10/bin:$PATH"
fi' >> ~/.profile

source ~/.profile

curl -O https://ghidra-sre.org/ghidra_9.1.1_PUBLIC_20191218.zip
7z x ghidra_9.1.1_PUBLIC_20191218.zip
