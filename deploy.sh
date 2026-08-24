#!/bin/bash
# InkLoft 每日自动部署: 有内容变更才 commit+push+vercel
cd "$(dirname "$0")" || exit 1
node build.mjs
chg=0
if git status --porcelain | grep -q .; then
  git add -A
  git -c user.email="ai@inkloft.local" -c user.name="InkLoft" commit -q -m "自动: 内容更新 $(date +%Y-%m-%d)"
  git push -q origin main && echo "[deploy] pushed"
  chg=1
fi
if [ "$1" = "--force" ] || [ "$chg" = "1" ]; then
  vercel --prod --yes >/dev/null 2>&1 && echo "[deploy] vercel deployed"
fi
echo "[deploy] done $(date)"
