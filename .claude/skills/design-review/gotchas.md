# Design Review: よくある失敗パターン

## 1. タップ領域不足を見逃す
小さなアイコンボタンが HIG の最小44ptを下回っているのに指摘漏れする。全てのインタラクティブ要素で `.frame(minHeight: 44)` を確認すること。

## 2. Dynamic Type 非対応の固定値を見逃す
`.font(.system(size: 16))` や固定 padding は Dynamic Type で破綻する。セマンティックフォント（`.body` 等）と `@ScaledMetric` を使うべき。

## 3. `.blue` ハードコードを見逃す
`.foregroundStyle(.blue)` が散在しやすい。`Color.accentColor` に統一する。

## 4. セクション末尾 divider の非表示漏れ
List の各セクション最終行に `.listRowSeparator(.hidden, edges: .bottom)` が適用されているか確認を忘れがち。

## 5. ローカライズ漏れの大量発生
新規画面の文字列を `String(localized:)` にしたが、`Localizable.xcstrings` の `en` エントリを追加し忘れる。
