#!/bin/bash

install-radare2 () {
    if [ ! -d ~/tools/radare2 ]; then
        git clone https://github.com/radareorg/radare2 ~/tools/radare2
    fi

    touch ~/.profile

    if ! fgrep -q 'if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi' ~/.profile; then
        ~/tools/radare2/sys/user.sh
        printf '\nif [ -d "$HOME/bin" ] ; then\n    PATH="$HOME/bin:$PATH"\nfi' >> ~/.profile
        source ~/.profile
    fi
}

update-radare2 () {
    if [ -d ~/tools/radare2 ]; then
        cd ~/tools/radare2
        sys/user.sh
    else
        printf 'Error: radare2 is not installed.'
    fi
}

install-radare2-plugin () {
    if [ ! -d ~/.local/share/radare2/r2pm/git/radare2-pm ]; then
        r2pm init
    fi

    r2pm update
    r2pm install "$1"
}

install-radare2-cfg () {
    printf 'eco zenburn\ne asm.ucase = true\ne scr.color = 3\ne scr.utf8 = true\ne scr.utf8.curvy = true' > ~/.radare2rc

    printf '{\"Title\":\"agf\",\"Cmd\":\"agf\",\"x\":0,\"y\":1,\"w\":69,\"h\":56},{\"Title\":\"pdc\",\"Cmd\":\"pdc\",\"x\":68,\"y\":1,\"w\":72,\"h\":29},{\"Title\":\"pxa\",\"Cmd\":\"xc \",\"x\":139,\"y\":1,\"w\":72,\"h\":29},{\"Title\":\"dr\",\"Cmd\":\"dr\",\"x\":68,\"y\":29,\"w\":40,\"h\":28},{\"Title\":\"drd\",\"Cmd\":\"drd\",\"x\":107,\"y\":29,\"w\":45,\"h\":28},{\"Title\":\"afl\",\"Cmd\":\"afl\",\"x\":151,\"y\":29,\"w\":60,\"h\":28}' > ~/.local/share/radare2/.r2panels/my-layout
}

install-cutter () {
    cutterVersion="Cutter-v1.10.2-x64.Linux.AppImage"
    cutterUrl="https://github.com/radareorg/cutter/releases/download/v1.10.2/$cutterVersion"

    if [ ! -f ~/tools/"$cutterVersion" ]; then
        cd ~/tools
        curl -LO "$cutterUrl"
        ln -sf "$cutterVersion" ~/bin/Cutter
        chmod +x ~/bin/Cutter
    fi
}

install-openjdk () {
    openjdkVersion="OpenJDK11U-jdk_x64_linux_hotspot_11.0.6_10.tar.gz"
    openjdkUrl="https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.6%2B10/$openjdkVersion"

    cd ~/tools

    if [ ! -f ~/tools/"$openjdkVersion" ]; then
        curl -LO "$openjdkUrl"
    fi

    touch ~/.profile

    if ! fgrep -q 'if [ -d "$HOME/tools/jdk-11.0.6+10/bin" ] ; then
    PATH="$HOME/tools/jdk-11.0.6+10/bin:$PATH"
fi' ~/.profile; then
        tar xvf "$openjdkVersion"
        printf '\nif [ -d "$HOME/tools/jdk-11.0.6+10/bin" ] ; then\n    PATH="$HOME/tools/jdk-11.0.6+10/bin:$PATH"\nfi' >> ~/.profile
        source ~/.profile
    fi
}

install-ghidra () {
    ghidraName="ghidra_9.1.2_PUBLIC"
    ghidraVersion="{$ghidraName}_20200212.zip"
    ghidraUrl="https://ghidra-sre.org/{$ghidraVersion}"

    install-openjdk

    if [ ! -f ~/tools/"{$ghidraName}" ]; then
        curl -O "{$ghidraUrl}"
    fi

    if [ ! -f ~/tools/"{$ghidraName}" ]; then
        7z x "{$ghidraVersion}"
        ln -sf ~/tools/"{$ghidraName}"/ghidraRun ~/bin/Ghidra
        chmod +x ~/bin/Ghidra
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
                    install-radare2
                    while true
                    do
                        options=("Ghidra Decompiler" "Retargetable Decompiler" "Quit")

                        echo "Select plugins to install: "
                        select opt in "${options[@]}"
                        do
                            case $opt in
                                "Ghidra Decompiler")
                                    install-radare2-plugin r2ghidra-dec
                                    ;;
                                "Retargetable Decompiler")
                                    install-radare2-plugin retdec-r2plugin
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
                    install-cutter
                    ;;
                "Ghidra")
                    install-ghidra
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
    update-radare2
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
