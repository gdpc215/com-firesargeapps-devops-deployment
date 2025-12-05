#!/bin/bash

set -e  # Exit on error

PROJECT_ID=$1
PROJECT_TYPE=${2:-container}  # Default to container if not specified

if [ -z "$PROJECT_ID" ]; then
    echo "Error: Project ID is required"
    echo "Usage: $0 <project-id> [project-type]"
    echo "  project-type: container (default) or functions"
    exit 1
fi

# Validate project ID format (4 characters)
if [[ ! "$PROJECT_ID" =~ ^[a-z0-9]{4}$ ]]; then
    echo "Error: Project ID must be exactly 4 characters (lowercase letters and numbers only)"
    exit 1
fi

# Validate project type
if [[ ! "$PROJECT_TYPE" =~ ^(container|functions)$ ]]; then
    echo "Error: Project type must be 'container' or 'functions'"
    exit 1
fi

echo "Creating repositories for project: $PROJECT_ID (Type: $PROJECT_TYPE)"

# Get the organization name from the current repo context
ORG_NAME=$(gh repo view --json owner -q '.owner.login')
echo "Organization: $ORG_NAME"

# Configure git to use the token for authentication
git config --global credential.helper store
echo "https://oauth2:${GH_TOKEN}@github.com" > ~/.git-credentials

# Get the path to templates
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/../../project-templates"

# Function to create a repository with templates
create_repo_with_templates() {
    local REPO_SUFFIX=$1
    local TEMPLATE_TYPE=$2
    local REPO_NAME="fsapps-${PROJECT_ID}-${REPO_SUFFIX}"
    
    echo "=========================================="
    echo "Creating repository: $REPO_NAME"
    echo "=========================================="
    
    # Check if repository exists and delete it. Needs delete_repo permission.
    # if gh repo view "$ORG_NAME/$REPO_NAME" >/dev/null 2>&1; then
    #     echo "Repository $REPO_NAME already exists. Deleting..."
    #     gh repo delete "$ORG_NAME/$REPO_NAME" --yes
    #     echo "Repository $REPO_NAME deleted successfully"
    # fi
    
    # Create the repository
    gh repo create "$ORG_NAME/$REPO_NAME" --public
    
    # Clone the newly created repository
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    git clone "https://github.com/$ORG_NAME/$REPO_NAME.git"
    cd "$REPO_NAME"
    
    # Create README.md
    echo "# $REPO_NAME" > README.md
    echo "" >> README.md
    echo "Project ID: $PROJECT_ID, Repo: $REPO_NAME" >> README.md
    
    # Add, commit, and push to master branch
    git add README.md
    git commit -m "Initial commit: Add README"
    git push origin HEAD
    
    # Get the default branch name
    DEFAULT_BRANCH=$(git branch --show-current)
    
    # Create develop branch
    echo "Creating develop branch..."
    git checkout -b develop
    git push origin develop
    
    # Create feature/initial branch with templates
    echo "Creating feature/initial branch with templates..."
    git checkout "$DEFAULT_BRANCH"
    git checkout -b feature/initial
    
    # Copy template files
    TEMPLATE_PATH="$TEMPLATES_DIR/$TEMPLATE_TYPE"
    if [ -d "$TEMPLATE_PATH" ]; then
        echo "Copying templates from $TEMPLATE_PATH"
        cp -r "$TEMPLATE_PATH"/* . 2>/dev/null || echo "No files to copy from templates"
        
        # Rename gitignore to .gitignore if it exists
        if [ -f "gitignore" ]; then
            mv "gitignore" ".gitignore"
            echo "Renamed gitignore to .gitignore"
        fi
        # Replace PROJECT_ID and PROJECT_ID_UPPER placeholders in all files
        PROJECT_ID_UPPER=$(printf '%s' "$PROJECT_ID" | tr '[:lower:]' '[:upper:]')
        find . -type f -not -path "./.git/*" -exec sed -i "s/\${PROJECT_ID}/$PROJECT_ID/g" {} + 2>/dev/null || true
        find . -type f -not -path "./.git/*" -exec sed -i "s/{{PROJECT_ID}}/$PROJECT_ID/g" {} + 2>/dev/null || true
        find . -type f -not -path "./.git/*" -exec sed -i "s/\${PROJECT_ID_UPPER}/$PROJECT_ID_UPPER/g" {} + 2>/dev/null || true
        find . -type f -not -path "./.git/*" -exec sed -i "s/{{PROJECT_ID_UPPER}}/$PROJECT_ID_UPPER/g" {} + 2>/dev/null || true
        
        git add -A
        if git diff --staged --quiet; then
            echo "No template files to commit"
        else
            git commit -m "Add project templates for $TEMPLATE_TYPE"
        fi
    else
        echo "Warning: Template directory not found: $TEMPLATE_PATH"
    fi
    
    git push origin feature/initial
    
    # Cleanup
    cd ../..
    rm -rf "$TEMP_DIR"
    
    echo "✅ Repository $REPO_NAME created successfully"
    echo ""
}

# Create the three repositories with appropriate templates
create_repo_with_templates "iaac" "terraform"

# Choose Java template based on project type
if [ "$PROJECT_TYPE" = "functions" ]; then
    create_repo_with_templates "java-backend" "java-functions"
else
    create_repo_with_templates "java-backend" "java-container"
fi

create_repo_with_templates "angular-front" "angular"

# Cleanup credentials
rm ~/.git-credentials

echo "=========================================="
echo "✅ All repositories created successfully!"
echo "=========================================="
echo "Repositories:"
echo "  - fsapps-${PROJECT_ID}-iaac"
echo "  - fsapps-${PROJECT_ID}-java-backend"
echo "  - fsapps-${PROJECT_ID}-angular-front"
