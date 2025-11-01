#!/usr/bin/env fish

function validate_ruby_env
    echo "🔍 Validating Ruby/Rails/PostgreSQL environment..."
    echo "Ruby version: "(ruby --version)
    echo "Ruby location: "(which ruby)
    echo "Bundler version: "(bundle --version)
    echo "Rails version: "(rails --version)
    echo "PostgreSQL version: "(psql --version)
    echo "PostgreSQL status: "(brew services list | grep postgresql)
    echo "Gem environment:"
    gem env | grep -E "(RUBY VERSION|INSTALLATION DIRECTORY|EXECUTABLE DIRECTORY)"
end

# Execute validation
validate_ruby_env
