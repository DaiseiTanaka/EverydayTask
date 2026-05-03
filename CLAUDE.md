# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

EverydayTask は App Store 公開済みの iOS 繰り返しタスク管理アプリ。日次・週次・月次・年次の繰り返しタスクを管理し、カレンダー上で完了状況を可視化する。ウィジェット対応。主要言語は日本語（英語フォールバック）。

## Build & Run

```bash
# メインアプリのビルド
xcodebuild -scheme EverydayTask -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' build

# ウィジェットのビルド
xcodebuild -scheme EverydayTaskWidgetExtension -sdk iphonesimulator build
```

- 純粋な Xcode プロジェクト（SPM・CocoaPods 等の外部依存なし）
- テストターゲットは存在しない

## Architecture

**MVVM パターン（単一 ViewModel）:**

```
EverydayTaskApp.swift (@main)
  ↓
ContentView (ルート — サイドバー + カレンダー + ハーフモーダル)
  ├── TaskViewModel (@StateObject — 全ビジネスロジック)
  ├── RKManager (@StateObject — カレンダー状態)
  ├── TaskView (ハーフモーダル — 日次タスクリスト)
  ├── CalendarView (カスタムカレンダー — RK* コンポーネント)
  ├── AllTaskListView (全タスク一覧 — 検索・ソート)
  ├── SideMenuView (サイドバーナビゲーション)
  └── TaskSettingView (タスク作成・編集フォーム)
```

### ソースレイアウト (`EverydayTask/`)

```
EverydayTask/
├── Model/
│   ├── Tasks.swift              — コアモデル: Tasks, TaskSpanType, Spans, prevTasks（移行用）
│   ├── SortKey.swift            — SortKey, DivideDisplayedTasks enum
│   └── TaskCellStyle.swift      — TaskCellStyle enum（リスト/グリッド表示）
├── ViewModel/
│   └── TaskViewModel.swift      — 中央状態管理（774行、CRUD・日付計算・フィルタ・永続化）
├── Views/
│   ├── MainViews/               — 主要画面
│   │   ├── TaskView.swift       — ハーフモーダルタスクリスト
│   │   ├── AllTaskListView.swift — 全タスク一覧（検索・ソート）
│   │   ├── RegularlyTaskView.swift
│   │   ├── CalendarView.swift
│   │   ├── TaskCell.swift       — タスクセル
│   │   ├── AllTaskCell.swift
│   │   └── RegularlyTaskCell.swift
│   ├── SubViews/                — モーダル・詳細画面
│   │   ├── TaskSettingView.swift — タスク作成・編集フォーム
│   │   ├── SideMenuView.swift   — サイドバー
│   │   └── EditRegularlyTaskHistoryView.swift
│   ├── CalendarView/            — カスタムカレンダー（RK* プレフィックス）
│   │   ├── RKViewController.swift — UIPageViewController ラッパー
│   │   ├── RKManager.swift      — カレンダー状態管理
│   │   ├── RKMonth.swift / RKCell.swift / RKWeekdayHeader.swift
│   │   └── RKDate.swift / RKColorSettings.swift
│   └── Components/              — 再利用コンポーネント
│       ├── AddTaskButton.swift
│       ├── SpanView.swift
│       └── Pickers/
├── ContentView.swift            — ルートコンテナ
└── EverydayTaskApp.swift        — @main エントリポイント
```

### 状態管理

- `TaskViewModel`（ObservableObject）が唯一のビジネスロジック層
- `@StateObject` でルート View から生成、`@ObservedObject` で子 View に伝播
- `@AppStorage` でユーザー設定（cellStyle, sortKey, 通知トグル）を保持

### データ永続化

- `UserDefaults` + JSON エンコード（`Codable`）
- メインデータキー: `"tasks"` → `[Tasks]` 配列
- App Group: `group.myproject.EverydayTask.widget2`（Widget と共有）
- CoreData は未使用

### データモデル

**`Tasks`** (Codable):
- `id`, `title`, `detail`, `addedDate`
- `spanType`: `.custom`（固定間隔）/ `.selected`（特定曜日）
- `span`: `.day` / `.week` / `.month` / `.year` / `.infinite`
- `doCount`: スパンあたりの目標回数
- `spanDate: [Int]`: 選択曜日インデックス（1-7）
- `doneDate: [Date]`: 完了日の履歴配列
- `notification`, `notificationHour`, `notificationMin`
- `accentColor`: 色名文字列（`"Blue"` 等）→ View 層で `Color` に変換
- `isAble`: 表示/非表示トグル

**タスク分類:**
- **Daily Tasks**: `spanType == .custom && span == .day` または `spanType == .selected`
- **Regularly Tasks**: `span == .week / .month / .year / .infinite`

**`prevTasks`**: 旧バージョンからのデータ移行用構造体（削除禁止）

### カレンダー

- `RK*` プレフィックスのカスタム実装
- `UIPageViewController` を `UIViewControllerRepresentable` でラップ
- `RKManager` がカレンダー状態（選択日、表示範囲）を管理

## Targets

| Target | Purpose |
|--------|---------|
| EverydayTask | メインアプリ (iOS 16.4+) |
| EverydayTaskWidgetExtension | ホーム/ロック画面ウィジェット + Live Activity スタブ |

## Key Entry Points

- `EverydayTaskApp.swift` — @main エントリポイント
- `TaskViewModel.swift` — 全ビジネスロジックの中央管理
- `ContentView.swift` — ルート画面（サイドバー + カレンダー + モーダル）
- `TaskView.swift` — メインタスクリスト UI

## App Configuration

- **Bundle ID**: `myproject.EverydayTaskdaiseitanaka`
- **Widget Bundle ID**: `myproject.EverydayTaskdaiseitanaka.EverydayTaskWidget`
- **App Group**: `group.myproject.EverydayTask.widget2`

## Coding Rules

### Swift Style

- **強制アンラップ (`!`) 禁止** — `guard let` / `if let` / `??` を使う
- **ハードコード禁止** — UserDefaults キー・App Group 名等は定数化する
- **アクセス修飾子を明示** — 外部から不要なものは `private`
- **日本語コメント推奨**
- **未使用コード禁止** — コメントアウトされたコード、未使用 import は即削除

### データ安全性

- **データ消失は最悪のケース** — 保存・削除ロジックは必ず影響範囲を確認
- **後方互換性** — `Codable` のプロパティ追加時はデフォルト値を必ず設定
- **prevTasks 移行構造体は削除禁止** — 旧バージョンユーザーのデータ移行に必要
- **Widget との同期** — タスクデータ変更時は App Group の UserDefaults も更新すること

### UI ルール

- **Dynamic Type 対応** — 固定フォントサイズではなく `.body`, `.caption` 等を使用
- **小型端末対応** — iPhone SE (375pt幅) でもレイアウトが崩れないこと
- **タップ領域** — 最小 44pt 以上を保証
- **ローカライズ** — ユーザー表示文字列は `LocalizedStringKey` でローカライズ対応

## 既知の技術的負債

- `TaskViewModel` が 774 行で肥大化（機能別に分割推奨）
- `RKManager` で `Date!`（暗黙アンラップ Optional）を使用
- デバッグ用 print 文（絵文字付き）がプロダクションコードに残存
- App Group 名・UserDefaults キーがマジックストリング
- 英語ローカライズファイルが空

## Agent & Skill 構成

| Agent | 役割 |
|-------|------|
| `pm` | PM: 要件定義・仕様整理・タスク分解 |
| `implementer` | 実装者: コーディング・ファイル構成・ビルド確認 |
| `qa` | QA: テスト観点洗い出し・デグレ確認・レビュー |
| `designer` | デザイナー: UI/UX レビュー・レイアウト検証 |

| Skill | 用途 |
|-------|------|
| `/feature-start` | 新機能開発の開始（PM→設計→実装→QA→デザイン） |
| `/refact` | 包括的コードレビュー＆リファクタリング |
| `/pm` | PM 観点での要件整理・タスク分解 |
| `/implement` | 実装の実行 |
| `/qa` | QA 観点でのレビュー・テスト |
| `/design-review` | デザイン観点での UI レビュー |
| `/xcode` | XcodeBuildMCP を使った iOS ビルド・テスト・実行・デバッグ |
