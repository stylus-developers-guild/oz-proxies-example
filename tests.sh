#!/bin/sh -e

make -B

arbos-forge test $@
