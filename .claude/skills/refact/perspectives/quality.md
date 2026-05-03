# コード品質 チェック

## チェック項目

- 危険な実装はないか（強制アンラップ `!`、その場しのぎのハードコード）
- 不要なコードはないか（デッドコード、未使用 import、コメントアウトされたコード）
- 各種命名（フォルダ、ファイル、struct、class、変数、コメント）は最適か
- 可読性の著しく低いロジックや簡略化できるロジックがないか
- 共通化できるロジックや再利用できるコンポーネントはないか
- アクセス修飾子は適切か（`private`, `internal`, `public` の使い分け）
- ファイル構成は既存の構成にあっているか（適切にファイル分割できているか）
- 定数がハードコードされていないか（`AppConstants`, `StorageKeys`, `TagID` を使用すること）
- Swift API Design Guidelines に準拠した命名になっているか（略語禁止）
- アニメーション値が定数化されているか（`Animation.appSpring`, `.selectionToggle` を使用すること）
- 選択 UI のスタイル値が定数化されているか（`SelectionStyle.backgroundOpacity`, `.inactiveSectionOpacity` を使用すること）

## 過去のレビューで発見された典型的な問題

- **マジックナンバーの散在**: `opacity(0.08)`, `.spring(response: 0.35, dampingFraction: 0.7)`, `.easeInOut(duration: 0.15)` が10箇所以上にハードコードされていた。`AppConstants` のアニメーション定数 / `SelectionStyle` の定数を使うこと
- **座標値のハードコード**: 東京駅の緯度経度 `35.681236, 139.767125` が3箇所に散在。`LocationTagConfig.defaultCoordinate` に統一済み
- **重複ロジック**: 選択チェックマークの `Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")` パターンが10箇所以上で重複。`SelectionCheckmark` コンポーネントに統一済み
- **3画面で完全に同じ選択状態管理ロジック**: `SelectionState<Section>` 汎用クラスに抽出済み
- **BulkActionBar アニメーションのハードコード**: `.spring(response: 0.35, dampingFraction: 0.8)` が3画面に散在。`Animation.bulkActionBar` 定数に統一すること
- **EditingBulkAction.label のローカライズ漏れ**: ラベル文字列が `String(localized:)` を経由せずハードコードされていた
