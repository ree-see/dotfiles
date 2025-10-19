function setup-precommit --description "Set up pre-commit hooks for TDD workflow in current project"
    # Check if we're in a git repository
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "❌ Not in a git repository"
        return 1
    end

    # Copy template if .pre-commit-config.yaml doesn't exist
    if test -f .pre-commit-config.yaml
        echo "⚠️  .pre-commit-config.yaml already exists"
        read -P "Overwrite? (y/N) " -l confirm
        if test "$confirm" != "y"
            echo "Cancelled"
            return 0
        end
    end

    # Copy template
    cp ~/.config/templates/.pre-commit-config.yaml .pre-commit-config.yaml
    echo "✅ Created .pre-commit-config.yaml"

    # Install hooks
    pre-commit install
    echo "✅ Installed pre-commit hooks"

    # Ask if user wants to run checks now
    read -P "Run pre-commit on all files now? (Y/n) " -l run_now
    if test "$run_now" != "n"
        pre-commit run --all-files
    end

    echo ""
    echo "📝 Next steps:"
    echo "   1. Edit .pre-commit-config.yaml to enable/disable hooks"
    echo "   2. Uncomment test runner hook for TDD workflow"
    echo "   3. Run 'pre-commit run --all-files' to test"
end