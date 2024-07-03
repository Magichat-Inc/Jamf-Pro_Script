#!/bin/bash

username=`ls -la /dev/console | cut -d " " -f 4`
while :
do
	inputpass=$(osascript -e 'tell application "SystemUIServer"
	set Printername to text returned of (display dialog "ログインユーザのパスワードを入力して実行ボタンを押してください。" default answer "" with title "FileVault 2 解除" buttons {"実行"} with icon caution with hidden answer)
	end tell' ) 
    if [ -n "$inputpass" ]; then
    	break
    else
    	osascript -e 'display alert "ログインユーザのパスワードを入力してください。"'
    fi
done

echo "<?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
  <plist version="1.0">
  <dict>
  <key>Username</key>
  <string>$username</string>
  <key>Password</key>
  <string>$inputpass</string>
  </dict>
  </plist>" > /Users/Shared/filevault.plist
fdesetup disable -inputplist < /Users/Shared/filevault.plist
rm /Users/Shared/filevault.plist

osascript -e  'display dialog "FileVault 2 をオフにします。
1分後に強制的に再起動されます。" with title "FileVault 2 設定変更中" buttons {"OK"}' &
sleep 60

# 再起動
sudo shutdown -r now
