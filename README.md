# harrisontotty.github.io

Personal blog of [Harrison Totty](https://harrison.totty.dev), built with [Jekyll](https://jekyllrb.com/) and deployed via GitHub Pages.

## Local Development

**Prerequisites:** Ruby 3+, Bundler, [just](https://github.com/casey/just)

```bash
# Install dependencies and serve locally (with live reload)
just serve

# Build without serving
just build
```

The local site will be available at `http://localhost:4000`.

## Writing Posts

```bash
# Create a new post
just new-post "My Post Title"
```

Posts are Markdown files in `_posts/` with the naming convention `YYYY-MM-DD-slug.md`. Frontmatter:

```yaml
---
layout: post
title: "My Post Title"
---
```

The `post` layout includes MathJax support for LaTeX math (`$...$` inline, `$$...$$` display).

## Project Structure

```
_config.yml      # Jekyll configuration
_layouts/        # HTML templates (default, post, page)
_includes/       # Reusable components (MathJax config)
_posts/          # Blog posts (Markdown)
about/           # About page
images/          # Post images
index.html       # Homepage
```

## Deployment

Pushes to `master` automatically build and deploy via [GitHub Actions](.github/workflows/jekyll-gh-pages.yml).
