sudo xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
/opt/homebrew/bin/brew bundle --file "~/.config/homebrew/init.brewfile"
pip install --upgrade `pip list --outdated | awk 'NR>2 {print $1}'`
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1 && nvim