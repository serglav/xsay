PREFIX ?= $(HOME)/.local

.PHONY: install uninstall

install:
	@echo "Installing xsay to $(PREFIX)..."
	@install -d $(PREFIX)/bin
	@install -d $(PREFIX)/share/xsay/soundfx
	@install -m 755 bin/xsay $(PREFIX)/bin/xsay
	@install -m 644 share/xsay/xsay.conf $(PREFIX)/share/xsay/xsay.conf
	@install -m 644 share/xsay/soundfx/*.aiff $(PREFIX)/share/xsay/soundfx/
	@mkdir -p "$${XDG_CONFIG_HOME:-$$HOME/.config}/xsay"
	@test -f "$${XDG_CONFIG_HOME:-$$HOME/.config}/xsay/xsay.conf" \
	  || cp share/xsay/xsay.conf "$${XDG_CONFIG_HOME:-$$HOME/.config}/xsay/xsay.conf"
	@echo ""
	@echo "Installed successfully!"
	@echo "  Run: xsay \"hello world\""
	@case ":$$PATH:" in \
	  *":$(PREFIX)/bin:"*) ;; \
	  *) echo ""; echo "  NOTE: Add $(PREFIX)/bin to your PATH:"; \
	     echo "    export PATH=\"$(PREFIX)/bin:\$$PATH\"" ;; \
	esac

uninstall:
	@echo "Removing xsay from $(PREFIX)..."
	@rm -f $(PREFIX)/bin/xsay
	@rm -rf $(PREFIX)/share/xsay
	@test -f /tmp/xsay-$${USER}.pid && kill $$(cat /tmp/xsay-$${USER}.pid) 2>/dev/null || true
	@rm -f /tmp/xsay-$${USER}.fifo /tmp/xsay-$${USER}.pid /tmp/xsay-$${USER}.last_repo
	@echo "Removed. User config preserved at ~/.config/xsay/"
