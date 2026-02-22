# Only source Cargo environment if it exists (after nix-darwin rebuild)
if test -f "$HOME/.cargo/env.fish"
    source "$HOME/.cargo/env.fish"
end
