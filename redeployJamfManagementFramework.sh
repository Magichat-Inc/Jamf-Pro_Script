#!/bin/bash

set -euo pipefail

# ---------------------------------------------------------------
# 認証情報は Jamf スクリプトパラメータで渡す（スクリプトに直書きしない）
#   パラメータ 4: Jamf Pro URL (例: https://example.jamfcloud.com)
#   パラメータ 5: API クライアント ID
#   パラメータ 6: API クライアントシークレット
#   パラメータ 7: 対象コンピュータ ID（カンマ区切りで複数指定可）
#
# 【Jamf Pro API クライアントに必要な権限】
#   設定 > API ロールとクライアント > API ロール にて以下を付与すること
#   - Send Computer Remote Command to Install Package
#   - Read Computer Check-In
# ---------------------------------------------------------------
jss_url="${4:-}"
client_id="${5:-}"
client_secret="${6:-}"
computer_ids="${7:-}"

# 必須パラメータの検証
if [[ -z "$jss_url" || -z "$client_id" || -z "$client_secret" || -z "$computer_ids" ]]; then
    echo "ERROR: パラメータが不足しています。" >&2
    echo "  パラメータ 4: Jamf Pro URL" >&2
    echo "  パラメータ 5: API クライアント ID" >&2
    echo "  パラメータ 6: API クライアントシークレット" >&2
    echo "  パラメータ 7: コンピュータ ID（カンマ区切り）" >&2
    exit 1
fi

# URL末尾スラッシュを除去
jss_url="${jss_url%/}"

# コンピュータ ID を数値のみ許可
IFS=',' read -ra id_array <<< "$computer_ids"
for id in "${id_array[@]}"; do
    id="${id// /}"
    if ! [[ "$id" =~ ^[0-9]+$ ]]; then
        echo "ERROR: コンピュータ ID は数値のみ有効です: '$id'" >&2
        exit 1
    fi
done

api_token=""

# 終了時にトークンを確実に失効
invalidate_token() {
    if [[ -n "$api_token" ]]; then
        curl --silent --fail --request POST \
            --url "${jss_url}/api/v1/auth/invalidateToken" \
            --header "Authorization: Bearer ${api_token}" || true
    fi
}
trap invalidate_token EXIT INT TERM

# OAuth 2.0 クライアントクレデンシャルフローでアクセストークンを取得
# JSON パースは plutil を使用（python3 は Xcode CLI Tools 未インストール環境では使用不可）
api_token=$(curl --silent --fail --request POST \
    --url "${jss_url}/api/oauth/token" \
    --header "Content-Type: application/x-www-form-urlencoded" \
    --data-urlencode "grant_type=client_credentials" \
    --data-urlencode "client_id=${client_id}" \
    --data-urlencode "client_secret=${client_secret}" \
    | /usr/bin/plutil -extract access_token raw -)

if [[ -z "$api_token" ]]; then
    echo "ERROR: API トークンの取得に失敗しました。" >&2
    exit 1
fi

# 各コンピュータに Jamf Management Framework を再デプロイ
for id in "${id_array[@]}"; do
    id="${id// /}"
    echo "Redeploying Jamf Management Framework to computer ID: ${id}"
    curl --silent --fail --request POST \
        --url "${jss_url}/api/v1/jamf-management-framework/redeploy/${id}" \
        --header "accept: application/json" \
        --header "Authorization: Bearer ${api_token}"
    echo ""
done

exit 0
