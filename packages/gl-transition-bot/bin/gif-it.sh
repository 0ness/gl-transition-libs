
set -e

tname=$1
imgurkey=$IMGUR_KEY

tmpimgs="/tmp/gl-transition-imgs"
palette="/tmp/gl-transition-palette.png"
gif="/tmp/gl-transition.gif"


rm -rf $tmpimgs $palette $gif

gl-transition-render -t $tname -o $tmpimgs \
  -i scripts/1.jpg,scripts/2.jpg,scripts/3.jpg,scripts/1.jpg \
  -f 50 -d 12 -w 512 -h 400

filters="scale=256:-1:flags=lanczos"
ffmpeg -v fatal -framerate 30 -i $tmpimgs/%d.png -vf "$filters,palettegen" -y $palette
ffmpeg -v fatal -framerate 30 -i $tmpimgs/%d.png -i $palette -lavfi "$filters [x]; [x][1:v] paletteuse" -y $gif

curl -sS -H "Authorization: Client-ID $imgurkey" -H 'Expect: ' -F "image=@$gif" https://api.imgur.com/3/image |
json data.link
