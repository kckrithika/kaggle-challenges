#!/usr/bin/env bash

# To define custom content for your shell, add a block following the pattern:
# cat << 'EOF' > ~/.bashrc.<your_username>
# <your content>
# EOF
#
# To control which alias blocks are installed for yourself, set flags as follows:
# if [[ "$USER" == "<your_username>" ]]; then
#     ALIASES_<the-one-you-want-to-set>=<true|false>
# fi

if [[ "$USER" == "lorrin.nelson" ]]; then
    ALIASES_EXPERIMENTAL=true
fi

cat << 'EOF' > ~/.bashrc.lorrin.nelson
set -o vi
EOF
