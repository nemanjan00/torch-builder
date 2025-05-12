#!/bin/bash

export CUDAHOSTCXX=/usr/bin/g++-11

export CC=gcc-11
export CXX=g++-11

export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH

export CMAKE_CUDA_ARCHITECTURES="75"
export TORCH_CUDA_ARCH_LIST="7.5"

export USE_CUFILE=0
export USE_NINJA=1
export USE_CUDA=1

export MAX_JOBS=$(nproc)
export USE_NCCL=0
export USE_DISTRIBUTED=1

virtualenv venv

source venv/bin/activate

pip3 install cmake pyyaml typing_extensions ninja numpy

cd /gitcache

function build () {
	PACKAGE=$1
	VERSION=$2

	if [ ! -d "$PACKAGE" ]; then
		git clone --recursive https://github.com/pytorch/$PACKAGE
	fi

	cd $PACKAGE

	git pull

	git checkout $VERSION
	git submodule sync && git submodule update --init --recursive

	rm -rf *.whl

	rm -rf build

	mkdir build

	cd build

	if test "pytorch" = "$PACKAGE"
	then
		cmake .. -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -GNinja -DBUILD_PYTHON=True -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/gitcache/pytorch/$PACKAGE -DCMAKE_PREFIX_PATH=$VIRTUAL_ENV/lib/python3.11/site-packages -DPython_EXECUTABLE=$VIRTUAL_ENV/bin/python -DTORCH_CUDA_ARCH_LIST=7.5 -DUSE_DISTRIBUTED=1 -DUSE_NCCL=0 -DUSE_NUMPY=True -DBUILD_TEST=0 -DCMAKE_INSTALL_PREFIX="$PWD/../torch" -DUSE_CUFILE=OFF

		retVal=$?
		if [ $retVal -ne 0 ]; then
			echo "Error"
			exit $retval
		fi

		ninja

		retVal=$?

		if [ $retVal -ne 0 ]; then
			echo "Error"
			exit $retval
		fi

		ninja install

		retVal=$?

		if [ $retVal -ne 0 ]; then
			echo "Error"
			exit $retval
		fi
	fi

	cd ..

	pip3 wheel . -v --no-build-isolation --no-deps

	retVal=$?

	if [ $retVal -ne 0 ]; then
		echo "Error"
		exit $retval
	fi

	rm -rf /build/$PACKAGE

	mkdir -p /build/$PACKAGE

	cp *.whl /build/$PACKAGE

	cd /gitcache
}

build pytorch v2.7.0

pip install /build/pytorch/torch*.whl --force-reinstall

export Torch_DIR="$VIRTUAL_ENV/lib/python3.11/site-packages/torch/share/cmake/Torch"
export CMAKE_PREFIX_PATH="$Torch_DIR${CMAKE_PREFIX_PATH:+:$CMAKE_PREFIX_PATH}"

build vision v0.22.0

pip install /build/pytorch/torch*.whl --force-reinstall
pip install /build/vision/torchvision*.whl

python - <<'PY'
import torch, torchvision, torch.ops as ops
print(torch.__version__)        # 2.7.0+cu129
print(torchvision.__version__)  # 0.22.0+cu129
print('nms' in dir(ops.torchvision))  # True
PY

build audio v2.7.0
