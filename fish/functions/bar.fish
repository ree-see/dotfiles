function bar --description 'Manage SketchyBar - reload, kill, start, or revert to Apple menu bar'
    set -l command $argv[1]
    
    switch $command
        case reload restart r
            echo "🔄 Reloading SketchyBar..."
            /Users/reesee/.config/sketchybar/reload.sh
            
        case kill stop k
            echo "⏹️  Stopping SketchyBar..."
            killall sketchybar 2>/dev/null || true
            echo "✅ SketchyBar stopped"
            
        case start s
            echo "🚀 Starting SketchyBar..."
            /Users/reesee/.config/sketchybar/start_two_pill.sh
            
        case apple revert a
            echo "🍎 Reverting to Apple menu bar..."
            # Stop SketchyBar
            killall sketchybar 2>/dev/null || true
            # Show Apple menu bar
            defaults write NSGlobalDomain _HIHideMenuBar -bool false
            # Restart SystemUIServer to apply changes
            killall SystemUIServer 2>/dev/null || true
            echo "✅ Reverted to Apple menu bar"
            
        case status st
            if pgrep -x sketchybar >/dev/null
                echo "✅ SketchyBar is running"
                set -l apple_hidden (defaults read NSGlobalDomain _HIHideMenuBar 2>/dev/null || echo "0")
                if test "$apple_hidden" = "1"
                    echo "🍎 Apple menu bar is hidden"
                else
                    echo "🍎 Apple menu bar is visible"
                end
            else
                echo "❌ SketchyBar is not running"
                set -l apple_hidden (defaults read NSGlobalDomain _HIHideMenuBar 2>/dev/null || echo "0")
                if test "$apple_hidden" = "1"
                    echo "🍎 Apple menu bar is hidden (no menu bar active!)"
                else
                    echo "🍎 Apple menu bar is visible"
                end
            end
            
        case help h ''
            echo "🎛️  SketchyBar Management Tool"
            echo ""
            echo "Usage: bar <command>"
            echo ""
            echo "Commands:"
            echo "  reload, restart, r    Reload SketchyBar with current config"
            echo "  start, s              Start SketchyBar"
            echo "  kill, stop, k         Stop SketchyBar"
            echo "  apple, revert, a      Revert to Apple menu bar"
            echo "  status, st            Show current status"
            echo "  help, h               Show this help message"
            echo ""
            echo "Examples:"
            echo "  bar reload            # Reload SketchyBar"
            echo "  bar kill              # Stop SketchyBar"
            echo "  bar apple             # Switch back to Apple menu bar"
            echo "  bar status            # Check what's running"
            
        case '*'
            echo "❌ Unknown command: $command"
            echo "💡 Run 'bar help' for available commands"
            return 1
    end
end