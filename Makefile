PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin
SCRIPT_NAME = claude-auto-resume

.PHONY: install uninstall test test-interrupt

install:
	@echo "Installing $(SCRIPT_NAME) to $(BINDIR)..."
	@mkdir -p $(BINDIR)
	@cp claude-auto-resume.sh $(BINDIR)/$(SCRIPT_NAME)
	@chmod +x $(BINDIR)/$(SCRIPT_NAME)
	@echo "Installation complete. You can now run '$(SCRIPT_NAME)' from anywhere."

uninstall:
	@echo "Uninstalling $(SCRIPT_NAME)..."
	@rm -f $(BINDIR)/$(SCRIPT_NAME)
	@echo "Uninstallation complete."

test:
	@echo "Testing script syntax..."
	@bash -n claude-auto-resume.sh
	@echo "Running Ctrl+C interrupt test..."
	@chmod +x test_interrupt_ctrl_c.sh
	@./test_interrupt_ctrl_c.sh
	@echo "All tests passed."

test-interrupt:
	@echo "Running Ctrl+C interrupt test..."
	@chmod +x test_interrupt_ctrl_c.sh
	@./test_interrupt_ctrl_c.sh

help:
	@echo "Available targets:"
	@echo "  install   - Install the script globally to $(BINDIR)"
	@echo "  uninstall - Remove the script from $(BINDIR)"
	@echo "  test      - Test script syntax"
	@echo "  help      - Show this help message"
	@echo ""
	@echo "Environment variables:"
	@echo "  PREFIX    - Installation prefix (default: /usr/local)"