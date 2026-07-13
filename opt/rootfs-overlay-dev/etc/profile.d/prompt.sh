# Dev-image shell prompt: "user@host dir %" where dir is the current working
# directory's NAME (its basename, \W), not the full path.
# Sourced by /etc/profile (login shells: SSH and the HDMI/serial console).
# Only applied for interactive bash (root's shell); other shells keep the
# default prompt. Colors: green user@host, blue directory.
#
# \W = basename of the cwd (use \w for the full path). % is just the prompt
# character (bash treats it literally).
if [ -n "$BASH_VERSION" ] && [ -n "$PS1" ]; then
	PS1='\[\e[1;32m\]\u@\h\[\e[0m\] \[\e[1;34m\]\W\[\e[0m\] % '
fi
