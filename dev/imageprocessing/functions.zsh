function scale_image() {
  if [ "$1" = "" ]; then
    echo "Please provide input file name"
    echo "Usage:"
    echo "  scale_image <INPUT_FILE> <OUTPUT_FILE>"
    return
  fi
  if [ "$2" = "" ]; then
    echo "Please provide output file base name"
    echo "Usage:"
    echo "  scale_image <INPUT_FILE> <OUTPUT_FILE>"
    return
  fi

  INPUT_FILE=$1
  OUTPUT_FILE=$2

  extension="${OUTPUT_FILE##*.}"
  filename="${OUTPUT_FILE%.*}"

  sizes=(16 24 32 48 64 128 256 512 1024)
  for size in "${sizes[@]}"; do
    of_name="${filename%.$extension}_$size.$extension"
    echo $of_name
    convert \
        -resize x${size} \
        -gravity center \
        -crop ${size}x${size}+0+0 \
        -background none \
        -flatten \
        -colors 256 \
        ${INPUT_FILE} \
        ${of_name}
  done
}
