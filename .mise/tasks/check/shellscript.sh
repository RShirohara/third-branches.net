#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

# [MISE] description="Check syntax for shellscript."
# [USAGE] arg "[files]" {
# [USAGE]   help "Target files."
# [USAGE] }
# [USAGE] flag "-f --format <format>" {
# [USAGE]   help "Output format for check result."
# [USAGE]   choices "checkstyle" "tty"
# [USAGE]   default "tty"
# [USAGE] }

eval "files=(${usage_files:-})"
if [ "${#files[*]}" -eq "0" ]; then
  while IFS='' read -r line; do
    files+=("${line}")
  done < <(
    find "${MISE_MONOREPO_ROOT}" \
      -type f \
      -name "*.sh"
  )
fi

shellcheck \
  --format="${usage_format?}" \
  "${files[@]}"
