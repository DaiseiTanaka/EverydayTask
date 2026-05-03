---
name: xcode
description: XcodeBuildMCP を使った iOS ビルド・テスト・実行・デバッグ。xcodebuild の代わりにこのスキルを使う。
argument-hint: "<build|test|run|screenshot|debug など操作内容>"
user-invocable: true
---

# Xcode 操作（XcodeBuildMCP）

対象: `$ARGUMENTS`

## 基本方針

- **`xcodebuild` / `xcrun` / `simctl` コマンドを直接使わない** — 必ず XcodeBuildMCP の MCP ツールを使用する
- セッション開始時にまず `session_show_defaults` でコンテキストを確認する
- デフォルトが未設定・不正の場合のみ `discover_projs` でプロジェクトを検索する

## 手順

### Step 1: セッションコンテキスト確認

1. `session_show_defaults` を呼び出す
2. project/scheme/simulator/device が正しいか確認する
3. 不足があれば `session_set_defaults` で設定する
   - workspace / scheme は CLAUDE.md のビルド設定を参照
   - simulator: デフォルトは `iPhone 16`

### Step 2: 操作の実行

引数 `$ARGUMENTS` に応じて適切なツールを選択する:

| 操作 | ツール | 備考 |
|------|--------|------|
| ビルド | simulator build ツール | scheme を指定 |
| ビルド+実行 | simulator build-and-run ツール | ビルド→実行を1ステップで |
| テスト | simulator test ツール | scheme を指定 |
| インストール | simulator install ツール | .app をインストール |
| スクリーンショット | UI automation screenshot ツール | 画面キャプチャ |
| UI 操作 | UI automation tap/swipe ツール | タップ座標指定 |
| ログ | log capture ツール | シミュレータ/実機ログ |
| デバッグ | LLDB ツール | ブレークポイント、変数検査 |

### Step 3: 結果の報告

- ビルド成功/失敗を明確に報告する
- エラーがあれば該当ファイルと行番号を提示する
- テスト結果はパス/フェイル数を含める

## ワークフロー別ガイド

### ビルド確認（最も頻繁）

```
1. session_show_defaults で確認
2. simulator build（scheme を指定）
3. エラーがあれば修正して再ビルド
```

### シミュレータで実行

```
1. session_show_defaults で確認
2. simulator build-and-run（ビルド+実行を1ステップで）
   ※ build → run と分けない（二重ビルドになるため）
```

### テスト実行

```
1. session_show_defaults で確認
2. simulator test（scheme を指定）
3. 失敗テストがあれば原因を分析
```

### 実機デプロイ

```
1. session_show_defaults で確認
2. device ワークフローが有効か確認
   （無効なら .xcodebuildmcp/config.yaml を更新してリロードを依頼）
3. device build + install + launch
```

### UI 自動化・スクリーンショット

```
1. アプリが実行中であることを確認
2. screenshot で画面キャプチャ
3. view hierarchy で要素座標を確認
4. tap/swipe で操作
```

## 注意事項

- シミュレータ系ツールのみデフォルト有効。実機・macOS・デバッグ・UI 自動化は `.xcodebuildmcp/config.yaml` で有効化が必要
- `discover_projs` はセッション開始時の1回のみ。投機的に呼ばない
- build-and-run を使う場合、事前の build-only は不要（二重ビルド回避）
- エラー時は失敗したステップと次のアクションを明示する
