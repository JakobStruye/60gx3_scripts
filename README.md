# 60gx3_scripts

To cross compile the C code:

Clone and build https://github.com/JakobStruye/Mikrotik-researcher-tools

Set the appropriate env vars:
export STAGING_DIR=/Mikrotik-researcher-tools/staging_dir
export TOOLCHAIN_DIR=$STAGING_DIR/toolchain-arm_cortex-a7+neon-vfpv4_gcc-7.4.0_musl_eabi
export LDCFLAGS=$TOOLCHAIN_DIR/usr/lib
export LD_LIBRARY_PATH=$TOOLCHAIN_DIR/usr/lib
export PATH=$TOOLCHAIN_DIR/bin:$PATH

arm-openwrt-linux-gcc -o a.out file.c
