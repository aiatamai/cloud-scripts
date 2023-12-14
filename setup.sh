#!/bin/sh
#shellcheck source=config

########## CONFIGURATION ##########
. "$HOME/cloud-media-scripts/config"

########## DOWNLOADS ##########
# Rclone
_rclone_url="https://downloads.rclone.org/rclone-current-linux-amd64.zip" #current stable rclone release

# Plexdrive
_plexdrive_url="https://github.com/dweidenfeld/plexdrive/releases/download/5.2.1/plexdrive-linux-amd64"
_plexdrive_bin="plexdrive-linux-amd64"

# Install Dependencies
echo "installing and/or updating dependencies"

apt-get update
apt-get install unionfs-fuse -qq
apt-get install screen -qq
apt-get install unzip -qq
apt-get install fuse -qq
apt-get install git -qq
apt-get install bc -qq
apt-get install golang -qq

########## Directories ##########
echo "creating directories for automation"

# rclone directories from config
if [ ! -d "${rclone_dir}" ]; then
    mkdir "${rclone_dir}"
fi

# Cloud directories from config
if [ ! -d "${cloud_dir}" ]; then
    mkdir "${cloud_dir}"
fi

# Local directories from config
if [ ! -d "${bin_dir}" ]; then
    mkdir -p "${bin_dir}"
fi

if [ ! -d "${temp_dir}/rclone" ]; then
    mkdir -p "${temp_dir}/rclone"
fi

if [ ! -d "${temp_dir}/plexdrive" ]; then
    mkdir -p "${temp_dir}/plexdrive"
fi

if [ ! -d "${cfg_dir}/plexdrive" ]; then
    mkdir -p "${cfg_dir}/plexdrive"
fi

if [ ! -d "${cfg_dir}/rclone" ]; then
    mkdir -p "${cfg_dir}/rclone"
fi

if [ ! -d "${cfg_dir}/CMS" ]; then
    mkdir -p "${cfg_dir}/CMS"
fi

# Add .bin to path
pathadd() {
    if [ -d "$bin_dir" ] && [[ ":$PATH:" != *":$bin_dir:"* ]]; then
        PATH="${PATH:+"$PATH:"}$bin_dir"
    fi
}

# copy git repo to root of user dir
git clone https://github.com/aiatamai/cloud-scripts.git "${temp_dir}/CMS"
cp -rf "${temp_dir}"/CMS/plexdrive/* "${cfg_dir}/plexdrive"
cp -rf "${temp_dir}"/CMS/rclone/* "${cfg_dir}/rclone"
cp -rf "${temp_dir}"/CMS/config "${cfg_dir}/CMS"
cp -rf "${temp_dir}"/CMS/scripts/* "${bin_dir}"

########## BoltDB ##########

# installing go
echo "installing BoltDB"

#curl -O "${temp_dir}" https://storage.googleapis.com/golang/go1.8.linux-amd64.tar.gz
#tar xvf "${temp_dir}"/go*linux-amd64.tar.gz
#chown -R root:root "${temp_dir}"/go
#mv "${temp_dir}"go /usr/local
mkdir ${gopath}
[[ ":$GOPATH:" != *":${gopath}:"* ]] && GOPATH="${gopath}:${GOPATH}"
#grep -q -F 'include "/configs/projectname.conf"' foo.bar || echo 'include "/configs/projectname.conf"' >> foo.bar
#grep -q -F "export GOPATH=$HOME/work" $HOME/.profile || echo export "GOPATH=$HOME/work" >> $HOME/.profile
#grep -q -F "export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin" $HOME/.profile || echo export "export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin" >> $HOME/.profile
#source ~/.profile

# installing BoltDB
go get github.com/boltdb/bolt/...

########## rclone ##########

echo "Installing or updating to latest stable rclone"

wget -o "${temp_dir}/rclone" "${_rclone_url}"
unzip "${temp_dir}"/rclone/rclone-*-linux-amd64.zip
cd "${temp_dir}"/rclone/rclone-*-linux-amd64 ||
cp -rf rclone "${bin_dir}"
cp rclone.1 /usr/local/share/man/man1/
cd $HOME ||
chown root:root "${bin_dir}/rclone"
chmod 755 "${bin_dir}/rclone"
mkdir -p /usr/local/share/man/man1
mandb --quiet

########## Plexdrive ##########

echo "Installing Plexdrive 5.0.0"

wget -o "${temp_dir}"/plexdrive "${_plexdrive_url}"
cp -rf "${temp_dir}"/plexdrive/"${_plexdrive_bin}" "${bin_dir}/plexdrive"

########## cleanup ##########

echo "cleaning up .tmp directory"

rm -rf "${temp_dir}"

########## Intructions written to .txt ##########

echo "--------- Writing SETUP RCLONE Instrucions ----------"

echo "1. Now run rclone with the command:" >> $HOME/.config/cloud-media-scripts/setup_rclone_instructions.txt
echo "rclone config" >> $HOME/.config/cloud-media-scripts/setup_rclone_instructions.txt
echo "2. You need to setup following:" >> $HOME/.config/cloud-media-scripts/setup_rclone_instructions.txt
echo "Google Drive remote" >> $HOME/.config/cloud-media-scripts/setup_rclone_instructions.txt
echo "Remote name needs to be gd" >> $HOME/.config/cloud-media-scripts/setup_rclone_instructions.txt

echo "-------- Writing SETUP PLEXDRIVE Instructions --------"

echo "1. Now run plexdrive with the command:" >> $HOME/.config/cloud-media-scripts/setup_plexdrive_instructions.txt
echo "pledrive --config=${plexdrive_dir} ${cloud_dir}" >> $HOME/.config/cloud-media-scripts/setup_plexdrive_instructions.txt
echo "2. Enter authorization" >> $HOME/.config/cloud-media-scripts/setup_plexdrive_instructions.txt
echo "3. Cancel plexdrive by pressing CTRL+C" >> $HOME/.config/cloud-media-scripts/setup_plexdrive_instructions.txt
echo "4. Run plexdrive with screen by running the following command:" >> $HOME/.config/cloud-media-scripts/setup_plexdrive_instructions.txt
echo "screen -dmS plexdrive ${plexdrive_options} ${cloud_dir}" >> $HOME/.config/cloud-media-scripts/setup_plexdrive_instructions.txt
echo 'Exit screen session by pressing CTRL+A then D' >> $HOME/.config/cloud-media-scripts/setup_plexdrive_instructions.txt

echo ""go to $HOME/.config/cloud-media-scripts/" to see your setup help instructions"

###################################################

pathadd