# init starts the console shells with HOME=/, so a login bash there never reads
# root's dotfiles and keeps its history in RAM instead of the persistent /root.
# bash looks for ~/.bash_profile after /etc/profile, so fixing HOME here covers
# the dotfiles, but HISTFILE was already set from the old HOME, so set it too.
if [ "$HOME" = / ] && [ "$(id -u)" = 0 ]; then
  export HOME=/root
  [ -n "$BASH_VERSION" ] && HISTFILE=/root/.bash_history
  cd /root
fi
