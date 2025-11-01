# This happens before $__fish_datadir/config.fish sets fish_function_path, so it is currently
# unset. We set it and then completely erase it, leaving its configuration to $__fish_datadir/config.fish
set fish_function_path /nix/store/hrfj9nhrbijzxs41hjja9a18vjvlv5xm-fishplugin-foreign-env-0-unstable-2020-02-09/share/fish/vendor_functions.d $__fish_datadir/functions

# source the NixOS environment config
if [ -z "$__NIX_DARWIN_SET_ENVIRONMENT_DONE" ]
  fenv source /nix/store/lahq0awicwgvz12ddjxbnw9ihmbbrc9n-set-environment
end

# clear fish_function_path so that it will be correctly set when we return to $__fish_datadir/config.fish
set -e fish_function_path
