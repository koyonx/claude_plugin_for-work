# check-gh-head

現在の作業ブランチに `develop` / `main` の最新 HEAD がマージされているかを判定する Claude Code プラグイン。セッション開始時に未マージなら自動で警告し、`/check-gh-head` でいつでも明示的に確認できる。

このリポジトリ自体が単一プラグインを配布する Claude Code マーケットプレイスでもあります。

## インストール

Claude Code で次を実行:

```
/plugin marketplace add koyonx/claude_plugin_for-work
/plugin install check-gh-head@koyon-work
/reload-plugins
```

## 機能

### `/check-gh-head` スラッシュコマンド

現在のブランチに対する `develop` / `main` のマージ状態をその場で報告する。未マージがあれば `merge` / `rebase` のいずれが適切か一文で提案する。

```
/check-gh-head            ローカル ref のみを使って判定
/check-gh-head --fetch    事前に `git fetch origin develop main` を実行してから判定
```

### SessionStart フック

Claude Code 起動時 (`startup` matcher) に `--quiet` モードで自動判定する。

- すべてマージ済み → 無音
- いずれかが未マージ → セッション先頭に警告行を出力

```
=== branch merge status (current: feature-xyz) ===
  [NOT MERGED] develop (develop) は feature-xyz に未マージ — feature-xyz は 3 コミット遅れ
  [MERGED]     main (main) は feature-xyz にマージ済み
```

## 判定ロジック

`git merge-base --is-ancestor <target> HEAD` で `<target>` が現 HEAD の祖先かを判定する。祖先であれば現ブランチに取り込まれている。

対象 ref の解決順:

1. ローカル `refs/heads/<name>`
2. 無ければ `refs/remotes/origin/<name>`

現ブランチ自身が `develop` / `main` の場合、その対象はスキップする。detached HEAD や非 git ディレクトリでは何もしない。

## リポジトリ構成

```
.claude-plugin/
  plugin.json          プラグインマニフェスト
  marketplace.json     このリポジトリをマーケットプレイス化
commands/
  check-gh-head.md     /check-gh-head スラッシュコマンド
hooks/
  hooks.json           SessionStart フック定義
scripts/
  check-merge-status.sh  判定ロジック本体
```

## アンインストール

```
/plugin uninstall check-gh-head@koyon-work
/plugin marketplace remove koyon-work
```
