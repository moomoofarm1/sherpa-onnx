#!/usr/bin/env bash
set -ex

dir=$PWD/build-ohos-armeabi-v7a

mkdir -p $dir
cd $dir

# Please first download the commandline tools from
# https://developer.huawei.com/consumer/cn/download/
#
# Example filename on Linux: commandline-tools-linux-x64-5.0.5.200.zip
# You can also download it from https://hf-mirror.com/csukuangfj/harmonyos-commandline-tools/tree/main

# mkdir /star-fj/fangjun/software/huawei
# cd /star-fj/fangjun/software/huawei
# wget https://hf-mirror.com/csukuangfj/harmonyos-commandline-tools/resolve/main/commandline-tools-linux-x64-5.0.5.200.zip
# unzip commandline-tools-linux-x64-5.0.5.200.zip
# rm commandline-tools-linux-x64-5.0.5.200.zip
if [ -z $OHOS_SDK_NATIVE_DIR ]; then
  OHOS_SDK_NATIVE_DIR=/star-fj/fangjun/software/huawei/command-line-tools/sdk/default/openharmony/native/
  export PATH=$OHOS_SDK_NATIVE_DIR/build-tools/cmake/bin:$PATH
  # You can find the following content inside OHOS_SDK_NATIVE_DIR
  # ls -lh /star-fj/fangjun/software/huawei/command-line-tools/sdk/default/openharmony/native/
  # total 524K
  # -rw-r--r--  1 kuangfangjun root 501K Jan  1  2001 NOTICE.txt
  # drwxr-xr-x  3 kuangfangjun root    0 Nov  6 22:36 build
  # drwxr-xr-x  3 kuangfangjun root    0 Nov  6 22:36 build-tools
  # -rw-r--r--  1 kuangfangjun root  371 Jan  1  2001 compatible_config.json
  # drwxr-xr-x  4 kuangfangjun root    0 Nov  6 22:36 docs
  # drwxr-xr-x 10 kuangfangjun root    0 Nov  6 22:36 llvm
  # -rw-r--r--  1 kuangfangjun root  16K Jan  1  2001 nativeapi_syscap_config.json
  # -rw-r--r--  1 kuangfangjun root 5.9K Jan  1  2001 ndk_system_capability.json
  # -rw-r--r--  1 kuangfangjun root  167 Jan  1  2001 oh-uni-package.json
  # drwxr-xr-x  3 kuangfangjun root    0 Nov  6 22:36 sysroot
fi

# If you don't want to install commandline tools, you can install the SDK
# using DevEco Studio. The following uses API version 10 as an example and
# it has installed the SDK to
# /Users/fangjun/software/huawei/OpenHarmony/Sdk/10/native
#
# Remember to select ``native`` when you install the SDK
if [ ! -d $OHOS_SDK_NATIVE_DIR ]; then
  OHOS_SDK_NATIVE_DIR=/Users/fangjun/software/huawei/OpenHarmony/Sdk/10/native
  # export PATH=$OHOS_SDK_NATIVE_DIR/build-tools/cmake/bin:$PATH
  # ls -lh /Users/fangjun/software/huawei/OpenHarmony/Sdk/10/native/
  # total 1560
  # -rw-r--r--   1 fangjun  staff   764K Jan  1  2001 NOTICE.txt
  # drwxr-xr-x   3 fangjun  staff    96B Nov 19 22:42 build
  # drwxr-xr-x   3 fangjun  staff    96B Nov 19 22:42 build-tools
  # drwxr-xr-x  10 fangjun  staff   320B Nov 19 22:42 llvm
  # -rw-r--r--   1 fangjun  staff   4.0K Jan  1  2001 nativeapi_syscap_config.json
  # -rw-r--r--   1 fangjun  staff   1.9K Jan  1  2001 ndk_system_capability.json
  # -rw-r--r--   1 fangjun  staff   169B Jan  1  2001 oh-uni-package.json
  # drwxr-xr-x   3 fangjun  staff    96B Nov 19 22:42 sysroot
fi

if [ ! -d $OHOS_SDK_NATIVE_DIR ]; then
  echo "Please first download Command Line Tools for HarmonyOS"
  exit 1
fi

export PATH=$OHOS_SDK_NATIVE_DIR/llvm/bin:$PATH

OHOS_TOOLCHAIN_FILE=$OHOS_SDK_NATIVE_DIR/build/cmake/ohos.toolchain.cmake

if [ ! -f $OHOS_TOOLCHAIN_FILE ]; then
  echo "$OHOS_TOOLCHAIN_FILE does not exist"
  echo "Please first download Command Line Tools for HarmonyOS"
  exit 1
fi


sleep 1
onnxruntime_version=1.16.3
onnxruntime_dir=onnxruntime-ohos-armeabi-v7a-$onnxruntime_version

if [ ! -f $onnxruntime_dir/lib/libonnxruntime.so ]; then
  # wget -c https://github.com/csukuangfj/onnxruntime-libs/releases/download/v${onnxruntime_version}/$onnxruntime_dir.zip
  wget -c https://hf-mirror.com/csukuangfj/onnxruntime-libs/resolve/main/$onnxruntime_dir.zip
  unzip $onnxruntime_dir.zip
  rm $onnxruntime_dir.zip
fi

export SHERPA_ONNXRUNTIME_LIB_DIR=$dir/$onnxruntime_dir/lib
export SHERPA_ONNXRUNTIME_INCLUDE_DIR=$dir/$onnxruntime_dir/include

echo "SHERPA_ONNXRUNTIME_LIB_DIR: $SHERPA_ONNXRUNTIME_LIB_DIR"
echo "SHERPA_ONNXRUNTIME_INCLUDE_DIR $SHERPA_ONNXRUNTIME_INCLUDE_DIR"

if [ -z $SHERPA_ONNX_ENABLE_TTS ]; then
  SHERPA_ONNX_ENABLE_TTS=ON
fi

if [ -z $SHERPA_ONNX_ENABLE_SPEAKER_DIARIZATION ]; then
  SHERPA_ONNX_ENABLE_SPEAKER_DIARIZATION=ON
fi

if [ -z $SHERPA_ONNX_ENABLE_BINARY ]; then
  SHERPA_ONNX_ENABLE_BINARY=OFF
fi

# See https://github.com/llvm/llvm-project/issues/57732
# we need to use -mfloat-abi=hard
cmake \
    -DOHOS_ARCH=armeabi-v7a \
    -DCMAKE_CXX_FLAGS="-mfloat-abi=hard" \
    -DCMAKE_C_FLAGS="-mfloat-abi=hard" \
    -DCMAKE_TOOLCHAIN_FILE=$OHOS_TOOLCHAIN_FILE \
    -DSHERPA_ONNX_ENABLE_TTS=$SHERPA_ONNX_ENABLE_TTS \
    -DSHERPA_ONNX_ENABLE_SPEAKER_DIARIZATION=$SHERPA_ONNX_ENABLE_SPEAKER_DIARIZATION \
    -DSHERPA_ONNX_ENABLE_BINARY=$SHERPA_ONNX_ENABLE_BINARY \
    -DBUILD_PIPER_PHONMIZE_EXE=OFF \
    -DBUILD_PIPER_PHONMIZE_TESTS=OFF \
    -DBUILD_ESPEAK_NG_EXE=OFF \
    -DBUILD_ESPEAK_NG_TESTS=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DSHERPA_ONNX_ENABLE_PYTHON=OFF \
    -DSHERPA_ONNX_ENABLE_TESTS=OFF \
    -DSHERPA_ONNX_ENABLE_CHECK=OFF \
    -DSHERPA_ONNX_ENABLE_PORTAUDIO=OFF \
    -DSHERPA_ONNX_ENABLE_JNI=OFF \
    -DSHERPA_ONNX_ENABLE_C_API=ON \
    -DCMAKE_INSTALL_PREFIX=./install \
    ..

# make VERBOSE=1 -j4
make -j2
make install/strip
cp -fv $onnxruntime_dir/lib/libonnxruntime.so install/lib
cp -fv $OHOS_SDK_NATIVE_DIR/llvm/lib/arm-linux-ohos/libc++_shared.so install/lib

rm -rf install/share
rm -rf install/lib/pkgconfig