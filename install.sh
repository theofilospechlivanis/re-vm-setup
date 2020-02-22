#!/bin/bash

radare2 () {
    git clone https://github.com/radareorg/radare2 ~/tools/radare2
    ~/tools/radare2/sys/user.sh

    if ! grep -q '
    if [ -d "$HOME/bin" ] ; then
        PATH="$HOME/bin:$PATH"
    fi' ~/.profile; then
        echo "$HOME/bin is in path."
    else
    echo '
    if [ -d "$HOME/bin" ] ; then
        PATH="$HOME/bin:$PATH"
    fi' >> ~/.profile
    fi

    source ~/.profile

    r2pm init
}

radare2-plugins () {
    r2pm update
    r2pm install "$1"
}

cutter () {
    curl -L https://github.com/radareorg/cutter/releases/download/v1.10.1/Cutter-v1.10.1-x64.Linux.AppImage -o ~/bin/Cutter
    chmod +x ~/bin/Cutter
}

ghidra () {
    cd ~/tools

    curl -LO https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.6%2B10/OpenJDK11U-jdk_x64_linux_hotspot_11.0.6_10.tar.gz
    tar xvf OpenJDK11U-jdk_x64_linux_hotspot_11.0.6_10.tar.gz

    if ! grep -q '
    if [ -d "$HOME/tools/jdk-11.0.6+10/bin" ] ; then
        PATH="$HOME/tools/jdk-11.0.6+10/bin:$PATH"
    fi' ~/.profile; then
        echo "OpenJDK is in path."
    else
    echo '
    if [ -d "$HOME/tools/jdk-11.0.6+10/bin" ] ; then
        PATH="$HOME/tools/jdk-11.0.6+10/bin:$PATH"
    fi' >> ~/.profile
    fi

    source ~/.profile

    curl -O https://ghidra-sre.org/ghidra_9.1.2_PUBLIC_20200212.zip
    7z x ghidra_9.1.2_PUBLIC_20200212.zip
}

install () {
    if [ "$1" = "fedora" ]; then
        sudo dnf install $(cat fedora/packages)
    elif [ "$1" = "ubuntu" ]; then
        sudo apt install $(cat ubuntu/packages)
    fi

    [ -f ~/bin ] || mkdir ~/bin
    [ -f ~/tools ] || mkdir ~/tools

    PS3='Select tools to install: '
    options=("radare2" "Cutter (r2gui)" "Ghidra" "Quit")
    select opt in "${options[@]}"
    do
        case $opt in
            "radare2")
                radare2
                PS3='Select plugins to install: '
                options=("Ghidra Decompiler" "Retargetable Decompiler" "Quit")
                select opt in "${options[@]}"
                do
                    case $opt in
                        "Ghidra Decompiler")
                            radare2-plugins r2ghidra-dec
                            ;;
                        "Retargetable Decompiler")
                            radare2-plugins retdec-r2plugin
                            ;;
                        "Quit")
                            break
                            ;;
                        *) echo "invalid option $REPLY";;
                    esac
                done
                ;;
            "Cutter (r2gui)")
                cutter
                ;;
            "Ghidra")
                ghidra
                ;;
            "Quit")
                break
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done
}

update () {
    echo "Update"
}

remove () {
    echo "Remove"
}

PS3='Enter your choice: '
options=("Install tools and packages" "Update tools and packages" "Remove tools and packages" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Install tools and packages")
            PS3='Enter your choice: '
            options=("Install packages for the Fedora distribution" "Install packages for the Ubuntu distribution" "Quit")
            select opt in "${options[@]}"
            do
                case $opt in
                    "Install packages for the Fedora distribution")
                        install fedora
                        ;;
                    "Install packages for the Ubuntu distribution")
                        install ubuntu
                        ;;
                    "Quit")
                        break
                        ;;
                    *) echo "invalid option $REPLY";;
                esac
            done
            ;;
        "Update tools and packages")
            update
            ;;
        "Remove tools and packages")
            remove
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
