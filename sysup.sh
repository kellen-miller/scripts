#! /bin/zsh

function sysup() {
  if [[ $# -eq 0 ]]; then
    update_brew
    update_gcloud
    update_macos
  else
    while [[ $# -gt 0 ]]; do
      case $1 in
        -l|--list)
          list_brew
          list_gcloud
          list_macos
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

function update_brew() {
  printf "Updating Homebrew Packages...\n"
  brew bundle -v --cleanup
  outdated=$(brew outdated)
  if [[ -n $outdated ]]; then
    echo "$outdated" | awk '{print $1}' | xargs brew install -v
    brew bundle dump -f --describe
  fi
}

function list_brew() {
  printf "Outdated Homebrew Packages:\n"
  brew outdated
}

function update_gcloud() {
  printf "\nUpdating Google Cloud Components...\n"
  gcloud components update --verbosity=info --quiet
}

function list_gcloud() {
  printf "\nOutdated Google Cloud Components:\n"
  gcloud components list --filter="state.name='Installed' AND current_version_string NOT latest_version_string"
}

function update_macos() {
   printf "\nUpdating MacOS...\n"
   softwareupdate -i -a
}

function list_macos() {
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