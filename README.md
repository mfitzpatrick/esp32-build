# Build ESP32 firmware with Docker

## Getting Started
Clone this repository
Run
```
docker build -t esp32-build .
docker run -it esp32-build bash
```
You can mount your source code in the container, cd to that directory,
and build it with `make`. Or you can cd to one of the examples directories
and build them.
```
cd $IDF_PATH/examples
```

## Using the prebuilt image
```
docker pull ghcr.io/mfitzpatrick/esp32-build:<tag name>
docker run --rm ghcr.io/mfitzpatrick/esp32-build:<tag name>
```

