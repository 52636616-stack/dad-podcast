#!/bin/bash
# podcast-rss-update.sh v2 - 更新RSS Feed
# 用法: ./podcast-rss-update.sh <标题> <MP3文件名> <时长秒> <文件大小字节>

PODCAST_DIR="/Users/z/.openclaw/workspace/podcast"
OUTPUT="${PODCAST_DIR}/podcast.xml"
BASE_URL="http://127.0.0.1:18900"

TITLE="$1"
FILENAME="$2"
DURATION="$3"
FILESIZE="$4"
DATE=$(date "+%a, %d %b %Y %H:%M:%S +0800")
GUID="${FILENAME}"
AUDIO_URL="${BASE_URL}/audio/${FILENAME}"

# 构建新item XML
NEW_ITEM=$(cat << XMLEND
    <item>
      <title>${TITLE}</title>
      <description>${TITLE}</description>
      <enclosure url="${AUDIO_URL}" length="${FILESIZE}" type="audio/mpeg"/>
      <guid>${GUID}</guid>
      <pubDate>${DATE}</pubDate>
      <itunes:duration>${DURATION}</itunes:duration>
    </item>
XMLEND
)

# 保存历史（保留最多5期）
EPISODES_FILE="${PODCAST_DIR}/episodes.txt"
echo "${NEW_ITEM}" > /tmp/new_episode.txt
if [ -f "$EPISODES_FILE" ]; then
  cat "$EPISODES_FILE" >> /tmp/new_episode.txt
fi
# 取前5条
head -5 /tmp/new_episode.txt > "$EPISODES_FILE"

# 生成RSS
cat > "${OUTPUT}" << RSSHEAD
<?xml version="1.0" encoding="UTF-8"?>
<rss xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" version="2.0">
  <channel>
    <title>爸爸的报告</title>
    <description>专属语音报告，来自泽曦</description>
    <link>${BASE_URL}</link>
    <language>zh-cn</language>
    <itunes:author>朱泽曦</itunes:author>
    <itunes:image href="${BASE_URL}/cover/cover.jpg"/>
    <itunes:category text="News"/>
RSSHEAD

cat "$EPISODES_FILE" >> "${OUTPUT}"

cat >> "${OUTPUT}" << RSSFOOT
  </channel>
</rss>
RSSFOOT

echo "✅ RSS Feed 已更新: ${OUTPUT} (${DURATION}秒)"
echo "   ${TITLE}"
