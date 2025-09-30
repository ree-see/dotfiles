# Helper function for rebuild: Handle git status and auto-commit
function _rebuild_handle_git --argument-names auto_commit commit_msg
    if not git rev-parse --git-dir >/dev/null 2>&1
        return 0
    end

    set -l git_status (git status --porcelain)
    if test -z "$git_status"
        echo "✅ Git tree is clean"
        return 0
    end

    echo "🔄 Git tree is dirty:"
    git status --short

    if test "$auto_commit" = true
        echo "📝 Auto-committing changes..."
        git add .
        git commit -m "$commit_msg"
        echo "✅ Changes committed"
    else
        echo "nix: update config before rebuild"
    end
end