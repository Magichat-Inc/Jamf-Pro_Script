# CHANGELOG

## 2026-05-16

### disableFileVault.sh (旧: disableFileVault2.sh)

#### セキュリティ改善
- パスワード書き込み先を `/Users/Shared/` から `mktemp /tmp/` + `chmod 600` に変更（全ユーザーが読めるディレクトリへの書き込みを廃止）
- `trap cleanup EXIT INT TERM` を追加し、異常終了時も一時ファイルを確実に削除
- XMLインジェクション対策として `escape_xml()` 関数を追加（`&`, `<`, `>`, `"`, `'` をエスケープ）
- XMLのクォートをヒアドキュメントで適切に処理し、シェルによる引用符の誤解釈を防止

#### バグ修正・品質改善
- `set -euo pipefail` を追加（未定義変数・コマンド失敗での即時終了）
- ユーザー名取得を `ls -la | cut` から `stat -f %Su /dev/console` に変更（スペースを含む名前での誤動作を防止）
- バッククォート（`` ` ``）を `$()` に統一

#### Jamf Pro 連携対応
- `sleep 60` と `shutdown -r now` を削除し、再起動は Jamf Pro ポリシーの再起動オプションに委譲
- ダイアログメッセージを「1分後に強制的に再起動されます」から「設定完了後に再起動されます」に修正

---

### redeployJamfManagementFramework.sh

#### セキュリティ改善
- 認証情報のハードコードを廃止し、Jamf スクリプトパラメータ（`$4`〜`$7`）で受け取る形に変更
- 認証方式を API ユーザー（Basic 認証）から API クライアント（OAuth 2.0 クライアントクレデンシャルフロー）に変更
- トークン取得エンドポイントを `/api/v1/auth/token` から `/api/oauth/token` に変更
- `trap invalidate_token EXIT INT TERM` を追加し、異常終了時もアクセストークンを確実に失効
- `curl --fail` を追加し、HTTP エラー（4xx/5xx）を成功として素通りさせない

#### バグ修正・品質改善
- `set -euo pipefail` を追加（未定義変数・コマンド失敗での即時終了）
- JSON パースを `grep | sed` から `python3` に変更（JSON 構造変化や複数マッチによる誤動作を防止）
- タイポ修正：トークン失効処理で `$jss_URL`（大文字）が参照されておりトークンが失効されていなかった問題を解消
- 必須パラメータの検証を追加（不足時に明確なエラーメッセージで終了）
- `computer_id` の数値バリデーションを追加（不正な値が API に渡されるのを防止）
- カンマ区切りで複数台同時指定に対応

#### ドキュメント
- 必要な API 権限をスクリプト冒頭のコメントに記載
  - `Send Computer Remote Command to Install Package`
  - `Read Computer Check-In`
