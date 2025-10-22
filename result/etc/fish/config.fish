# /etc/fish/config.fish: DO NOT EDIT -- this file has been generated automatically.

# if we haven't sourced the general config, do it
if not set -q __fish_nix_darwin_general_config_sourced
  set fish_function_path /nix/store/hrfj9nhrbijzxs41hjja9a18vjvlv5xm-fishplugin-foreign-env-0-unstable-2020-02-09/share/fish/vendor_functions.d $fish_function_path
fenv source /etc/fish/foreign-env/shellInit > /dev/null
set -e fish_function_path[1]


  

  # and leave a note so we don't source this config section again from
  # this very shell (children will source the general config anew)
  set -g __fish_nix_darwin_general_config_sourced 1
end

# if we haven't sourced the login config, do it
status --is-login; and not set -q __fish_nix_darwin_login_config_sourced
and begin
  set fish_function_path /nix/store/hrfj9nhrbijzxs41hjja9a18vjvlv5xm-fishplugin-foreign-env-0-unstable-2020-02-09/share/fish/vendor_functions.d $fish_function_path
fenv source /etc/fish/foreign-env/loginShellInit > /dev/null
set -e fish_function_path[1]


  

  # and leave a note so we don't source this config section again from
  # this very shell (children will source the general config anew)
  set -g __fish_nix_darwin_login_config_sourced 1
end

# if we haven't sourced the interactive config, do it
status --is-interactive; and not set -q __fish_nix_darwin_interactive_config_sourced
and begin
  
  

  set fish_function_path /nix/store/hrfj9nhrbijzxs41hjja9a18vjvlv5xm-fishplugin-foreign-env-0-unstable-2020-02-09/share/fish/vendor_functions.d $fish_function_path
fenv source /etc/fish/foreign-env/interactiveShellInit > /dev/null
set -e fish_function_path[1]


  
  

  # and leave a note so we don't source this config section again from
  # this very shell (children will source the general config anew,
  # allowing configuration changes in, e.g, aliases, to propagate)
  set -g __fish_nix_darwin_interactive_config_sourced 1
end
