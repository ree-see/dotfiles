# Helper function for rebuild: Show configuration differences
function _rebuild_show_diff
    echo "📊 Configuration changes:"
    if command -v nix-diff >/dev/null
        echo "Running nix-diff..."
        nix-diff (readlink /nix/var/nix/profiles/system) (nix-build '<darwin>' -A system --no-out-link)
    else
        echo "Install nix-diff for detailed comparison: nix-env -iA nixpkgs.nix-diff"
    end
end