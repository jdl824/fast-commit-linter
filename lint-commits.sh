#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Input variables
PR_TITLE="${INPUT_PR_TITLE:-}"
COMMIT_MESSAGES="${INPUT_COMMIT_MESSAGES:-}"
ALLOWED_TYPES="${INPUT_ALLOWED_TYPES:-feat,fix,docs,style,refactor,perf,test,build,ci,chore,revert}"
CUSTOM_REGEX="${INPUT_CUSTOM_REGEX:-}"
IGNORE_BOTS="${INPUT_IGNORE_BOTS:-true}"
ACTOR="${INPUT_GITHUB_ACTOR:-}"

echo -e "${BLUE}=== Fast Conventional Commit Linter ===${NC}"

# 1. Handle Bot Ignore Logic
if [ "$IGNORE_BOTS" = "true" ]; then
	if [[ "$ACTOR" == *"dependabot"* ]] || [[ "$ACTOR" == *"renovate"* ]] || [[ "$ACTOR" == *"[bot]"* ]]; then
		echo -e "${GREEN}✓ Skipping validation for automated bot account: ${ACTOR}${NC}"
		exit 0
	fi
fi

# 2. Build the Regex Pattern
if [ -n "$CUSTOM_REGEX" ]; then
	REGEX="$CUSTOM_REGEX"
	echo -e "${BLUE}Using custom regex pattern: ${REGEX}${NC}"
else
	# Sanitize and convert comma-separated string to pipe-separated for regex: "feat,fix" -> "feat|fix"
	TYPES_REGEX=$(echo "$ALLOWED_TYPES" | tr -d ' ' | tr ',' '|')

	# Matches: type(scope)!: subject OR type!: subject OR type: subject
	REGEX="^(${TYPES_REGEX})(\([a-zA-Z0-9_-]+\))?(!)?: .+$"
	echo -e "${BLUE}Using conventional commit regex with types: [${ALLOWED_TYPES}]${NC}"
fi

FAILURES=0

# Validation helper function utilizing native bash regex matching (0 subshells = fast)
validate_string() {
	local label="$1"
	local text="$2"

	# Skip empty strings
	if [ -z "$text" ]; then
		return 0
	fi

	if [[ "$text" =~ $REGEX ]]; then
		echo -e "${GREEN}✓ Valid ${label}: \"${text}\"${NC}"
		return 0
	else
		echo -e "${RED}✖ Invalid ${label}: \"${text}\"${NC}"
		FAILURES=$((FAILURES + 1))
		return 1
	fi
}

# 3. Validate PR Title (if provided)
if [ -n "$PR_TITLE" ]; then
	validate_string "PR Title" "$PR_TITLE" || true
fi

# 4. Validate extra Commit Messages (if provided)
if [ -n "$COMMIT_MESSAGES" ]; then
	echo -e "\n${BLUE}Checking individual commit messages...${NC}"
	while IFS= read -r msg; do
		# Skip empty lines
		[ -z "$msg" ] && continue
		validate_string "Commit" "$msg" || true
	done <<<"$COMMIT_MESSAGES"
fi

# 5. Final Reporting
if [ "$FAILURES" -gt 0 ]; then
	echo -e "\n${RED}=== Validation Failed ===${NC}"
	echo -e "${YELLOW}Expected format: No special chars allowed in PR Title"

	if [ -z "$CUSTOM_REGEX" ]; then
		echo -e "${YELLOW}Allowed types:${NC} ${ALLOWED_TYPES}"
	fi
	exit 1
else
	echo -e "\n${GREEN}=== Validation Passed! ===${NC}"
	exit 0
fi
