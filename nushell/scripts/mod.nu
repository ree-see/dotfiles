# Custom scripts module - sources all .nu files in scripts directory

# Export all custom commands directly
export-env {
    source-env prompt.nu
}

export use cfg.nu cfg
export use mkcd.nu mkcd
export use rebuild.nu rebuild
export use rollback.nu rollback
export use nixstatus.nu nixstatus