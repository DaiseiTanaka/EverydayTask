# デザイン・UI チェック

## チェック項目

### 基本
- 端末幅の小さいデバイス（iPhone SE 375pt 幅）でもレイアウトが崩れないか
- アプリ全体に登場するコンポーネント（ボタン、テキスト、キーボード）のサイズ感や操作仕様は統一されているか
- 端末自体の設定でテキストサイズを大きくしているユーザー（Dynamic Type）にも適切に表示され、操作可能になっているか
- レイアウトが固定値に依存しすぎていないか
- タップ領域が 44pt 以上確保されているか（SHIG #78: `.frame(width:height:)` が44未満でないか）
- セマンティックフォントスタイル（`.body`, `.caption` 等）を使用しているか
- `@ScaledMetric` で Dynamic Type に対応しているか
- カラースキーム（ライト/ダーク）で問題なく表示されるか
- 空状態・ローディング状態・エラー状態の UI が考慮されているか
- Haptic feedback の強度がアプリ全体で統一されているか

### SHIG（ソシオメディア HIG）原則チェック
- **黙って実行する（Do, Don't Ask）**: Undo 可能な操作に確認ダイアログを表示していないか。アプリには `UndoHandler` + `UndoToastView` が実装済みなので、復元可能な削除・非表示・復元にはダイアログ不要。不可逆操作（完全削除、データ消失）のみ確認を残す
- **具体的な動詞をボタンラベルに使う**: `Button("OK")` ではなく `Button("閉じる")` `Button("確認")` `Button("削除")` 等の具体的な動詞を使用しているか
- **一貫性**: 同じ目的の色は同じ色を使っているか（例: コンテンツ有りの状態は `Color.accentColor` に統一）。ハードコード `.blue` ではなく `Color.accentColor` を使用しているか
- **シグニファイア**: 操作可能な要素は押せそうに、操作不能な要素は押せなさそうに見えるか。破壊的ボタンは `.red`、無効状態は `.opacity` で区別しているか
- **フィードバック**: 保存・削除等の重要操作にハプティック（`UINotificationFeedbackGenerator(.success)` 等）があるか
- **フリップフロップ回避**: トグルのラベルが「現在の状態」か「操作後の状態」か曖昧でないか
- **スクロール可能性の明示**: 水平スクロールで `showsIndicators: false` を安易に使っていないか
- **エラーは建設的に**: エラーメッセージが原因と対処法の両方を示しているか

## 過去のレビューで発見された典型的な問題

- **タップ領域不足**: `.frame(minHeight: 36)` で HIG の最小タップ領域 44pt を下回っていた。`.frame(minHeight: 44)` 以上を保証すること
- **BulkActionBar のパディングが Dynamic Type 非対応**: `.padding(.vertical, 14)` が固定値。`@ScaledMetric` を使用すること
- **Undo 可能な操作に確認ダイアログ**: 「すべて再表示」が Undo 可能なのに `.alert` で確認を表示していた。SHIG「黙って実行する」原則に従い、即実行+UndoToast に変更すること
- **復元スワイプの色不統一**: ArchivedScreen は `.tint(.green)` で RecentlyDeletedScreen は `.tint(.blue)` だった。同系統の操作は色を統一すること
- **ハプティック漏れ**: 一括操作（bulk pin/hide/delete/restore）にハプティックフィードバックがなかった。重要操作には `UINotificationFeedbackGenerator` を追加すること（成功=`.success`、破壊=`.warning`）
- **`.blue` ハードコードの散在**: TagSettingScreen の位置情報セクション、CaptureExpandedSheet、TaskSettingScreen の URL、RemindersImportScreen 等で `.blue` / `.foregroundStyle(.blue)` が直接使用されていた。`Color.accentColor` に統一すること。Widget 内も `WidgetDataLoader.loadThemeColor()` を使用すること
- **IconPalette のタップ領域不足**: `minHeight: 40` で 44pt を下回っていた。`minHeight: 44` に修正すること
- **セクション末尾 divider 非表示漏れ**: ArchivedScreen / RecentlyDeletedScreen で `.listRowSeparator(.hidden, edges: .bottom)` が各セクション最終行に適用されていなかった
- **カレンダーの週始まりハードコード**: `firstWeekday - 1` で日曜始まりを前提としていた。`(firstWeekday - calendar.firstWeekday + 7) % 7` でユーザー設定の週始まり日に対応すること
- **固定フォントサイズ**: `.font(.system(size: 16))` が Dynamic Type 非対応。`.font(.body)` 等のセマンティックスタイルを使用すること
- **ローカライズ漏れの大量発生**: 新規画面で約47件の `String(localized:)` に英語翻訳が未追加。新規文字列追加時は必ず `Localizable.xcstrings` に `en` エントリを同時追加すること
