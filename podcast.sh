#!/bin/bash
# podcast.sh v2 - 一站式：生成音频+更新RSS
# 用法: ./podcast.sh <标题> <内容文件路径>

PODCAST_DIR="$(cd "$(dirname "$0")" && pwd)"
TITLE="$1"
CONTENT_FILE="$2"

if [ -z "$TITLE" ] || [ -z "$CONTENT_FILE" ]; then
  echo "用法: $0 <标题> <内容文件路径>"
  exit 1
fi

CONTENT=$(cat "$CONTENT_FILE")
EPISODE_ID=$(date +%s)
SHORT_DATE=$(date "+%Y-%m-%d")
FILENAME="${SHORT_DATE}-${EPISODE_ID}.mp3"
AUDIO_PATH="${PODCAST_DIR}/audio/${FILENAME}"

# 生成音频
say -o /tmp/podcast_temp.aiff "$CONTENT" 2>/dev/null
ffmpeg -y -i /tmp/podcast_temp.aiff -b:a 48k "${AUDIO_PATH}" 2>/dev/null
rm -f /tmp/podcast_temp.aiff

# 取时长和大小
DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "${AUDIO_PATH}" 2>/dev/null | cut -d. -f1)
FILESIZE=$(stat -f%z "${AUDIO_PATH}")

echo "✅ MP3: ${FILENAME} (${DURATION}秒, ${FILESIZE}字节)"

# 更新RSS
bash "${PODCAST_DIR}/podcast-rss-update.sh" "$TITLE" "$FILENAME" "$DURATION" "$FILESIZE"

echo ""
echo "✅ 播客制作完成！共${DURATION}秒"
echo "订阅链接: http://127.0.0.1:18900/podcast.xml"
