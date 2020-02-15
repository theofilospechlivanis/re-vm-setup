#!/bin/bash

radare2 () {
	git clone https://github.com/radareorg/radare2 ~/tools/radare2
	~/tools/radare2/sys/user.sh

	if ! grep -q SomeString ~/.profile; then
        echo "bin is in path"
	fi

	source ~/.profile

    if [ "$1" = "r2ghidra-dec" ]; then
        r2pm init
        r2pm update
        r2pm -i r2ghidra-dec
    fi
}

cutter () {
    curl -L https://github.com/radareorg/cutter/releases/download/v1.10.0/Cutter-v1.10.0-x64.Linux.appimage -o ~/bin/Cutter
	chmod +x ~/bin/Cutter
}

ghidra () {
	cd ~/tools

	curl -LO https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.5%2B10/OpenJDK11U-jdk_x64_linux_hotspot_11.0.5_10.tar.gz
	tar xvf OpenJDK11U-jdk_x64_linux_hotspot_11.0.5_10.tar.gz

	if ! grep -q SomeString ~/.profile; then
        echo "jdk is in path"
	fi

	echo '
	if [ -d "$HOME/tools/jdk-11.0.5+10/bin" ] ; then
	    PATH="$HOME/tools/jdk-11.0.5+10/bin:$PATH"
	fi' >> ~/.profile

	source ~/.profile

	curl -O https://ghidra-sre.org/ghidra_9.1.1_PUBLIC_20191218.zip
	7z x ghidra_9.1.1_PUBLIC_20191218.zip
}

install () {
	sudo apt install `cat ubuntu/packages`

	[ -f ~/bin ] || mkdir ~/bin
	[ -f ~/tools ] || mkdir ~/tools

    PS3='Select tools to install: '
    options=("radare2" "Cutter (r2gui)" "Ghidra" "Quit")
    select opt in "${options[@]}"
    do
        case $opt in
            "radare2")
                echo "Install the Ghidra Decompiler as well? [y/N]"
                read input
                if [ "$input" = "Y" ] || [ "$input" = "y" ]; then
                    radare2 r2ghidra-dec
                else
                    radare2
                fi
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

PS3='Please enter your choice: '
options=("Install tools and packages" "Update tools and packages" "Remove tools and packages" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Install tools and packages")
            echo "You chose choice 1"
            ;;
        "Update tools and packages")
            echo "You chose choice 2"
            ;;
        "Remove tools and packages")
            echo "You chose choice 3"
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
