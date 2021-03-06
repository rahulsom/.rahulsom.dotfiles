source "${HOME}/.oh-your-dotfiles/lib/dotfiles.zsh"

# Create a default `user.gitconfig` if it doesn't exist
if [ ! -f ~/user.gitconfig ]; then
  cat >~/user.gitconfig <<EOF
[user]
  name = Daniel Thomas
  email = danny.thomas@example.com
[shell]
  # Default SSH username. Defaults to \`git\`.
  #username = danny
[github]
  # GitHub username for command-line tools.
  user = DanielThomas
[alias]
  # Push the current branch upstream to \`danny\` using the same branch name for the remote branch.
  um = !git push --set-upstream danny \$(git current-branch)
EOF
fi

# gitconfig
echo "[include]" >~/.gitconfig
for file_source in $(dotfiles_find \*.gitconfig); do
  echo "  path = $file_source" >>~/.gitconfig
done
echo "  path = ~/user.gitconfig" >>~/.gitconfig
