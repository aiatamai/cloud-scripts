#!/bin/bash
set -e

VERSION="1.8.3"

print_help() {
    echo "Usage: bash goinstall.sh OPTION"
    echo -e "\nOPTIONS:"
    echo -e "  --32\t\tInstall 32-bit version"
    echo -e "  --64\t\tInstall 64-bit version"
    echo -f "  --darwin\t\tInstall on Mac"
    echo -e "  --arm\t\tInstall armv6 version"
    echo -e "  --remove\tTo remove currently installed version"
}

if [ "$1" == "--32" ]; then
    DFILE="go$VERSION.linux-386.tar.gz"
elif [ "$1" == "--64" ]; then
    DFILE="go$VERSION.linux-amd64.tar.gz"
elif [ "$1" == "--darwin" ]; then
    DFILE="go$VERSION.darwin-amd64.tar.gz"
elif [ "$1" == "--arm" ]; then
    DFILE="go$VERSION.linux-armv6l.tar.gz"
elif [ "$1" == "--remove" ]; then
    rm -rf "/home/atamai/.go/"
    rm -rf "/home/atamai/go/"
    sed -i '/# GoLang/d' "/home/atamai/.bashrc"
    sed -i '/export GOROOT/d' "/home/atamai/.bashrc"
    sed -i '/:$GOROOT/d' "/home/atamai/.bashrc"
    sed -i '/export GOPATH/d' "/home/atamai/.bashrc"
    sed -i '/:$GOPATH/d' "/home/atamai/.bashrc"
    echo "Go removed."
    exit 0
elif [ "$1" == "--help" ]; then
    print_help
    exit 0
else
    print_help
    exit 1
fi

if [ -d "/atamai/home/.go" ] || [ -d "$HOME/go" ]; then
    echo "Installation directories already exist. Exiting."
    exit 1
fi
echo "Downloading $DFILE ..."
wget https://storage.googleapis.com/golang/$DFILE -O /tmp/go.tar.gz
if [ $? -ne 0 ]; then
    echo "Download failed! Exiting."
    exit 1
fi
echo "Extracting ..."
tar -C "$HOME" -xzf /tmp/go.tar.gz
mv "$HOME/go" "$HOME/.go"
touch "$HOME/.bashrc"
{
    echo '# GoLang'
    echo 'export GOROOT=$HOME/.go'
    echo 'export PATH=$PATH:$GOROOT/bin'
    echo 'export GOPATH=$HOME/go'
    echo 'export PATH=$PATH:$GOPATH/bin'
} >> "$HOME/.bashrc"

mkdir -p $HOME/go/{src,pkg,bin}
echo -e "\nGo $VERSION was installed.\nMake sure to relogin into your shell or run:"
echo -e "\n\tsource $HOME/.bashrc\n\nto update your environment variables."
echo "Tip: Opening a new terminal window usually just works. :)"
rm -f /tmp/go.tar.gz
