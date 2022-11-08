#!/bin/bash

# Variables
seedsigner_app_repo="https://github.com/SeedSigner/seedsigner.git"
seedsigner_app_repo_branch="0.5.1-ram"
config_name="${1:-pi0}"
config_dir="../${config_name}"
rootfs_overlay="${config_dir}/board/raspberrypi/rootfs-overlay"
config_file="${config_dir}/configs/pi0"
cur_dir_name=${PWD##*/}
cur_dir=$(pwd)

echo "${cur_dir}"
echo "${config_dir}"

if [ ! -d "${config_dir}" ]; then
  # config does not exists
  echo "config ${config_name} not found"
  exit 1
fi

# clean up previous build if Makefile exists in /opt/build dir
# if [ -f "${cur_dir}/Makefile" ]; then
#   make clean
#   rm .br2* Makefile
# fi

# Setup external tree
rm -rf "${cur_dir}/../../output"
mkdir -p "${cur_dir}/../../output"
make BR2_EXTERNAL="${config_dir}/" O="${cur_dir}/../../output" -C ../buildroot/ 2> /dev/null > /dev/null

# remove previous opt seedsigner app repo code if it already exists
rm -fr ${rootfs_overlay}/opt/

# Download SeedSigner from GitHub and put into rootfs
git clone --depth 1 -b "${seedsigner_app_repo_branch}" "${seedsigner_app_repo}" "${rootfs_overlay}/opt/"
      
# Delete unnecessary files to save space
rm -rf ${rootfs_overlay}/opt/.git 
rm -rf ${rootfs_overlay}/opt/.gitignore
rm -rf ${rootfs_overlay}/opt/requirements.txt 
rm -rf ${rootfs_overlay}/opt/docs
rm -rf ${rootfs_overlay}/opt/README.md 
rm -rf ${rootfs_overlay}/opt/LICENSE.md
rm -rf ${rootfs_overlay}/opt/enclosures
rm -rf ${rootfs_overlay}/opt/seedsigner_pubkey.gpg 
rm -rf ${rootfs_overlay}/opt/setup.py

cd "${cur_dir}/../../output"
make ${config_name}_defconfig
make

exit 0


