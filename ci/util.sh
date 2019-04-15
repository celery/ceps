############################## UTILITY FUNCTIONS ##############################

# Print to given argument to stdout, followed by a newline.
errata_print () {
    printf "\\n" && printf %"s\\n" "$1"
}

# Run the given command with its output suppressed.
errata_quiet_cmd () {
    "$1" &> /dev/null
}

errata_banner_print () {
    printf '#%.0s' {1..100}
}

################################ DEPENDENCIES #################################

if which node > /dev/null && which npm > /dev/null
then
    echo "Found Node.js ($(node -v)) and npm ($(npm -v))."
else
    export NVM_DIR="$HOME/.nvm"
    # `NVM` is our version of `nvm` (https://github.com/creationix/nvm).
    NVM="0.33.11"

    NVM_SH="https://raw.githubusercontent.com/creationix/nvm/v$NVM/install.sh"
    errata_quiet_cmd "curl -o- $NVM_INSTALL | bash"

    # shellcheck source=/dev/null
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install 10.11.0
fi