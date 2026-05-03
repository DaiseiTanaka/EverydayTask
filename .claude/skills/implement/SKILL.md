---
name: implement
description: PM の仕様に基づいてコーディング・ファイル構成・ビルド確認を行う。
argument-hint: "<実装するタスクの説明>"
---

# 実装の実行

対象: `$ARGUMENTS`

## 手順

1. 対象タスクの仕様を確認する
2. 関連する既存コードを読み込む
3. CLAUDE.md の Coding Rules に従って実装する
4. ビルドを実行して確認する

### 実装の流れ

1. **既存コードの把握**: 変更対象ファイルと依存ファイルをすべて読む
2. **下位層から実装**: Model → Repository → Service → Presenter → Screen の順
3. **Coding Rules の遵守**:
   - 強制アンラップ禁止
   - ハードコード禁止（`AppConstants` を使用）
   - アクセス修飾子を明示
   - ローカライズは `String(localized:)`
   - 1 ファイル = 1 型
4. **共通コンポーネント**: 再利用可能な UI は `Components/` に切り出す
5. **ビルド確認**: `xcodebuild build` でコンパイルエラーがないことを確認
6. **Xcode プロジェクト登録**: 新規ファイルは `.pbxproj` に追加する

### データ変更時の追加チェック

- `Codable` プロパティ追加 → デフォルト値を設定
- 保存キー変更 → 後方互換性を確保
- `isReadOnly` ガードを忘れない
