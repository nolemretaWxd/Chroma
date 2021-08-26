#!/bin/bash

# pacman -S coreutils base-devel cmake

THREADCOUNT=8
CMAKE_GENERATOR="Unix Makefiles"
CMAKE=cmake
CMAKE_FLAGS=-Wno-dev
CMAKE_BUILD_TYPE=Release
MAKE=make

 FT_TAG=VER-2-11-0
 HB_TAG=2.9.0
SDL_TAG=release-2.0.16

NATIVES_DIR=$(pwd)/.natives
SOURCES_DIR=$NATIVES_DIR/sources
BUILDROOT_DIR=$NATIVES_DIR/buildroot
ARTIFACT_DIR=$NATIVES_DIR/artifacts

HB=harfbuzz
HB_PATH=$SOURCES_DIR/$HB
HB_BUILDROOT=$BUILDROOT_DIR/$HB
HB_ARPATH=$HB_BUILDROOT/libharfbuzz.a
HB_BUILD_TYPE=Release
HB_ARTIFACT=libharfbuzz.a

FT=freetype
FT_PATH=$SOURCES_DIR/$FT
FT_BUILDROOT=$BUILDROOT_DIR/$FT
FT_SOPATH=$FT_BUILDROOT/libfreetype.so.6.18.0
FT_BUILD_TYPE=Release
FT_ARTIFACT=libfreetype.so

SDL=SDL
SDL_PATH=$SOURCES_DIR/$SDL
SDL_BUILDROOT=$BUILDROOT_DIR/$SDL
SDL_SOPATH=$SDL_BUILDROOT/libSDL2-2.0.so.0.16.0
SDL_BUILD_TYPE=Release
SDL_ARTIFACT=libSDL2.so

SDL_gpu=SDL_gpu
SDL_GPU_PATH=$SOURCES_DIR/$SDL_gpu
SDL_GPU_BUILDROOT=$BUILDROOT_DIR/$SDL_gpu
SDL_GPU_SOPATH=$SDL_GPU_BUILDROOT/SDL_gpu/lib/libSDL2_gpu.so
SDL_GPU_BUILD_TYPE=Release
SDL_GPU_ARTIFACT=libSDL2_gpu.so

SDL_sound=SDL_sound
SDL_SOUND_PATH=$SOURCES_DIR/$SDL_sound
SDL_SOUND_BUILDROOT=$BUILDROOT_DIR/$SDL_sound
SDL_SOUND_SOPATH=$SDL_SOUND_BUILDROOT/libSDL2_sound.so.2.0.0
SDL_SOUND_BUILD_TYPE=Release
SDL_SOUND_ARTIFACT=libSDL2_sound.so

SDL_nmix=SDL_nmix
SDL_NMIX_PATH=$SOURCES_DIR/$SDL_nmix
SDL_NMIX_BUILDROOT=$BUILDROOT_DIR/$SDL_nmix
SDL_NMIX_SOPATH=$SDL_NMIX_BUILDROOT/libSDL2_nmix.so.1.1.0
SDL_NMIX_BUILD_TYPE=Release
SDL_NMIX_ARTIFACT=libSDL2_nmix.so

for argument in "$@"
do
  case $argument in
    --clean-artifacts)
        rm -rf $ARTIFACT_DIR
        ;;

    --clean-buildroot)
        rm -rf $BUILDROOT_DIR
        ;;

    --rebuild-nmix)
        rm -rf $BUILDROOT_DIR/$SDL_nmix
        ;;

    --rebuild-sound)
        rm -rf $BUILDROOT_DIR/$SDL_sound
        ;;

    --rebuild-gpu)
        rm -rf $BUILDROOT_DIR/$SDL_gpu
        ;;

    --rebuild-sdl)
        rm -rf $BUILDROOT_DIR/$SDL
        ;;

    --rebuild-ft)
        rm -rf $BUILDROOT_DIR/$FT
        ;;

    --rebuild-hb)
        rm -rf $BUILDROOT_DIR/$HB
        ;;
  esac
done

if [ ! -d "$NATIVES_DIR" ]; then
    mkdir -p $NATIVES_DIR
fi

if [ ! -d "$BUILDROOT_DIR" ]; then
    mkdir -p $BUILDROOT_DIR
fi

if [ ! -d "$ARTIFACT_DIR" ]; then
    mkdir -p $ARTIFACT_DIR
fi;

cd $NATIVES_DIR

git clone https://github.com/harfbuzz/harfbuzz   $HB_PATH
git clone https://github.com/freetype/freetype   $FT_PATH
git clone https://github.com/libsdl-org/SDL      $SDL_PATH
git clone https://github.com/Chroma-2D/SDL-gpu   $SDL_GPU_PATH
git clone https://github.com/Chroma-2D/SDL_sound $SDL_SOUND_PATH
git clone https://github.com/Chroma-2D/SDL_nmix  $SDL_NMIX_PATH 

   cd $HB_PATH && git checkout $HB_TAG                                                \
&& cd $FT_PATH && git checkout $FT_TAG                                                \
&& cd $SDL_PATH && git checkout $SDL_TAG                                              \
                                                                                      \
&& $CMAKE $CMAKE_FLAGS -B $HB_BUILDROOT $HB_PATH -G "$CMAKE_GENERATOR"                \
                    -DCMAKE_BUILD_TYPE=$HB_BUILD_TYPE                                 \
                    -DHB_HAVE_FREETYPE=1                                              \
                    -DHB_BUILD_SUBSET=0                                               \
                    -DFREETYPE_INCLUDE_DIRS=$FT_PATH/include                          \
                     && cd $HB_BUILDROOT && $MAKE -j$THREADCOUNT                      \
                     && mv $HB_ARPATH $ARTIFACT_DIR/$HB_ARTIFACT                      \
                                                                                      \
&& $CMAKE $CMAKE_FLAGS -B $FT_BUILDROOT $FT_PATH -G "$CMAKE_GENERATOR"                \
                    -DCMAKE_BUILD_TYPE=$FT_BUILD_TYPE                                 \
                    -DBUILD_SHARED_LIBS=1                                             \
                    -DFT_REQUIRE_HARFBUZZ=1                                           \
                    -DHARFBUZZ_INCLUDE_DIRS=$HB_PATH/include                          \
                    -DHARFBUZZ_LIBRARY=$ARTIFACT_DIR/$HB_ARTIFACT                     \
                    -DFT_DISABLE_ZLIB=1                                               \
                     && cd $FT_BUILDROOT && $MAKE -j$THREADCOUNT                      \
                     && mv $FT_SOPATH $ARTIFACT_DIR/$FT_ARTIFACT                      \
                                                                                      \
                                                                                      \
&& $CMAKE $CMAKE_FLAGS -B $SDL_BUILDROOT $SDL_PATH -G "$CMAKE_GENERATOR"              \
                    -DCMAKE_BUILD_TYPE=$SDL_BUILD_TYPE                                \
                    -DSDL_STATIC=0                                                    \
                     && cd $SDL_BUILDROOT && $MAKE -j$THREADCOUNT                     \
                     && mv $SDL_SOPATH $ARTIFACT_DIR/$SDL_ARTIFACT                    \
                                                                                      \
&& $CMAKE $CMAKE_FLAGS -B $SDL_GPU_BUILDROOT $SDL_GPU_PATH -G "$CMAKE_GENERATOR"      \
                    -DCMAKE_BUILD_TYPE=$SDL_GPU_BUILD_TYPE                            \
                    -DDISABLE_OPENGL_1_BASE=1                                         \
                    -DDISABLE_OPENGL_1=1                                              \
                    -DDISABLE_OPENGL_2=1                                              \
                    -DBUILD_STATIC=0                                                  \
                    -DBUILD_DEMOS=0                                                   \
                    -DSDL2_INCLUDE_DIR=$SDL_PATH/include                              \
                    -DSDL2_LIBRARY=$ARTIFACT_DIR/$SDL_ARTIFACT                        \
                     && cd $SDL_GPU_BUILDROOT && $MAKE -j$THREADCOUNT                 \
                     && mv $SDL_GPU_SOPATH $ARTIFACT_DIR/$SDL_GPU_ARTIFACT            \
                                                                                      \
&& $CMAKE $CMAKE_FLAGS -B $SDL_SOUND_BUILDROOT $SDL_SOUND_PATH -G "$CMAKE_GENERATOR"  \
                    -DCMAKE_BUILD_TYPE=$SDL_SOUND_BUILD_TYPE                          \
                    -DSDLSOUND_BUILD_STATIC=0                                         \
                    -DSDLSOUND_BUILD_SHARED=1                                         \
                    -DSDLSOUND_BUILD_TEST=0                                           \
                    -DSDL2_INCLUDE_DIRS=$SDL_PATH/include                             \
                    -DSDL2_INCLUDE_DIR=$SDL_PATH/include                              \
                    -DSDL2_LIBRARY=$ARTIFACT_DIR/$SDL_ARTIFACT                        \
                    -DSDL2_LIBRARIES=$ARTIFACT_DIR/$SDL_ARTIFACT                      \
                     && cd $SDL_SOUND_BUILDROOT && $MAKE -j$THREADCOUNT               \
                     && mv $SDL_SOUND_SOPATH $ARTIFACT_DIR/$SDL_SOUND_ARTIFACT        \
                                                                                      \
&& $CMAKE $CMAKE_FLAGS -B $SDL_NMIX_BUILDROOT $SDL_NMIX_PATH -G "$CMAKE_GENERATOR"    \
                    -DCMAKE_BUILD_TYPE=$SDL_NMIX_BUILD_TYPE                           \
                    -DSDL_SOUND_INCLUDE_DIR=$SDL_SOUND_PATH/src                       \
                    -DSDL_SOUND_LIBRARY=$ARTIFACT_DIR/$SDL_SOUND_ARTIFACT             \
                    -DSDL_SOUND_LIBRARIES=$ARTIFACT_DIR/$SDL_SOUND_ARTIFACT           \
                    -DSDL2_INCLUDE_DIR=$SDL_PATH/include                              \
                    -DSDL2_LIBRARY=$ARTIFACT_DIR/$SDL_ARTIFACT                        \
                    -DSDL2_LIBRARIES=$ARTIFACT_DIR/$SDL_ARTIFACT                      \
                     && cd $SDL_NMIX_BUILDROOT && $MAKE -j$THREADCOUNT                \
                     && mv $SDL_NMIX_SOPATH $ARTIFACT_DIR/$SDL_NMIX_ARTIFACT          \
                                                                                      \
&& cd $ARTIFACT_DIR                                                                   \
&& bzip2 *.so                                                                         \
&& chmod 644 *.bz2                                                                    \
&& mv $FT_ARTIFACT.bz2 libfreetype.bz2                                                \
&& mv $SDL_ARTIFACT.bz2 libSDL2.bz2                                                   \
&& mv $SDL_GPU_ARTIFACT.bz2 libSDL2_gpu.bz2                                           \
&& mv $SDL_SOUND_ARTIFACT.bz2 libSDL2_sound.bz2                                       \
&& mv $SDL_NMIX_ARTIFACT.bz2 libSDL2_nmix.bz2

echo "Done. Natives:"
find $ARTIFACT_DIR -name "*.bz2"
