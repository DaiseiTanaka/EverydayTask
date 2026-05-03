# Refact: よくある失敗パターン

## 1. private アクセスレベルの見逃し
別ファイルの extension に分割した際、`private` メンバーにアクセスできずビルドエラーになる。分割前に `private` → アクセス修飾子なし（internal）への変更を確認すること。

## 2. Xcode プロジェクトへのファイル登録漏れ
新規ファイルを作成しても `project.pbxproj` に登録しないとビルド対象にならない。PBXBuildFile, PBXFileReference, PBXGroup, PBXSourcesBuildPhase の4箇所すべてに追加が必要。

## 3. 500行ルールの boundary 判断ミス
MARK セクションの途中で分割すると、関連するヘルパーメソッドが離れてしまう。MARK セクション単位で論理的にまとまった機能を切り出すこと。

## 4. Widget/ShareExtension ターゲットへの登録漏れ
Model 層のファイル（Tag, Task 等）は Widget と ShareExtension ターゲットにも登録が必要。Service/Screen 層は通常メインターゲットのみ。

## 5. ローカライズエントリの重複・漏れ
ファイル分割時にコードを移動すると、`Localizable.xcstrings` の参照が変わることはないが、新規文字列追加時に en 翻訳の追加を忘れやすい。
