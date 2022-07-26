#!/bin/bash

"/opt/local/bin/munger" \
-b "/opt/local/bin/" \
-a -r 0102 \
-l a \
-d .6dpf-pcp4a-v2 \
-X 26 -C 8 -G 120 -R 3 \
-A "--sampling 2 --accuracy 4 --omit-original-data" \
-T 3 \
-s "refbrain/6dpfv2w.nrrd" \
images

