function moxee-run --description "Build and run Moxee app on physical device"
    # Default device name
    set device_name "reesee"
    if test (count $argv) -gt 0
        set device_name $argv[1]
    end

    echo "🔍 Finding device '$device_name'..."
    set device_id (xcrun xctrace list devices 2>&1 | grep -i "$device_name" | grep -oE '\([0-9A-F-]{36}\)' | tr -d '()')

    if test -z "$device_id"
        echo "❌ Device '$device_name' not found"
        return 1
    end

    echo "✅ Found device: $device_id"

    # Navigate to project directory
    cd /Users/reesee/dev/moxee/ios

    echo "🔨 Building app..."
    xcodebuild -project Moxee.xcodeproj -scheme Moxee -configuration Debug -destination "id=$device_id" clean build 2>&1 | grep -E "(BUILD|error:)" | tail -5

    if test $status -ne 0
        echo "❌ Build failed"
        return 1
    end

    echo "📦 Finding app bundle..."
    set app_path (find ~/Library/Developer/Xcode/DerivedData -name "Moxee.app" -type d -mmin -5 | grep -v Index.noindex | head -1)

    if test -z "$app_path"
        echo "❌ Could not find built app"
        return 1
    end

    echo "📲 Installing app to device..."
    xcrun devicectl device install app --device $device_id "$app_path" 2>&1 | tail -5

    if test $status -ne 0
        echo "❌ Installation failed"
        return 1
    end

    echo "🚀 Launching app..."
    xcrun devicectl device process launch --device $device_id com.moxee.app 2>&1 | tail -3

    if test $status -eq 0
        echo "✅ App launched successfully on '$device_name'!"
    else
        echo "❌ Launch failed"
        return 1
    end
end
