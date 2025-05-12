docker build . --tag builder

docker run --rm -ti -e CCACHE_DIR=/ccache -v ccache:/ccache -v gitcache:/gitcache -v ./build:/build --gpus all builder bash /build.sh
