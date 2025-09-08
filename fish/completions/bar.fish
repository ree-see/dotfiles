# Tab completions for the bar command
complete -c bar -f
complete -c bar -a "reload restart r" -d "Reload SketchyBar"
complete -c bar -a "start s" -d "Start SketchyBar"
complete -c bar -a "kill stop k" -d "Stop SketchyBar"
complete -c bar -a "apple revert a" -d "Revert to Apple menu bar"
complete -c bar -a "status st" -d "Show current status"
complete -c bar -a "help h" -d "Show help message"