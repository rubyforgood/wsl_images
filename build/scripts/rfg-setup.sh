#!/usr/bin/env bash
set -euo pipefail

MARKER="$HOME/.rfg-setup-complete"

if [[ "${1:-}" != "--force" && -f "$MARKER" ]]; then
  echo "Setup has already been completed. Run 'rfg-setup --force' to run it again."
  exit 0
fi

if [[ -f "/.dockerenv" ]]; then
  sudo rm -f "/.dockerenv"
fi

echo
echo "🎉 Welcome to the Ruby for Good contributor environment!"
echo
echo "This script will help you set up your environment in a few steps"
echo "  - Set Git identity values"
echo "  - Authenticate with GitHub"
echo "  - Clone Ruby for Good repositories"
echo

# --- Git identity ---
current_name="$(git config --global user.name || true)"
current_email="$(git config --global user.email || true)"

read -rp "Git user.name${current_name:+ [$current_name]}: " git_name
git_name="${git_name:-$current_name}"

read -rp "Git user.email${current_email:+ [$current_email]}: " git_email
git_email="${git_email:-$current_email}"

if [[ -n "$git_name" ]]; then
  git config --global user.name "$git_name"
fi

if [[ -n "$git_email" ]]; then
  git config --global user.email "$git_email"
fi

# --- GitHub authentication ---
if gh auth status >/dev/null 2>&1; then
  echo "✅ Already authenticated with GitHub CLI."
else
  echo
  echo "Let's authenticate the GitHub CLI."
  gh auth login --git-protocol https --web
fi

# --- Repository discovery ---
echo
echo "Fetching current Ruby for Good repositories..."

mapfile -t repos < <(
  gh repo list rubyforgood \
    --source \
    --no-archived \
    --visibility public \
    --limit 1000 \
    --json nameWithOwner \
    --jq '.[].nameWithOwner'
)

if (( ${#repos[@]} == 0 )); then
  echo "No public Ruby for Good repositories were found."
  touch "$MARKER"
  exit 0
fi

echo
echo "Select the Ruby for Good repositories to clone."
echo "Enter repository numbers separated by spaces, or 'a' for all."
echo

for index in "${!repos[@]}"; do
  printf '%3d) %s\n' "$((index + 1))" "${repos[$index]}"
done

echo
read -rp "Repositories to clone: " selection

mkdir -p "$HOME/workspace"

if [[ "$selection" == "a" || "$selection" == "A" ]]; then
  selected_indices=("${!repos[@]}")
else
  read -r -a selected_indices <<< "$selection"
fi

for value in "${selected_indices[@]}"; do
  if ! [[ "$value" =~ ^[0-9]+$ ]]; then
    echo "Skipping invalid selection: $value"
    continue
  fi

  index=$((value - 1))

  if (( index < 0 || index >= ${#repos[@]} )); then
    echo "Skipping out-of-range selection: $value"
    continue
  fi

  repo="${repos[$index]}"
  destination="$HOME/workspace/$(basename "$repo")"

  if [[ -d "$destination/.git" ]]; then
    echo "↷ $repo already cloned at $destination, skipping."
    continue
  fi

  if [[ -e "$destination" ]]; then
    echo "⚠️  $destination exists but is not a Git repository; skipping $repo."
    continue
  fi

  echo "Cloning $repo..."
  gh repo clone "$repo" "$destination"
done

touch "$MARKER"

echo
echo "✅ Setup complete."
echo "Run 'rfg-setup --force' to go through this setup again if you need to change your Git identity or clone more repositories."
echo
