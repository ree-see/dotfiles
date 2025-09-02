function nu --description "Start Nushell with proper configuration"
    command nu --config ~/.config/nushell/config.nu --env-config ~/.config/nushell/env.nu $argv
end