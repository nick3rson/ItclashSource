#!/bin/bash
echo "🔧 Installing CTF Tools..."
sudo apt update
sudo apt install -y sqlmap ffuf python3-pip git curl
pip3 install -r jwt_tool/requirements.txt
go install github.com/securego/gosec/v2/cmd/gosec@latest
echo "✅ Done! All tools installed."
