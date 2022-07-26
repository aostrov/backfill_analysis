import nrrd
import numpy as np
from pathlib import Path
from collections import namedtuple

Dims = namedtuple('dims','x y z')



thresholds = {
   "0-Mcell_6dpf_average_hist-match_5-fish.nrrd" : 14311,
   "L-Mcell_6dpf_average_hist-match_6-fish.nrrd" : 24921,
   "0-Mcell_7dpf_average_hist-match_13-fish.nrrd" : 11580,
   "L-Mcell_7dpf_average_hist-match_8-fish.nrrd" : 10613,
   "2-Mcell_6dpf_average_hist-match_5-fish.nrrd" : 12131,
   "R-Mcell_6dpf_average_hist-match_4-fish.nrrd" : 8998,
   "2-Mcell_7dpf_average_hist-match_9-fish.nrrd" : 12336,
   "R-Mcell_7dpf_average_hist-match_10-fish.nrrd" : 13592
}

dir = Path('/mnt/f/mauthner_backfills/nephma_averages')
outdir = Path('/mnt/f/mauthner_backfills/nefma_averages_colorCoded')

average_images = [x for x in dir.iterdir()]

for avg_img in average_images:
   data, header = nrrd.read(avg_img)
   dims = Dims(*list(data.shape))
   y = np.zeros(data.shape)
   z_slices = dims.z
   for z_slice in range(0,z_slices):
      print(z_slice)
      y[:,:,z_slice] = z_slices - z_slice
      y[:,:,z_slice] = y[:,:,z_slice] * (data[:,:,z_slice] > thresholds[avg_img.name])
   #write nrrd here.
   outfile = outdir.joinpath(avg_img.name)
   # print(outfile)
   nrrd.write(str(outfile),y)
