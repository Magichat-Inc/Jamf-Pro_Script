# Scripts for Jamf Pro

## 概要 (Overview)
Mac 管理のための便利なスクリプトを掲載予定 <br/>
A collection of useful scripts for Mac management

## コンテンツ (Contents)
 | Filename | Description (JA/EN) |
 | --- | --- |
 | redeployJamfManagementFramework.sh | Jamf管理フレームワークの再配備と再登録 <br />  Redeploys the Jamf management framework without having to unenroll and re-enroll a computer. |
  | disableFileVault.sh | FileVault の無効化 <br />  Disables FileVault. |
 |  |  |  |

## 注意事項 (Notes)

### disableFileVault.sh
- **PPPC プロファイルの展開を推奨**
  - `osascript` で `SystemUIServer` を制御するため、実行時にユーザーへ許可ダイアログが表示される場合があります。ユーザーが「許可」を選択すれば動作しますが、エンタープライズ環境では事前に PPPC プロファイルを展開することでダイアログを非表示にできます。
  - 設定値: 識別子 `com.jamfsoftware.jamf` / サービス: Apple イベント / 受信側: `com.apple.systemuiserver` / アクセス: 許可
