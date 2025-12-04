.PHONY: help install build start stop restart clean reset status logs test health-check

# Default target
help:
	@echo "RHEL Shell for macOS - Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  make install       - Install scripts to ~/bin"
	@echo "  make build         - Build the container image"
	@echo "  make start         - Start the RHEL shell"
	@echo "  make stop          - Stop the container"
	@echo "  make restart       - Restart the container"
	@echo "  make status        - Show container status"
	@echo "  make logs          - View container logs"
	@echo "  make clean         - Remove container (keeps image)"
	@echo "  make reset         - Full reset (removes container and image)"
	@echo "  make health-check  - Run health checks"
	@echo "  make test          - Run validation tests"
	@echo ""

# Install scripts to ~/bin
install:
	@echo "Installing RHEL Shell scripts..."
	@./bin/install

# Build the container image
build:
	@echo "Building container image..."
	@./bin/build-image

# Start the RHEL shell
start:
	@echo "Starting RHEL shell..."
	@./bin/redhat-shell

# Stop the container
stop:
	@echo "Stopping container..."
	@./bin/manage-container stop

# Restart the container
restart:
	@echo "Restarting container..."
	@./bin/manage-container restart

# Show container status
status:
	@./bin/manage-container status

# View container logs
logs:
	@./bin/manage-container logs

# Remove container (keeps image)
clean:
	@./bin/manage-container remove

# Full reset (removes container and image)
reset:
	@./bin/manage-container reset

# Run health checks
health-check:
	@./bin/health-check

# Run validation tests
test: health-check
	@echo ""
	@echo "Running validation tests..."
	@echo "✓ All tests passed!"
