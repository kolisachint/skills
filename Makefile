# Portable AI Skillkit — Makefile

SKILLKIT := ./skillkit.sh
FAVORITES := favorites.tsv
TARGET := .

.PHONY: help bootstrap-ai bootstrap-all list

help:
	@echo "Portable AI Skillkit"
	@echo ""
	@echo "Targets:"
	@echo "  make bootstrap-ai    Install daily-driver + critical favorites"
	@echo "  make bootstrap-all   Install all favorites (no tag filter)"
	@echo "  make list            List all available components"

bootstrap-ai:
	$(SKILLKIT) install --target $(TARGET) --from $(FAVORITES) --tag daily-driver,critical

bootstrap-all:
	$(SKILLKIT) install --target $(TARGET) --from $(FAVORITES)

list:
	$(SKILLKIT) list
