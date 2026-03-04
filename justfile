# harrisontotty.github.io

set dotenv-load := false

# Default: list available recipes
default:
    @just --list

# Install Ruby dependencies
setup:
    bundle config set --local path vendor/bundle
    bundle install

# Serve the site locally with live reload
serve: setup
    bundle exec jekyll serve --livereload --drafts

# Build the site
build: setup
    bundle exec jekyll build

# Clean generated files
clean:
    rm -rf _site .jekyll-cache .jekyll-metadata .sass-cache

# Create a new post (usage: just new-post "My Post Title")
new-post title:
    #!/usr/bin/env bash
    set -euo pipefail
    slug=$(echo "{{ title }}" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')
    date=$(date +%Y-%m-%d)
    file="_posts/${date}-${slug}.md"
    if [ -f "$file" ]; then
        echo "Error: $file already exists"
        exit 1
    fi
    cat > "$file" << EOF
    ---
    layout: post
    title: "{{ title }}"
    ---
    EOF
    # Remove leading whitespace from heredoc
    sed -i 's/^    //' "$file"
    echo "Created $file"

# Validate HTML output
check: build
    bundle exec htmlproofer ./_site \
        --disable-external \
        --ignore-urls "/^#/" \
        --no-enforce-https

# List all posts
posts:
    @ls -1 _posts/ | sed 's/\.md$//' | sed 's/^[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}-/  /' | sort -r
