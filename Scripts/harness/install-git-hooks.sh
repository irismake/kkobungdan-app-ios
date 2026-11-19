#!/usr/bin/env bash
# 이 저장소의 git 훅을 .githooks/ 로 연결한다. (로컬 설정만 바꾼다. 해제: git config --unset core.hooksPath)
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
chmod +x .githooks/*
git config core.hooksPath .githooks
echo "✓ git 훅 연결: $(git config core.hooksPath) (pre-commit · commit-msg)"
