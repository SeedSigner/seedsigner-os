#!/bin/bash

# global variables
cur_dir_name=${PWD##*/}
cur_dir=$(pwd)
seedsigner_app_repo="https://github.com/SeedSigner/seedsigner.git"
seedsigner_app_repo_branch="dev"

help()
{
  echo "Usage: build.sh [pi board] [options]
  
  Pi Board: (only one allowed)
  -a, --all         Build for all supported pi boards
      --pi0         Build for pi0 and pi0w
      --pi2         Build for pi2
      --pi02w       Build for pi02w and pi3
      --pi4         Build for pi4 and pi4cmio
      --pi0X        Experimental build for pi0
      --pi02wX      Experimental build for pi02w and pi3
  
  Options:
  -h, --help        Display a help screen and quit 
      --dev         Builds developer version of images
      --no-clean    Leave previous build, target, and output files
      --skip-repo   Skip pulling repo, assume rootfs-overlay/opt is populated with app code
      --app-repo    Build image with not official seedsigner github repo
      --app-branch  Build image with repo branch other than default
      --no-op       All other option ignored and script just hangs to keep container alive"
  exit 2
}

tail_endless() {
  echo "Running 'tail -f /dev/null' to keep script alive"
  tail -f /dev/null
  exit 0
}

download_app_repo() {
  # remove previous opt seedsigner app repo code if it already exists
  rm -fr ${rootfs_overlay}/opt/
  
  # Download SeedSigner from GitHub and put into rootfs
  echo "cloning repo ${seedsigner_app_repo} with branch ${seedsigner_app_repo_branch}"
  git clone --depth 1 -b "${seedsigner_app_repo_branch}" "${seedsigner_app_repo}" "${rootfs_overlay}/opt/" || exit
        
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
  rm -rf ${rootfs_overlay}/opt/tests
  rm -rf ${rootfs_overlay}/opt/tools
  rm -rf ${rootfs_overlay}/opt/pytest.ini
}

build_image() {
  # arguments: $1 - config name, $2 clean/no-clean - allows for, $3 skip-repo

  # Variables
  config_name="${1:-pi0}"
  config_dir="./${config_name}"
  rootfs_overlay="./rootfs-overlay"
  config_file="${config_dir}/configs/pi0"
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
    
  fi
  
  if [ "${3}" != "skip-repo" ]; then
    download_app_repo
  fi
  
  # Setup external tree
  #make BR2_EXTERNAL="../${config_dir}/" O="${build_dir}" -C ./buildroot/ #2> /dev/null > /dev/null

  make BR2_EXTERNAL="../${config_dir}/" O="${build_dir}" -C ./buildroot/ ${config_name}_defconfig
  cd "${build_dir}"
  make
  
  # if successful, mv seedsigner_os.img image to /images
  # rename to image to include branch name and config name, then compress
  
  if [ -f "${build_dir}/images/seedsigner_os.img" ] && [ -d "${image_dir}" ]; then
    mv -f "${build_dir}/images/seedsigner_os.img" "${image_dir}/seedsigner_os.${seedsigner_app_repo_branch}.${config_name}.img"
  fi
  
  cd - # return to previous working directory
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
  --pi2)
    PI2_FLAG=0; ((ARCH_CNT=ARCH_CNT+1)); shift
    ;;
  --pi02w)
    PI02W_FLAG=0; ((ARCH_CNT=ARCH_CNT+1)); shift
    ;;
  --pi4)
    PI4_FLAG=0; ((ARCH_CNT=ARCH_CNT+1)); shift
    ;;
  --pi0X)
    PI0X_FLAG=0; ((ARCH_CNT=ARCH_CNT+1)); shift
    ;;
  --pi02wX)
    PI02WX_FLAG=0; ((ARCH_CNT=ARCH_CNT+1)); shift
  ;;
  --no-clean)
    NOCLEAN=0; shift
    ;;
  --skip-repo)
    SKIPREPO=0; shift
    ;;
  --no-op)
    NO_OP=0; shift
    ;;
  --dev)
    DEVBUILD=0; shift
    ;;
  --app-repo=*)
    APP_REPO=$(echo "${1}" | cut -d "=" -f2-); shift
    ;;
  --app-branch=*)
    APP_BRANCH=$(echo "${1}" | cut -d "=" -f2-); shift
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

# if no-op then hang endlessly
if ! [ -z $NO_OP ]; then
  tail_endless
  exit 0
fi

# Check for --no-clean argument to pass clean/no-clean to build_image function
if [ -z $NOCLEAN ]; then
  CLEAN_ARG="clean"
else
  CLEAN_ARG="no-clean"
fi

# Check for --no-clean argument to pass clean/no-clean to build_image function
if ! [ -z $SKIPREPO ]; then
  SKIPREPO_ARG="skip-repo"
else
  SKIPREPO_ARG="no-skip-repo"
fi

echo $SKIPREPO_ARG

# Check for --dev argument to pass to build_image function
DEVARG=""
if ! [ -z $DEVBUILD ]; then
  DEVARG="-dev"
fi

# check for custom app repo
if ! [ -z ${APP_REPO} ]; then
  seedsigner_app_repo="${APP_REPO}"
fi

# check for custom app branch
if ! [ -z ${APP_BRANCH} ]; then
  seedsigner_app_repo_branch="${APP_BRANCH}"
fi

###
### Run build_image function based on input arguments
###

# Build All Architectures
if ! [ -z ${ALL_FLAG} ]; then
  build_image "pi0${DEVARG}" "clean" "${SKIPREPO_ARG}"
  build_image "pi02w${DEVARG}" "clean" "skip-repo"
  build_image "pi2${DEVARG}" "clean" "skip-repo"
  build_image "pi4${DEVARG}" "clean" "skip-repo"
fi

# Build only for pi0, pi0w, and pi1
if ! [ -z ${PI0_FLAG} ]; then
  build_image "pi0${DEVARG}" "${CLEAN_ARG}" "${SKIPREPO_ARG}"
fi

# Build only for pi2
if ! [ -z ${PI2_FLAG} ]; then
  build_image "pi2${DEVARG}" "${CLEAN_ARG}" "${SKIPREPO_ARG}"
fi


# build for pi02w
if ! [ -z ${PI02W_FLAG} ]; then
  build_image "pi02w${DEVARG}" "${CLEAN_ARG}" "${SKIPREPO_ARG}"
fi

# build for pi4
if ! [ -z ${PI4_FLAG} ]; then
  build_image "pi4${DEVARG}" "${CLEAN_ARG}" "${SKIPREPO_ARG}"
fi

# Build experimental  for pi0, pi0w, and pi1
if ! [ -z ${PI0X_FLAG} ]; then
  echo "building pi0X${DEVARG} image"
  build_image "pi0X${DEVARG}" "${CLEAN_ARG}" "${SKIPREPO_ARG}"
fi

# Build experimental  for pi0, pi0w, and pi1
if ! [ -z ${PI02WX_FLAG} ]; then
  echo "building pi02wX${DEVARG} image"
  build_image "pi02wX${DEVARG}" "${CLEAN_ARG}" "${SKIPREPO_ARG}"
fi

exit 0
