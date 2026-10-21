# Hook: post-merge-asset-validation

## Trigger

Runs after any merge to `main` (the trunk) or a `release/*` branch that
includes changes to `assets/`.

## Purpose

Validates that all assets in the merged branch conform to naming conventions,
size budgets, and format requirements. Prevents non-compliant assets from
accumulating on the trunk.

## Implementation

```bash
#!/bin/bash
# Post-merge hook: Asset validation
# Checks merged assets against project standards

MERGED_ASSETS=$(git diff --name-only HEAD@{1} HEAD | grep -E '^assets/')

if [ -z "$MERGED_ASSETS" ]; then
    exit 0
fi

EXIT_CODE=0
WARNINGS=""

for file in $MERGED_ASSETS; do
    filename=$(basename "$file")

    # Check naming convention (lowercase with underscores)
    if echo "$filename" | grep -qE '[A-Z[:space:]-]'; then
        WARNINGS="$WARNINGS\nNAMING: $file -- must be lowercase with underscores"
        EXIT_CODE=1
    fi

    # Check max image dimensions (max 2560x1440 for web assets)
    if [[ "$file" == *.png || "$file" == *.jpg || "$file" == *.webp ]]; then
        # Requires ImageMagick
        if command -v identify &> /dev/null; then
            dims=$(identify -format "%w %h" "$file" 2>/dev/null)
            if [ -n "$dims" ]; then
                w=$(echo "$dims" | cut -d' ' -f1)
                h=$(echo "$dims" | cut -d' ' -f2)
                if (( w > 2560 || h > 1440 )); then
                    WARNINGS="$WARNINGS\nDIMENSIONS: $file -- ${w}x${h} exceeds max web budget (2560x1440)"
                fi
            fi
        fi
    fi

    # Check file size budgets
    size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
    if [ -n "$size" ]; then
        # Images: max 500KB
        if [[ "$file" == public/illustrations/* ]] && [ "$size" -gt 512000 ]; then
            WARNINGS="$WARNINGS\nBUDGET: $file -- ${size} bytes exceeds 500KB image budget"
            EXIT_CODE=1
        fi
        # Icons & Brand: max 100KB
        if [[ "$file" == public/brand/* ]] && [ "$size" -gt 102400 ]; then
            WARNINGS="$WARNINGS\nBUDGET: $file -- ${size} bytes exceeds 100KB icon budget"
        fi
    fi
done

if [ -n "$WARNINGS" ]; then
    echo "=== Asset Validation Report ==="
    echo -e "$WARNINGS"
    echo "================================"
    echo "Run /saas-asset-audit for a full report."
fi

exit $EXIT_CODE
```

## Agent Integration

When this hook reports issues:
1. For naming violations: fix manually or invoke `design-system-director` for guidance
2. For size violations: invoke `ui-motion-designer` for optimization advice
3. For a full audit: run `/saas-asset-audit` skill
