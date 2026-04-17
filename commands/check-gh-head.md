---
description: 現在のブランチに develop / main の HEAD がマージされているかを判定する
allowed-tools: ["Bash"]
argument-hint: "[--fetch]"
---

引数: $ARGUMENTS

以下のコマンドで判定結果を取得する（`--fetch` が渡されたら remote の最新も取り込む）。

!`bash "${CLAUDE_PLUGIN_ROOT}/scripts/check-merge-status.sh" $ARGUMENTS`

上の結果を読み取り、以下を日本語で簡潔に報告する:
- 現在のブランチ名
- develop / main それぞれについて「マージ済み」か「未マージ（何コミット遅れ）」か
- いずれかが未マージなら、`git merge origin/<target>` あるいは `git rebase origin/<target>` のどちらを選ぶべきかを、作業状況に基づいて一文で提案する
