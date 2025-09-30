#!/usr/bin/env fish

# Ruby/Rails/PostgreSQL Development Environment Setup Script
# This script sets up Ruby development tools that can't be managed by Nix
# Part of the dotfiles configuration for reproducible development environments

function print_status
    echo (set_color blue)"[INFO]"(set_color normal) $argv
end

function print_success
    echo (set_color green)"[SUCCESS]"(set_color normal) $argv
end

function print_warning
    echo (set_color yellow)"[WARNING]"(set_color normal) $argv
end

function print_error
    echo (set_color red)"[ERROR]"(set_color normal) $argv
end

echo "🔥 Setting up Ruby/Rails/PostgreSQL development environment..."

# Install rbenv via Homebrew
print_status "Installing rbenv..."
if command -v rbenv >/dev/null
    print_warning "rbenv already installed"
else
    brew install rbenv
    print_success "rbenv installed"
end

# Install PostgreSQL via Homebrew
print_status "Installing PostgreSQL..."
if command -v psql >/dev/null
    print_warning "PostgreSQL already installed"
else
    brew install postgresql
    print_success "PostgreSQL installed"
end

print_status "Dependencies installed"

# Initialize rbenv for this session
set -gx PATH $HOME/.rbenv/bin $PATH
status --is-interactive; and rbenv init - fish | source

print_status "rbenv initialized"

# Install latest stable Ruby version if not already installed
set RUBY_VERSION "3.3.0"
print_status "Installing Ruby $RUBY_VERSION..."

if rbenv versions | grep -q $RUBY_VERSION
    print_warning "Ruby $RUBY_VERSION already installed"
else
    rbenv install $RUBY_VERSION
    print_success "Ruby $RUBY_VERSION installed"
end

# Set global Ruby version
print_status "Setting global Ruby version to $RUBY_VERSION..."
rbenv global $RUBY_VERSION
rbenv rehash

# Verify Ruby installation
set CURRENT_RUBY (rbenv version | awk '{print $1}')
print_status "Current Ruby version: $CURRENT_RUBY"

# Update RubyGems
print_status "Updating RubyGems..."
gem update --system --no-document

# Install bundler
print_status "Installing/updating Bundler..."
gem install bundler --no-document

# Install Rails (latest stable)
print_status "Installing Rails..."
gem install rails --no-document

# Install PostgreSQL adapter gem
print_status "Installing PostgreSQL adapter (pg gem)..."
gem install pg --no-document

# Install common Ruby development gems
print_status "Installing common development gems..."
gem install --no-document \
    solargraph \
    rubocop \
    brakeman \
    pry \
    pry-byebug

# Rehash to make new executables available
rbenv rehash

# PostgreSQL Setup
print_status "Starting PostgreSQL service..."
brew services start postgresql

# Verify installations
print_status "Verifying installations..."
echo "Ruby: "(ruby --version)
echo "Bundler: "(bundle --version)
echo "Rails: "(rails --version)
echo "PostgreSQL: "(psql --version)
echo "Gem location: "(which gem)
echo "Bundle location: "(which bundle)
echo "Rails location: "(which rails)
echo "PostgreSQL location: "(which psql)

print_success "Ruby/Rails/PostgreSQL development environment setup complete!"
print_status "Next steps:"
echo "  1. Restart your shell or run: source ~/.config/fish/config.fish"
echo "  2. Verify setup with: ruby --version && rails --version && psql --version"
echo "  3. In Rails projects, run: bundle install"
echo "  4. Create Rails apps with PostgreSQL: rails new myapp --database=postgresql"

# Create a simple validation script
echo '#!/usr/bin/env fish

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
end' > ~/.config/scripts/validate-ruby.fish

chmod +x ~/.config/scripts/validate-ruby.fish
print_success "Created validation script at ~/.config/scripts/validate-ruby.fish"
print_status "Run 'fish ~/.config/scripts/validate-ruby.fish' to validate your setup"