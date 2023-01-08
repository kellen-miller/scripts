#!/bin/zsh

function su() {
  if [[ $# -eq 0 || (-n $1 && $1 = "--skip-mas") ]]; then
    brew_update "$@"
    gcloud_update
    macOS_update
  else
    while [[ $# -gt 0 ]]; do
      case $1 in
        -l|--list)
          brew_list
          gcloud_list
          macOS_list
          return 0
        ;;
        -h|--help)
          print_help
          return 1
        ;;
        *)
          echo "Invalid argument: $1"
          print_help
          return 1
        ;;
      esac
    done
  fi
}

function brew_update() {
  printf "\n### Updating Homebrew Packages ###\n"
  brew_check
  if [[ -n $1 && $1 = "--skip-mas" ]]; then
    mas_check
  fi
  brew_dump
  brew bundle -v
  outdated=$(brew outdated)
  if [[ -n $outdated ]]; then
    echo "$outdated" | awk '{print $1}' | xargs brew install -v
    brew_dump
  fi
}

function brew_list() {
  printf "Outdated Homebrew Packages:\n"
  brew outdated
}

function brew_check() {
  createBrewfile=false
  brewfilePath=""
  if [[ -n $HOMEBREW_BUNDLE_FILE ]]; then
    if [[ -f $HOMEBREW_BUNDLE_FILE ]]; then
      return
    else
      echo ".Brewfile not found at $HOMEBREW_BUNDLE_FILE, creating one"
      brewfilePath=$HOMEBREW_BUNDLE_FILE
      createBrewfile=true
    fi
  else
    echo "HOMEBREW_BUNDLE_FILE environment variable not set, checking user's directories for .Brewfile..."
    brewfile=$(find "$HOME" -type f -iname "*.Brewfile" -maxdepth 5 -print -quit 2>/dev/null)
    if [[ -n $brewfile ]]; then
      echo ".Brewfile found at $brewfile"
      brewfilePath=$brewfile
    else
      echo "No .Brewfile found, creating one at $HOME/.config/homebrew/.Brewfile"
      brewfilePath="$HOME/.config/homebrew/.Brewfile"
      createBrewfile=true
    fi
    export HOMEBREW_BUNDLE_FILE=$brewfilePath
    echo "Setting HOMEBREW_BUNDLE_FILE to $brewfilePath in .zshrc"
    printf '$-3i\n%s\n.\nw\n' "export HOMEBREW_BUNDLE_FILE=$brewfilePath" | ed -s .zshrc
  fi
  if [[ $createBrewfile == true ]]; then
    mkdir -p "$(dirname "$brewfilePath")"
    touch "$brewfilePath"
  fi
}

function brew_dump() {
  brew bundle dump -f --describe
}

function mas_check() {
  if [[ -z $(command -v mas) ]]; then
    read -q "REPLY?mas tool not found. mas is used to update Mac App Store apps, do you want to install via brew? [y/n]: "
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      brew install mas
    fi
  fi
}

function gcloud_update() {
  printf "\n\n### Updating Google Cloud Components ###\n"
  gcloud components update --verbosity=info --quiet
}

function gcloud_list() {
  printf "\nOutdated Google Cloud Components:\n"
  gcloud components list --filter="state.name='Installed' AND current_version_string NOT latest_version_string"
}

function macOS_update() {
   printf "\n\n### Updating MacOS ###\n"
   softwareupdate -ia --agree-to-license --force --verbose
}

function macOS_list() {
  printf "\nOutdated MacOS Packages:\n"
  softwareupdate -l
}

function print_help() {
  echo "Usage: sysup [OPTION]"
  echo "Update system and installed packages"
  echo ""
  echo "Commands sysup runs:"
  echo "  brew bundle -v"
  echo "  gcloud components update --verbosity=info --quiet"
  echo "  softwareupdate -ia --agree-to-license --force --verbose"
  echo ""
  echo "Options:"
  echo "  -l, --list    List updates"
  echo "  --skip-mas    Skips updating Mac App Store apps"
  echo "  -h, --help    Print help"
  echo "  no options    Run all updates"
}