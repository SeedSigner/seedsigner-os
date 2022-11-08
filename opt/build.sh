#!/bin/bash

help()
{
  echo "Usage: build.sh [ -h | --help ]

    pick a single build architecture:
    
    [ --pi0 ] # image only created for pi0
    [ --pi02w ] # image only created for pi02w
    
    or build them all (longest compile time)
    
    [ -a | --all ]
    
    developer options:
    
    [ --dev ] # creates dev version of image
    [ --no-clean ] # build without clean, make br2_external, or seedsigner app clone
                   # allows for partial recompile; ignored when using --all
    [ --app-repo ] # TODO: Implement
    [ --app-branch ] # TODO: Implement
    [ --keep-alive ] # keeps container running after build.sh completes"
  exit 2
}

build_image() {
  # arguments: $1 - config name, $2 clean/no-clean - allows for 

  # Variables
  seedsigner_app_repo="https://github.com/SeedSigner/seedsigner.git"
  seedsigner_app_repo_branch="0.5.1-ram"
  config_name="${1:-pi0}"
  config_dir="./${config_name}"
  rootfs_overlay="./rootfs-overlay"
  config_file="${config_dir}/configs/pi0"
  cur_dir_name=${PWD##*/}
  cur_dir=$(pwd)
  build_dir="${cur_dir}/../output"
  build2_dir="${cur_dir}/../../output"
  image_dir="${cur_dir}/../images"

  if [ ! -d "${config_dir}" ]; then
    # config does not exists
    echo "config ${config_name} not found"
    exit 1
  fi
  
  if [ "${2}" != "no-clean" ]; then
  
    # remove previous build dir
    rm -rf "${build_dir}"
    mkdir -p "${build_dir}"
    
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
    
  fi
  
  # Setup external tree
  make BR2_EXTERNAL="../${config_dir}/" O="${build_dir}" -C ./buildroot/ # 2> /dev/null > /dev/null
  
  cd "${build_dir}"
  make ${config_name}_defconfig
  make
  
  # if successful, mv seedsigner_os.img image to /images
  # rename to image to include branch name and config name, then compress
  
  if [ -f "${build_dir}/images/seedsigner_os.img" ] && [ -d "${image_dir}" ]; then
    mv -f "${build_dir}/images/seedsigner_os.img" "${image_dir}/seedsigner_os.${seedsigner_app_repo_branch}.${config_name}.img"
    gzip -f "${image_dir}/seedsigner_os.${seedsigner_app_repo_branch}.${config_name}.img"
    mv -f "${build_dir}/images" "${image_dir}/seedsigner_os.${seedsigner_app_repo_branch}.${config_name}"
  fi
  
}

###
### Gather Arguments passed into build.sh script
###

VALID_ARGUMENTS=$# # Returns the count of arguments that are in short or long options

if [ "$VALID_ARGUMENTS" -eq 0 ]; then
  help
fi

PARAMS=""
ARCH_CNT=0
while (( "$#" )); do
  case "$1" in
  -a|--all)
    ALL_FLAG=0; ((ARCH_CNT=ARCH_CNT+1)); shift
    ;;
  -h|--help)
    HELP_FLAG=0; shift
    ;;
  --pi0)
    PI0_FLAG=0; ((ARCH_CNT=ARCH_CNT+1)); shift
    ;;
  --pi02w)
    PI02W_FLAG=0; ((ARCH_CNT=ARCH_CNT+1)); shift
    ;;
  --no-clean)
    NOCLEAN=0; shift
    ;;
  --keep-alive)
    KEEPALIVE=0; shift
    ;;
  --dev)
    DEVBUILD=0; shift
    ;;
  -*|--*=) # unsupported flags
    echo "Error: Unsupported flag $1" >&2
    help
    exit 1
    ;;
  *) # unsupported flags
    echo "Error: Unsupported argument $1" >&2
    help
    exit 1
    ;;
  esac
done

# When no arguments, display help
if ! [ -z ${HELP_FLAG} ]; then
  help
fi

# Only allow 1 architecture related argument flag
if [ $ARCH_CNT -gt 1 ]; then
  echo "Invalid number of architecture arguments" >&2
  exit 3
fi

# Check for --no-clean argument to pass clean/no-clean to build_image function
if [ -z $NOCLEAN ]; then
  CLEAN_ARG="clean"
else
  CLEAN_ARG="no-clean"
fi

# Check for --dev argument to pass to build_image function
DEVARG=""
if ! [ -z $DEVBUILD ]; then
  DEVARG="-dev"
fi

###
### Run build_image function based on input arguments
###

# Build All Architectures
if ! [ -z ${ALL_FLAG} ]; then
  build_image "pi0${DEVARG}" "clean"
  build_image "pi02w${DEVARG}" "clean"
fi

# Build only for pi0, pi0w, and pi1
if ! [ -z ${PI0_FLAG} ]; then
  build_image "pi0${DEVARG}" "${CLEAN_ARG}"
fi

# build for pi02w
if ! [ -z ${PI02W_FLAG} ]; then
  build_image "pi02w${DEVARG}" "${CLEAN_ARG}"
fi

# if build.sh makes it this far without errors, and --keep-alive flag is set, then keep container/script running
if ! [ -z $KEEPALIVE ]; then
  tail -f /dev/null
fi

exit 0

