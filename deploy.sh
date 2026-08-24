#!/bin/bash
# InkLoft 每日自动部署
# 内容在 git 仓库(源)管理;vercel 部署走"无 .git 的暂存副本"——
# 实测:clone 目录带 origin 时 vercel CLI 会走挂掉的 Git 集成路径(coolthor 2026-08-25)。
cd "$(dirname "$0")" || exit 1

# 1) 重建内容
node build.mjs

# 2) 源仓库 commit+push(有变更才推)
chg=0
if git status --porcelain | grep -q .; then
  git add -A
  git -c user.email="ai@inkloft.local" -c user.name="InkLoft" commit -q -m "auto: 内容更新 $(date +%Y-%m-%d)"
  git push -q origin main && chg=1
  echo "[deploy] pushed"
fi

# 3) 只在有变更(或 --force)时才部署
if [ "$1" = "--force" ] || [ "$chg" = "1" ]; then
  STAGE=/tmp/inkloft-deploy
  rm -rf "$STAGE"; mkdir -p "$STAGE"
  cp index.html data.json vercel.json build.mjs "$STAGE/"
  cp -r media portraits "$STAGE/" 2>/dev/null
  cp -r .vercel "$STAGE/" 2>/dev/null
  ( cd "$STAGE" && vercel --prod --yes >/tmp/inkloft-deploy.log 2>&1 )
  rc=$?
  [ $rc -eq 0 ] && echo "[deploy] vercel ok" || { echo "[deploy] vercel FAIL rc=$rc"; tail -4 /tmp/inkloft-deploy.log; }
fi
echo "[deploy] done $(date '+%Y-%m-%d %H:%M')"
