#!/bin/bash
# podcast-generator.sh - 播客内容生成器
# 把文字报告转成MP3，更新RSS Feed
# 用法: ./podcast-generator.sh <报告标题> <报告文件路径>

PODCAST_DIR="/Users/z/.openclaw/workspace/podcast"
TITLE="$1"
CONTENT_FILE="$2"

if [ -z "$TITLE" ] || [ -z "$CONTENT_FILE" ]; then
  echo "用法: $0 <标题> <内容文件路径>"
  exit 1
fi

# 读内容
CONTENT=$(cat "$CONTENT_FILE")

# 生成唯一ID和日期
EPISODE_ID=$(date +%s)
DATE=$(date "+%a, %d %b %Y %H:%M:%S +0800")
SHORT_DATE=$(date "+%Y-%m-%d")
FILENAME="${SHORT_DATE}-${EPISODE_ID}.mp3"
AUDIO_PATH="${PODCAST_DIR}/audio/${FILENAME}"

# 用macOS say生成音频
say -o /tmp/podcast_temp.aiff "$CONTENT" 2>/dev/null
ffmpeg -y -i /tmp/podcast_temp.aiff -b:a 48k "${AUDIO_PATH}" 2>/dev/null
rm -f /tmp/podcast_temp.aiff

# 获取音频时长（秒）
DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "${AUDIO_PATH}" 2>/dev/null | cut -d. -f1)

# 文件大小
FILESIZE=$(stat -f%z "${AUDIO_PATH}")

echo "✅ MP3生成完毕: ${FILENAME} (${DURATION}秒, ${FILESIZE}字节)"
echo "FILE=${FILENAME}" > /tmp/podcast_episode_info
echo "DURATION=${DURATION}" >> /tmp/podcast_episode_info
echo "FILESIZE=${FILESIZE}" >> /tmp/podcast_episode_info
echo "TITLE=${TITLE}" >> /tmp/podcast_episode_info
echo "DATE=${DATE}" >> /tmp/podcast_episode_info
