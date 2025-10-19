function newproject --description "Create a new project with Claude Code configuration"
    # Parse arguments
    set -l options (fish_opt -s t -l type --required-val)
    set -a options (fish_opt -s h -l help)
    set -a options (fish_opt -l tdd)
    argparse $options -- $argv

    # Show help
    if set -q _flag_help
        echo "Usage: newproject <project-name> [options]"
        echo ""
        echo "Options:"
        echo "  -t, --type TYPE     Project type: node, ruby, python, web (default: node)"
        echo "  --tdd               Set up pre-commit hooks for TDD workflow"
        echo "  -h, --help          Show this help message"
        echo ""
        echo "Examples:"
        echo "  newproject my-app --type node --tdd"
        echo "  newproject my-site --type web"
        echo "  newproject api-server --type ruby --tdd"
        return 0
    end

    # Validate project name
    if test (count $argv) -eq 0
        echo "❌ Error: Project name is required"
        echo "Usage: newproject <project-name> [--type TYPE] [--tdd]"
        return 1
    end

    set -l project_name $argv[1]
    set -l project_type $_flag_type
    if test -z "$project_type"
        set project_type "node"
    end

    # Validate project type
    set -l valid_types node ruby python web
    if not contains $project_type $valid_types
        echo "❌ Error: Invalid project type '$project_type'"
        echo "Valid types: node, ruby, python, web"
        return 1
    end

    # Create project directory
    set -l project_path ~/dev/$project_name
    if test -d $project_path
        echo "❌ Error: Directory already exists: $project_path"
        return 1
    end

    echo "🚀 Creating new $project_type project: $project_name"

    # Create directory and navigate to it
    mkdir -p $project_path
    cd $project_path

    # Initialize git
    git init
    echo "✅ Initialized git repository"

    # Create CLAUDE.md from template
    cp ~/.config/templates/CLAUDE.md.template CLAUDE.md
    sed -i '' "s/PROJECT_NAME/$project_name/g" CLAUDE.md
    echo "✅ Created CLAUDE.md"

    # Create .gitignore based on project type
    switch $project_type
        case node
            echo "node_modules/
dist/
build/
.env
.DS_Store
*.log
.pnpm-debug.log*" > .gitignore

            # Initialize package.json
            pnpm init
            echo "✅ Initialized pnpm project"

        case ruby
            echo "*.gem
*.rbc
.bundle
.config
coverage
InstalledFiles
lib/bundler/man
pkg
rdoc
spec/reports
test/tmp
test/version_tmp
tmp
.env
.DS_Store" > .gitignore

        case python
            echo "__pycache__/
*.py[cod]
*$py.class
.Python
venv/
ENV/
.env
.DS_Store
*.log
.pytest_cache/" > .gitignore

        case web
            echo "node_modules/
dist/
.cache/
.env
.DS_Store
*.log" > .gitignore
    end
    echo "✅ Created .gitignore"

    # Create README.md
    echo "# $project_name

[Project description]

## Setup

See CLAUDE.md for development environment details.

## Development

\`\`\`fish
# Install dependencies
pnpm install  # or appropriate command for $project_type

# Run development server
pnpm dev
\`\`\`

## Testing

\`\`\`fish
pnpm test
\`\`\`
" > README.md
    echo "✅ Created README.md"

    # Set up pre-commit hooks if --tdd flag is set
    if set -q _flag_tdd
        cp ~/.config/templates/.pre-commit-config.yaml .pre-commit-config.yaml
        pre-commit install
        echo "✅ Set up pre-commit hooks for TDD"
    end

    # Initial commit
    git add .
    git commit -m "chore: Initialize $project_type project

- Set up project structure
- Add CLAUDE.md with global config reference
- Initialize git repository" -m "🤖 Generated with newproject command"

    echo ""
    echo "🎉 Project created successfully!"
    echo ""
    echo "📍 Location: $project_path"
    echo "📝 Type: $project_type"
    if set -q _flag_tdd
        echo "✓ TDD: Pre-commit hooks enabled"
    end
    echo ""
    echo "Next steps:"
    echo "  1. Review CLAUDE.md"
    echo "  2. Update README.md with project details"
    if not set -q _flag_tdd
        echo "  3. Run 'setup-precommit' if you want TDD hooks"
    end
    echo ""
    echo "Happy coding! 🚀"
end