# 設計（MVVM & クリーンアーキテクチャ）チェック

## チェック項目

- MVVM & クリーンアーキテクチャに沿った実装になっているか
- Screen(UI) > Presenter(UI logic) > Service(Business logic) > Repository(Data) の層構造になっているか
- 各層の責務が混在していないか
- 依存の方向が正しいか（上位層 → 下位層の一方向）
- 1 ファイル = 1 型の原則を守っているか
- 新規ファイルの配置が既存ディレクトリ構成に合っているか

## レイヤー責務の基準

| レイヤー | 責務 | やってはいけないこと |
|---------|------|-------------------|
| Screen | SwiftUI View のみ | ビジネスロジック、データ操作、UIState の所有 |
| Presenter | UI ロジック、UIState の管理 | 直接の永続化操作、View の生成、UIApplication 呼び出し |
| Service | ビジネスロジック | UI 依存、View の参照 |
| Repository | 永続化（SharedDefaults/UserDefaults） | ビジネスロジック |

## UIState パターン

- `{Context}UIState` struct を Presenter ファイル内で定義し、`presenter.uiState` で公開
- 画面固有の UI 状態（選択状態、フィルタ、ソート、モーダル表示 etc.）は必ず Presenter で管理
- Screen に `@State` で UI ロジック用の状態を持たせない（`@State` は純粋な View ローカル状態のみ）
- 選択状態は `SelectionState<Section>` を Presenter のプロパティとして保持（`presenter.selection` / `presenter.editingSelection`）

## 過去のレビューで発見された典型的な問題

- **Screen 層へのビジネスロジック漏れ**: 一括操作（bulk action）のロジック（セクション種別に応じたアイテム絞り込み・操作実行・Undo 登録）が Screen に実装されていた。これらは Presenter の責務であり、Screen は `presenter.bulkShow(ids:section:)` のようなメソッドを呼ぶだけにすべき
- **選択状態管理の重複**: 3画面で全く同じ toggleSelection / clearSelection / isSectionActive ロジックが重複していた。`SelectionState<Section>` 汎用クラスに抽出済み
- **Presenter が UIApplication を直接呼び出し**: `openSettings()` が `UIApplication.shared.open()` を直接呼んでおり、Presenter がUIKitに依存。UIApplication の操作は Screen 層の責務
- **Screen 内の enum 配置**: `EditingBulkAction` 等の UI ロジック用の型が Screen ファイル内に nested type として定義されていた。Presenter 層の型として定義するか別ファイルに分離すべき
