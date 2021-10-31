#!/usr/bin/env bash

# This script is used to initialize container envrionment for Python project development.

# set -e

info() {
  printf '\E[32m'; echo "$@"; printf '\E[0m'
}


error() {
  printf '\E[31m'; echo "$@"; printf '\E[0m'
}

# -------------------------
if [[ $EUID -ne 0 ]]; then # root user
    error "Please run this script as the root user."
    exit 1
fi

# -------------------------
info "update && upgrade"
apt -q update && apt -q upgrade -y

# -------------------------
info "install common libraries"
apt -q install -y --no-install-recommends \
    sudo \
    curl \
    git \
    tmux \
    nano \
    htop \
    neofetch \
    direnv

# -------------------------
# look for user
USERNAME="automatic"
# If in automatic mode, determine if a user already exists
if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
    USERNAME=""
    POSSIBLE_USERS=("$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
    for CURRENT_USER in "${POSSIBLE_USERS[@]}"; do
        if id -u "${CURRENT_USER}" > /dev/null 2>&1; then
            USERNAME=${CURRENT_USER}
            info "found existing user: $USERNAME"
            break
        fi
    done
fi

if [ "${USERNAME}" = "" ]; then
    error "Couldn't find existing user, exit..."
    exit 1
fi

# user .bashrc path
if [ "${USERNAME}" = "root" ]; then
    USER_RC_PATH="/root"
else
    USER_RC_PATH="/home/${USERNAME}"
fi
# user .bashrc
USER_RC=$USER_RC_PATH/.bashrc

if [ ! -f "$USER_RC" ]; then
    error "$USER_RC does not exists, exit..."
    exit 1
fi

INIT_SH_PATH="$USER_HOME/init.sh"
wget https://raw.githubusercontent.com/taicaile/init.sh/master/init.sh -O  "$INIT_SH_PATH"

# append this

INIT_HOOK_LINE="source $INIT_SH_PATH"
grep -qF -- "$INIT_HOOK_LINE" "$USER_RC" || {
    echo "$INIT_HOOK_LINE" >>"$USER_RC"
    # shellcheck disable=SC1090
    source "$USER_RC"
}

# -------------------------
info "The following versions of Python are installed in this machine:"
for p in $(find  /usr/bin/python* | grep -P 'python[\d](.[\d])?+$')
do
  info "$p" "$($p --version)"
done