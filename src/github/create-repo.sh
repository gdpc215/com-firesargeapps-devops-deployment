#!/bin/bash

set -e  # Exit on error

REPO_NAME=$1

if [ -z "$REPO_NAME" ]; then
    echo "Error: Repository name is required"
    echo "Usage: $0 <repository-name>"
    exit 1
fi

echo "Creating repository: $REPO_NAME"

# Get the organization name from the current repo context
ORG_NAME=$(gh repo view --json owner -q '.owner.login')

echo "Organization: $ORG_NAME"

# Create the repository
gh repo create "$ORG_NAME/$REPO_NAME" --public

# Configure git to use the token for authentication
git config --global credential.helper store
echo "https://oauth2:${GH_TOKEN}@github.com" > ~/.git-credentials

# Clone the newly created repository
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"
git clone "https://github.com/$ORG_NAME/$REPO_NAME.git"
cd "$REPO_NAME"

# Create an empty README.md
echo "# $REPO_NAME" > README.md

# Add, commit, and push to main/master branch
git add README.md
git commit -m "Initial commit: Add README"
git push origin HEAD

# Get the default branch name (could be main or master)
DEFAULT_BRANCH=$(git branch --show-current)

# Create develop branch
echo "Creating develop branch..."
git checkout -b develop
git push origin develop

# Create feature/initial branch
echo "Creating feature/initial branch..."
git checkout "$DEFAULT_BRANCH"
git checkout -b feature/initial
git push origin feature/initial

# Cleanup
cd ../..
rm -rf "$TEMP_DIR"
rm ~/.git-credentials

echo "Repository $REPO_NAME created successfully with branches: $DEFAULT_BRANCH, develop, feature/initial"
