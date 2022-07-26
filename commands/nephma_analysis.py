#!/bin/python3

import pandas as pd
import nrrd
import numpy as np
from pathlib import Path

rhombomere_mask_6dpf = nrrd.read("/Volumes/TranscendJD/mauthner/masks/6dpf04.labels.nrrd")[0]
axon_mask_6dpf = nrrd.read("/Volumes/TranscendJD/mauthner/masks/6dpf04.axons.nrrd")[0]
rhombomere_mask_7dpf = nrrd.read("/Volumes/TranscendJD/mauthner/masks/7dpf03.labels.nrrd")[0]
axon_mask_7dpf = nrrd.read("/Volumes/TranscendJD/mauthner/masks/7dpf03.axons.nrrd")[0]
neuropil_mask_6dpf = nrrd.read("/Volumes/TranscendJD/mauthner/masks/6dpf_neuropil.labels.nrrd")[0]
neuropil_mask_7dpf = nrrd.read("/Volumes/TranscendJD/mauthner/masks/7dpf_neuropil.labels.nrrd")[0]

mauthner_mask_6dpf = nrrd.read("/mnt/f/mauthner_backfills/6dpf_mauthner-isolated.labels.nrrd")[0]
mauthner_mask_7dpf = nrrd.read("/mnt/f/mauthner_backfills/7dpf_mauthner-isolated.labels.nrrd")[0]

columns = ['animal', 'age', 'genotype' , 'mauthner_status', 'nucMLF', 'rh1', 'rh2', 'rh3', 'rh4', 'rh5', 'rh6']
columns = ['animal', 'age', 'genotype' , 'mauthner_status', 'left_Mcell', 'right_Mcell']
df = pd.DataFrame(columns=columns)
# access to df can be done with df.loc[row,column], where column can be indexed via column name
# and row can seemingly be indexed by row number or row name if that is set to something particular

# file access and string parsing
## laptop
wt_binaries_path = Path("/Volumes/TranscendJD/mauthner/wt_binaries/")
nefma_binaries_path = Path("/Volumes/TranscendJD/mauthner/nephma-binaries")
## pc
wt_binaries_path = Path("/mnt/f/mauthner_backfills/wt/wt_binaries/")
nefma_binaries_path = Path("/mnt/f/mauthner_backfills/nephma-binaries/")

wt_binaries = [x for x in wt_binaries_path.iterdir()]
nefma_binaries = [x for x in nefma_binaries_path.iterdir()]
binaries_list = [wt_binaries,nefma_binaries]
for geno in binaries_list:
    for image in geno:
        print(image)
        
        age = image.name.split('_')[0][0:4]
        
        rh_mask = rhombomere_mask_6dpf if (age == "6dpf") else rhombomere_mask_7dpf
        ax_mask = axon_mask_6dpf if (age == "6dpf") else axon_mask_7dpf
        np_mask = neuropil_mask_6dpf if (age == "6dpf") else neuropil_mask_7dpf
        rh_mask = rh_mask * (ax_mask == 0) * (np_mask == 0)
        
        animal = image.name.split('_')[1]
        geno = image.name.split('_')[2]
        mauthner_status = "2" if (geno == 'wt') else image.name.split('_')[4][0]
        masks_list = []
        sample_binary = nrrd.read(image)[0]
        for mask in range(1,8):
            print(mask)
            i_mask = rh_mask == mask
            masks_list.append(np.count_nonzero(sample_binary * i_mask))
        
        local_dict = {
        'animal' : animal,
        'age' : age,
        'genotype' : geno,
        'mauthner_status' : mauthner_status,
        'nucMLF' : masks_list[0],
        'rh1' : masks_list[1],
        'rh2' : masks_list[2],
        'rh3' : masks_list[3],
        'rh4' : masks_list[4],
        'rh5' : masks_list[5],
        'rh6' : masks_list[6]
        }
        
        df = df.append(local_dict, ignore_index=True)

df = pd.DataFrame(columns=columns)
for geno in binaries_list:
    for image in geno:
        print(image)
        age = image.name.split('_')[0][0:4]
        m_masks = mauthner_mask_6dpf if (age == "6dpf") else mauthner_mask_7dpf
        animal = image.name.split('_')[1]
        geno = image.name.split('_')[2]
        mauthner_status = "2" if (geno == 'wt') else image.name.split('_')[4][0]
        masks_list = []
        sample_binary = nrrd.read(image)[0]
        for mask in range(1,3):
            print(mask)
            i_mask = m_masks == mask
            masks_list.append(np.count_nonzero(sample_binary * i_mask))
        local_dict = {
        'animal' : animal,
        'age' : age,
        'genotype' : geno,
        'mauthner_status' : mauthner_status,
        'left_Mcell' : masks_list[0],
        'right_Mcell' : masks_list[1]
        }
        df = df.append(local_dict, ignore_index=True)



wt_mean_rh4 = np.mean(df.loc[(df.loc[:,'age']=='6dpf') & (df.loc[:,'genotype']=="wt"),'rh4'])
wt_std_rh4 = np.std(df.loc[(df.loc[:,'age']=='6dpf') & (df.loc[:,'genotype']=="wt"),'rh4'])
