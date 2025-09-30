#!/bin/bash

# Ruby/Rails/PostgreSQL Development Environment Setup Script
# This script sets up Ruby development tools that can't be managed by Nix
# Part of the dotfiles configuration for reproducible development environments

set -e

echo "🔥 Setting up Ruby/Rails/PostgreSQL development environment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if rbenv is installed (should be from Homebrew via Nix)
if ! command -v rbenv &> /dev/null; then
    print_error "rbenv not found. Make sure to run 'rebuild' first to install Homebrew packages."
    exit 1
fi

# Check if PostgreSQL is installed (should be from Homebrew via Nix)
if ! command -v psql &> /dev/null; then
    print_error "PostgreSQL not found. Make sure to run 'rebuild' first to install Homebrew packages."
    exit 1
fi

# Initialize rbenv for this session
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

print_status "rbenv found and initialized"

# Install latest stable Ruby version if not already installed
RUBY_VERSION="3.3.0"
print_status "Installing Ruby ${RUBY_VERSION}..."

if rbenv versions | grep -q "$RUBY_VERSION"; then
    print_warning "Ruby ${RUBY_VERSION} already installed"
else
    rbenv install "$RUBY_VERSION"
    print_success "Ruby ${RUBY_VERSION} installed"
fi

# Set global Ruby version
print_status "Setting global Ruby version to ${RUBY_VERSION}..."
rbenv global "$RUBY_VERSION"
rbenv rehash

# Verify Ruby installation
CURRENT_RUBY=$(rbenv version | awk '{print $1}')
print_status "Current Ruby version: ${CURRENT_RUBY}"

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
echo "Ruby: $(ruby --version)"
echo "Bundler: $(bundle --version)"
echo "Rails: $(rails --version)"
echo "PostgreSQL: $(psql --version)"
echo "Gem location: $(which gem)"
echo "Bundle location: $(which bundle)"
echo "Rails location: $(which rails)"
echo "PostgreSQL location: $(which psql)"

print_success "Ruby/Rails/PostgreSQL development environment setup complete!"
print_status "Next steps:"
echo "  1. Restart your shell or run: source ~/.config/fish/config.fish"
echo "  2. Verify setup with: ruby --version && rails --version && psql --version"
echo "  3. In Rails projects, run: bundle install"
echo "  4. Create Rails apps with PostgreSQL: rails new myapp --database=postgresql"

# Create a simple validation script
cat > ~/.config/scripts/validate-ruby.sh << 'EOF'
#!/bin/bash
echo "🔍 Validating Ruby/Rails/PostgreSQL environment..."
echo "Ruby version: $(ruby --version)"
echo "Ruby location: $(which ruby)"
echo "Bundler version: $(bundle --version)"
echo "Rails version: $(rails --version)"
echo "PostgreSQL version: $(psql --version)"
echo "PostgreSQL status: $(brew services list | grep postgresql)"
echo "Gem environment:"
gem env | grep -E "(RUBY VERSION|INSTALLATION DIRECTORY|EXECUTABLE DIRECTORY)"
EOF

chmod +x ~/.config/scripts/validate-ruby.sh
print_success "Created validation script at ~/.config/scripts/validate-ruby.sh"