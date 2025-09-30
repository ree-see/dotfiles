# Helper function for rebuild: Update flake inputs
function _rebuild_update_flake --argument-names config_dir
    echo "🔄 Updating flake inputs..."
    if nix flake update --flake $config_dir/nix
        echo "✅ Flake inputs updated"
        return 0
    else
        echo "❌ Failed to update flake inputs"
        return 1
    end
end