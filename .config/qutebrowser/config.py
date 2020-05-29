# Load existing settings made via :set
config.load_autoconfig()

config.bind(',m', 'hint links spawn --detach mpv --force-window yes {hint-url}')
config.bind(',v', 'spawn mpv --ytdl-format="bestvideo[height<=?1080][vcodec!=vp9]+bestaudio/best" {url}')
config.bind(',dla', 'spawn youtube-dl -x --audio-format mp3 -o ~/user/Music/%(title)s.%(ext)s {url}')
