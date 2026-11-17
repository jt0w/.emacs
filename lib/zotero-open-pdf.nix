# WARNING: vibe coded
{ writeShellApplication
, curl
, jq
, xdg-utils
}:

writeShellApplication {
  name = "zotero-open-pdf";

  runtimeInputs = [
    curl
    jq
    xdg-utils
  ];

  text = ''
    if [[ $# -ne 1 ]]; then
      echo "Usage: zotero-open-pdf <citekey>" >&2
      exit 2
    fi

    citekey="$1"

    url=$(curl -sf http://localhost:23119/better-bibtex/json-rpc \
      -X POST \
      -H "Content-Type: application/json" \
      --data-binary "$(jq -nc --arg key "$citekey" '{
        jsonrpc: "2.0",
        method: "item.attachments",
        params: [$key],
        id: 1
      }')" | jq -r '.result[0].open // empty')

    if [[ -n "$url" ]]; then
      exec ${xdg-utils}/bin/xdg-open "$url"
    else
      echo "No PDF attachment found for: $citekey" >&2
      exit 1
    fi
  '';
}
