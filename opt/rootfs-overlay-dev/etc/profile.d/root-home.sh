# init starts the console shells with HOME=/, so a login bash there looks for
# /.bash_profile and never reads root's dotfiles, and keeps its history in RAM
# instead of the persistent /root. bash expands ~/.bash_profile after
# /etc/profile, so fixing HOME here is enough.
if [ "$HOME" = / ] && [ "$(id -u)" = 0 ]; then
  export HOME=/root
  cd /root
fi
