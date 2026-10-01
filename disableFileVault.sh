#!/bin/bash

set -euo pipefail

# ログインユーザーを取得（ls パースを避け stat を使用）
username=$(stat -f %Su /dev/console)

# スクリプト終了時に一時ファイルが残らないよう保証
tmpfile=""
cleanup() {
    if [[ -n "$tmpfile" && -f "$tmpfile" ]]; then
        rm -f "$tmpfile"
    fi
}
trap cleanup EXIT INT TERM

# パスワード入力ループ
while true; do
    inputpass=$(osascript -e '
        tell application "SystemUIServer"
            set result to text returned of (display dialog "ログインユーザのパスワードを入力して実行ボタンを押してください。" ¬
                default answer "" ¬
                with title "FileVault 解除" ¬
                buttons {"実行"} ¬
                with icon caution ¬
                with hidden answer)
        end tell
        return result
    ')
    if [[ -n "$inputpass" ]]; then
        break
    fi
    osascript -e 'display alert "ログインユーザのパスワードを入力してください。"'
done

# 一時ファイルを現在ユーザーのみ読み取れる権限で作成
tmpfile=$(mktemp /tmp/filevault.XXXXXX)
chmod 600 "$tmpfile"

# XML特殊文字をエスケープ
escape_xml() {
    local s="$1"
    s="${s//&/&amp;}"
    s="${s//</&lt;}"
    s="${s//>/&gt;}"
    s="${s//\"/&quot;}"
    s="${s//\'/&apos;}"
    printf '%s' "$s"
}

escaped_user=$(escape_xml "$username")
escaped_pass=$(escape_xml "$inputpass")

# plist を一時ファイルへ書き込み（ディスク書き込みは最小限・最短時間）
cat > "$tmpfile" <<PLIST_EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Username</key>
    <string>${escaped_user}</string>
    <key>Password</key>
    <string>${escaped_pass}</string>
</dict>
</plist>
PLIST_EOF

# FileVault を無効化
fdesetup disable -inputplist < "$tmpfile"

# 即座に削除（trap でも保証されるが明示的に削除）
rm -f "$tmpfile"
tmpfile=""

# 再起動は Jamf Pro ポリシーの「再起動」オプションで実施すること
# ポリシー設定: [一般] タブ > 再起動オプション にて再起動を有効にする
osascript -e 'display dialog "FileVault をオフにします。\n設定完了後に再起動されます。" with title "FileVault 設定変更中" buttons {"OK"}' &

sleep 5

# shutdown -r now
