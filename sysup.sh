#!/bin/zsh

function sysup() {
  if [[ $# -eq 0 ]]; then
    brew_update
    gcloud_update
    macos_update
  else
    while [[ $# -gt 0 ]]; do
      case $1 in
        -l|--list)
          brew_list
          gcloud_list
          macos_list
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
  printf "### Updating Homebrew Packages ###\n"
  brew_check
  brew_dump
  brew bundle -v --cleanup
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
      echo ".Brewfile not found at $HOMEBREW_BUNDLE_FILE, creating one..."
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
      echo "No .Brewfile found, creating one at $HOME/.config/homebrew/.Brewfile..."
      brewfilePath="$HOME/.config/homebrew/.Brewfile"
      createBrewfile=true
    fi
    export HOMEBREW_BUNDLE_FILE=$brewfilePath
    echo "Setting HOMEBREW_BUNDLE_FILE to $brewfilePath in .zshrc"
    printf '$-3i\nexport HOMEBREW_BUNDLE_FILE=%s\n.\nw\n' "$brewfilePath" | ed -s .zshrc
  fi
  if [[ $createBrewfile == true ]]; then
    mkdir -p "$(dirname "$brewfilePath")"
    touch "$brewfilePath"
    brew_dump
  fi
}

function brew_dump() {
  brew bundle dump -f --describe
}

function gcloud_update() {
  printf "\n### Updating Google Cloud Components ###\n"
  gcloud components update --verbosity=info --quiet
}

function gcloud_list() {
  printf "\nOutdated Google Cloud Components:\n"
  gcloud components list --filter="state.name='Installed' AND current_version_string NOT latest_version_string"
}

function macos_update() {
   printf "\n### Updating MacOS ###\n"
   softwareupdate -i -a
}

function macos_list() {
  printf "\nOutdated MacOS Packages:\n"
  softwareupdate -l
}

function print_help() {
  echo "Usage: sysup [OPTION]"
  echo "Update system and installed packages"
  echo ""
  echo "Commands run:"
  echo "  brew bundle -v --cleanup"
  echo "  gcloud components update --verbosity=info --quiet"
  echo "  softwareupdate -i -a"
  echo ""
  echo "Options:"
  echo "  -l, --list    List updates"
  echo "  -h, --help    Print help"
  echo "  no options    Run all updates"
}