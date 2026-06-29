#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

# [MISE] description="Check syntax for frontend resources."
# [USAGE] arg "[files]" {
# [USAGE]   help "Target files."
# [USAGE]   var #true
# [USAGE]   default "."
# [USAGE] }
# [USAGE] flag "-f --format <format>" {
# [USAGE]   help "Output format for check result."
# [USAGE]   choices "default" "rdjson"
# [USAGE]   default "default"
# [USAGE] }
# [USAGE] flag "-o --output <output>" {
# [USAGE]   help "Output path for check result."
# [USAGE] }

biome_args=("--reporter=${usage_format:?}")
if [ -n "${usage_output:-}" ]; then
  biome_args+=("--reporter-file=${usage_output:?}")
fi

eval "files=(${usage_files:-})"

npm exec @biomejs/biome -- \
  ci \
  "${biome_args[@]:?}" \
  "${files[@]:?}"
