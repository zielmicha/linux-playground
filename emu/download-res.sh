#!/bin/bash
ROOT=$(dirname $0)/..
. $ROOT/vars.inc

mkdir -p $DATA/res
wget $MIRROR/busybox -O $DATA/res/busybox
wget $MIRROR/bzImage -O $DATA/res/bzImage
