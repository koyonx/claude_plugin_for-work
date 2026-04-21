# koyon-work marketplace

koyon 個人用の Claude Code マーケットプレイス。現在は 2 プラグインを配布しています。

- **`check-gh-head`** — 現在のブランチに `develop` / `main` の最新 HEAD がマージされているかを判定し、未マージなら警告する。
- **`study`** — カレントリポジトリの技術スタックを検出し、実践的な使い方や類似技術との比較を問題形式で学ばせる。

## インストール

Claude Code で次を実行:

```
/plugin marketplace add koyonx/claude_plugin_for-work
/plugin install check-gh-head@koyon-work
/plugin install study@koyon-work
/reload-plugins
```

## check-gh-head

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

## study

### `/study` スラッシュコマンド

カレントワークツリー内のマニフェスト (`package.json`, `pyproject.toml`, `Cargo.toml`, `Dockerfile`, `.github/workflows/*` など) を読み取って主要な技術スタックを検出し、その技術についてインタラクティブに出題する。

4 つのカテゴリを混ぜて 1 問ずつ出題する:

- **(A) 基礎** — 設計思想・主要 API・バージョン差異
- **(B) 実践 (repo-grounded)** — このリポジトリの実ファイルを引用し、「なぜこう書くのか / 落とし穴は」を問う
- **(C) 比較** — 類似技術 (例: Next.js ↔ Remix/Nuxt, Prisma ↔ Drizzle) とのトレードオフ
- **(D) 最新動向** — 直近の非推奨 API や推奨プラクティスの変化

```
/study                              検出 → 対象確認 → 出題
/study React --level=hard --count=8 特定トピックで高難度 8 問
/study --lang=en                    英語モード
```

採点後は解説と公式ドキュメントへのリンクが付き、セッション終了時にはカテゴリ別正答率と次に学ぶべき弱点トピックを提示する。

## リポジトリ構成

```
.claude-plugin/
  plugin.json          check-gh-head のマニフェスト
  marketplace.json     このリポジトリをマーケットプレイス化
commands/
  check-gh-head.md     /check-gh-head スラッシュコマンド
hooks/
  hooks.json           SessionStart フック定義
scripts/
  check-merge-status.sh  判定ロジック本体
study/
  .claude-plugin/
    plugin.json        study のマニフェスト
  commands/
    study.md           /study スラッシュコマンド
```

## アンインストール

```
/plugin uninstall check-gh-head@koyon-work
/plugin uninstall study@koyon-work
/plugin marketplace remove koyon-work
```
