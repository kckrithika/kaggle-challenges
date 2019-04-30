# Delete any previous content from bashrc
cat ~/.bashrc | awk '/^# BEGIN customize-shell-install.sh$/{flag=1}/^# END customize-shell-install.sh$/{flag=0;next}flag' > .bashrc.tmp
mv .bashrc.tmp ~/.bashrc
# Add current content
cat << EOF >> ~/.bashrc
# BEGIN customize-shell-install.sh
source ~/aliases
if [ -f ~/.bashrc.\$USER ]; then
    source ~/.bashrc.\$USER
fi
echo "Shell customizations last updated $DATE. To update, run customize-shell-install.
# END customize-shell-install.sh
EOF
