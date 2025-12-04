#!/bin/bash

set -e  # Exit on any error

# Environment injection script for Angular SWA deployment
echo "Starting environment injection process..."

# Get project name from environment variable
PROJECT_NAME="${PROJECT_NAME:-}"
echo "Using project name: $PROJECT_NAME"

# Define paths
DIST_PATH="dist/$PROJECT_NAME/browser"
ENV_JS_PATH="$DIST_PATH/assets/env.js"
INDEX_HTML_PATH="$DIST_PATH/index.html"
CONFIG_PATH="staticwebapp.config.json"

echo "=== Deployment Validation ==="
echo "Project: $PROJECT_NAME"
echo "Dist path: $DIST_PATH"
echo "Env.js path: $ENV_JS_PATH"

# Validate build output structure
if [ ! -d "$DIST_PATH" ]; then
    echo "ERROR: Build output directory not found at: $DIST_PATH"
    echo "Available directories in dist:"
    ls -la dist/ 2>/dev/null || echo "No dist directory found"
    exit 1
fi

# Validate index.html exists
if [ ! -f "$INDEX_HTML_PATH" ]; then
    echo "ERROR: index.html not found at: $INDEX_HTML_PATH"
    echo "Available files in build output:"
    ls -la "$DIST_PATH/" 2>/dev/null
    exit 1
fi

# Validate staticwebapp.config.json is in the right place
echo "Checking staticwebapp.config.json placement..."
if [ -f "$CONFIG_PATH" ]; then
    echo "✓ Found staticwebapp.config.json in root"
    # Copy config to build output for deployment
    cp "$CONFIG_PATH" "$DIST_PATH/"
    echo "✓ Copied config to build output"
else
    echo "ERROR: staticwebapp.config.json not found in project root"
    exit 1
fi

# Check if env.js exists
if [ ! -f "$ENV_JS_PATH" ]; then
    echo "WARNING: env.js not found at: $ENV_JS_PATH"
    echo "Available files in assets directory:"
    find "$DIST_PATH" -name "*.js" 2>/dev/null || echo "No JS files found"
    echo "Continuing without env.js injection..."
    exit 0
fi

echo "Found env.js at: $ENV_JS_PATH"

# Get environment variables with defaults
SUPABASE_URL="${SUPABASE_URL:-}"
SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:-}"
API_URL="${API_URL:-}"

echo "Injecting environment variables..."

# Replace placeholders using sed
sed -i "s|#SUPABASE_URL#|$SUPABASE_URL|g" "$ENV_JS_PATH"
sed -i "s|#SUPABASE_ANON_KEY#|$SUPABASE_ANON_KEY|g" "$ENV_JS_PATH"
sed -i "s|#API_URL#|$API_URL|g" "$ENV_JS_PATH"

# Verify replacements were successful
if grep -q "#SUPABASE_URL#\|#SUPABASE_ANON_KEY#\|#API_URL#" "$ENV_JS_PATH"; then
    echo "ERROR: Token replacement failed - placeholders still remain in $ENV_JS_PATH"
    echo "File content:"
    cat "$ENV_JS_PATH"
    exit 1
fi

echo "✓ Successfully injected environment variables"
echo "✓ Deployment validation completed successfully!"

# Display final structure
echo "=== Final Build Structure ==="
find "$DIST_PATH" -type f -name "*.html" -o -name "*.js" -o -name "staticwebapp.config.json" | head -10