---
name: design-review
description: デザイン観点での UI レビュー。レイアウト・Dynamic Type・コンポーネント統一性を検証する。
argument-hint: "[対象画面やコンポーネント（省略時は直近の差分全体）]"
---

# デザインレビュー

対象: `$ARGUMENTS`（未指定時は `git diff` の差分に含まれる UI ファイル全体）

## 手順

Agent ツールで `designer` エージェント (`.claude/agents/designer.md`) を起動し、以下を実行させる:

### 1. UI ファイルの特定
- 変更された Screen/, Components/ 配下のファイルを特定
- 関連するプレゼンターの UIState も確認

### 2. レイアウト検証
- iPhone SE (375pt) での表示問題がないか
- 固定値への過度な依存がないか
- ScrollView / LazyVStack の適切な使用
- セーフエリアの考慮

### 3. Dynamic Type 検証
- セマンティックフォントスタイル（`.body`, `.caption` 等）の使用
- 大きいテキストサイズでのレイアウト耐性
- `lineLimit` / `minimumScaleFactor` の適切な設定

### 4. コンポーネント統一性
- ボタン・テキストフィールド・カードのスタイル統一
- タップ領域 44pt 以上の確保
- カラースキームの一貫性
- アイコンサイズの統一

### 5. インタラクション
- フィードバック（haptic, animation）の適切さ
- 空状態・ローディング状態・エラー状態の UI
