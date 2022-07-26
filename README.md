# backfill_analysis

Convert .czi files to 2 single channel .nrrd files, rotating them as necessary to match the template, using rotate_and_split_pcp4a_czi.ijm

User munger_pcp4a_6dpf_affine.sh to affine register these images to the template.

The template included in the repo is a 4x4 downsampled version of the template that can be used for image registration.
If you desire the full sized template, you can download it from:

https://drive.google.com/file/d/1fXOOllrv7ou_v3jA2Ukih4SVO-M7CFBJ/view?usp=sharing

All code in the analysis folder is there for informative purposes and please don't laugh at my code!