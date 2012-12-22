MASTER_SSH_PORT=5600
MIRROR=http://user.zielm.com/playground-mirror

ROOT=$(readlink -f $ROOT)

if [ -e $ROOT/locals.inc ]; then
   . $ROOT/locals.inc
fi

DATA=$(readlink -f $DATA)

maketmp() {
   echo $DATA/tmp_$RANDOM
}

mkdir -p $DATA/tmp
mkdir -p $DATA/gen
mkdir -p $DATA/shared
