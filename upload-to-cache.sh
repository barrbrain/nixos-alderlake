#!/bin/sh

. /etc/profile.d/nix.sh

set -eu
set -f # disable globbing
export IFS=' '

echo "Signing paths" $OUT_PATHS
nix store sign -k /etc/nix/key.private $OUT_PATHS

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY

echo "Uploading paths" $OUT_PATHS
exec nix copy --to "s3://nix.ba.rr-dav.id.au?region=ap-northeast-1&compression=zstd&compression-level=16&parallel-compression=true" $OUT_PATHS
