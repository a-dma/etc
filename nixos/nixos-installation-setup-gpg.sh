#!/usr/bin/env sh

# This script is meant to be *sourced* (not executed) during a NixOS
# installation. Its purpose is to setup enough of GnuPG to be able to
# get access to git repositories over SSH where the private key is
# stored on a hardware token.
#
# Possibly not the easiest and most straightforward way of
# accomplishing this, but it avoids rebuilding the system's
# configuration and seems to work reliably.

# usage: ~# source ./nixos-installation-setup-gpg.sh~

if [ "$EUID" -ne 0 ]
then
    echo "Please run as root"
    return
fi

# Install software
nix-env -iA nixos.gnupg nixos.pinentry nixos.git

# Populate configuration directory
gpg -k

# Configure gpg-agent to use the right pinentry (the default one is not available here ...)
echo pinentry-program $(which pinentry) >~/.gnupg/gpg-agent.conf

# Set pinentry TTY
export GPG_TTY=$(tty)

# Start gpg-agent
gpg-connect-agent /bye

# Tell gpg-agent to refresh its TTY configuration value
echo UPDATESTARTUPTTY | gpg-connect-agent

# Set SSH authentication socket
export SSH_AUTH_SOCK=~/.gnupg/S.gpg-agent.ssh

# Fix TTY permissions (https://dev.gnupg.org/T3908)
chmod o+rw $(tty)
