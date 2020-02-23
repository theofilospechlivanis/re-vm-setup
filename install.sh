#!/bin/bash

radare2 () {
    if [ ! -d ~/tools/radare2 ]; then
        git clone https://github.com/radareorg/radare2 ~/tools/radare2
    fi

    touch ~/.profile

    if ! grep -q 'if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi' ~/.profile; then
        ~/tools/radare2/sys/user.sh
        echo '
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi' >> ~/.profile
        source ~/.profile
    fi
}

radare2-plugins () {
    if [ ! -d ~/.local/share/radare2/r2pm/git/radare2-pm ]; then
        r2pm init
    fi

    r2pm update
    r2pm install "$1"
}

cutter () {
    cutterVersion="Cutter-v1.10.1-x64.Linux.AppImage"
    cutterUrl="https://github.com/radareorg/cutter/releases/download/v1.10.1/$cutterVersion"

    if [ ! -f ~/tools/"$cutterVersion" ]; then
        cd ~/tools
        curl -LO "$cutterUrl"
        ln -sf "$cutterVersion" ~/bin/Cutter
#        chmod +x ~/bin/Cutter
    fi
}

openjdk () {
    openjdkVersion="OpenJDK11U-jdk_x64_linux_hotspot_11.0.6_10.tar.gz"
    openjdkUrl="https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.6%2B10/$openjdkVersion"

    cd ~/tools

    if [ ! -f ~/tools/"$openjdkVersion" ]; then
        curl -LO "$openjdkUrl"
    fi

    touch ~/.profile

    if ! grep -q 'if [ -d "$HOME/tools/jdk\-11\.0\.6\+10/bin" ] ; then
    PATH="$HOME/tools/jdk\-11\.0\.6\+10/bin:$PATH"
fi' ~/.profile; then
        tar xvf "$openjdkVersion"
        echo '
if [ -d "$HOME/tools/jdk-11.0.6+10/bin" ] ; then
    PATH="$HOME/tools/jdk-11.0.6+10/bin:$PATH"
fi' >> ~/.profile
        source ~/.profile
    fi
}

ghidra () {
    ghidraVersion="ghidra_9.1.2_PUBLIC_20200212.zip"
    ghidraUrl="https://ghidra-sre.org/$ghidraVersion"
    ghidraName="ghidra_9.1.2_PUBLIC"

    openjdk

    if [ ! -f ~/tools/"$ghidraVersion" ]; then
        curl -O "$ghidraUrl"
    fi

    if [ ! -f ~/tools/"$ghidraName" ]; then
        7z x "$ghidraVersion"
        ln -sf ~/tools/"$ghidraName"/ghidraRun ~/bin/Ghidra
    fi
}

install () {
    if [ "$1" = "fedora" ]; then
        sudo dnf -y install $(cat fedora/packages)
    elif [ "$1" = "ubuntu" ]; then
        sudo apt -y install $(cat ubuntu/packages)
    fi

    mkdir -p ~/bin
    mkdir -p ~/tools

    while true
    do
        options=("radare2" "Cutter (r2gui)" "Ghidra" "Quit")

        echo "Select tools to install: "
        select opt in "${options[@]}"
        do
            case $opt in
                "radare2")
                    radare2
                    while true
                    do
                        options=("Ghidra Decompiler" "Retargetable Decompiler" "Quit")

                        echo "Select plugins to install: "
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
                                    break 2
                                    ;;
                                *) echo "invalid option $REPLY";;
                            esac
                        done
                    done
                    ;;
                "Cutter (r2gui)")
                    cutter
                    ;;
                "Ghidra")
                    ghidra
                    ;;
                "Quit")
                    break 2
                    ;;
                *) echo "invalid option $REPLY";;
            esac
        done
    done
}

update () {
    echo "Update"
}

remove () {
    echo "Remove"
}

PS3="Input: "

while true
do
    options=("Install tools and packages" "Update tools and packages" "Remove tools and packages" "Quit")

    echo "Enter your choice: "
    select opt in "${options[@]}"
    do
        case $opt in
            "Install tools and packages")
                while true
                do
                    options=("Install packages for the Fedora distribution" "Install packages for the Ubuntu distribution" "Quit")

                    echo "Enter your choice: "
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
                                break 2
                                ;;
                            *) echo "invalid option $REPLY";;
                        esac
                    done
                done
                ;;
            "Update tools and packages")
                update
                ;;
            "Remove tools and packages")
                remove
                ;;
            "Quit")
                break 2
                ;;
            *) echo "invalid option $REPLY";;
        esac
    done
done
