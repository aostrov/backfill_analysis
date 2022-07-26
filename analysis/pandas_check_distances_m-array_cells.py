import xml.etree.ElementTree as ET
import pandas as pd
import pathlib as pl
import re
import numpy as np
import plotnine

xml_path_home = pl.Path("E:/Joao/mauthner_backfills/pcp4a/reformatted.6dpf-pcp4a-v2/")
csv_path = pl.Path(r"E:\Joao\mauthner_backfills\pcp4a\analysis\distances.csv")
xmls = [xml for xml in list(xml_path_home.iterdir()) if ".xml" in str(xml)]
regex_animal = re.compile(r'_E[0-9]+_')
regex_channel = re.compile(r'_0[0-9]_')
animals = []
channels = []
marker_type = []
marker_x = []
marker_y = []
marker_z = []

for xml in xmls:
  tree = ET.parse(xml)
  root = tree.getroot()
  markers = root.findall('./Marker_Data/Marker_Type')
  raw_animal = regex_animal.search(xml.name)
  animal= xml.name[raw_animal.start(0)+1:raw_animal.end(0)-1]
  raw_channel = regex_channel.search(xml.name)
  channel = xml.name[raw_channel.start(0)+1:raw_channel.end(0)-1]
  for marker in root.findall('./Marker_Data/Marker_Type'):
    m_type = marker.find('Type').text
    # print(m_type)
    if marker.find('Marker'):
      # print('yay')
      marker_type.append(m_type)
      animals.append(animal)
      channels.append(channel)
      m_x = marker.find('Marker/MarkerX').text
      m_y = marker.find('Marker/MarkerY').text
      m_z = marker.find('Marker/MarkerZ').text
      marker_x.append(m_x)
      marker_y.append(m_y)
      marker_z.append(m_z)

df = pd.DataFrame(data = {"animal":animals,"channel": channels,"type": marker_type,"x": marker_x, "y": marker_y, "z": marker_z})

df.to_csv(csv_path)

animals_unique = np.unique(animals)
animals_dist = []
type_dist = []
dist_dist = []

for an in animals_unique:
  temp_df = df.loc[df['animal'] == an]
  df_01 = temp_df.loc[temp_df['channel']=='01']
  df_02 = temp_df.loc[temp_df['channel']=='02']
  for i in range(len(df_02)):
    t2,x2,y2,z2 = df_02.iloc[i,[2,3,4,5]]
    x1,y1,z1 = df_01.loc[df_01['type'] == t2,['x','y','z']].iloc[0,[0,1,2]]
    a=np.array((int(x2),int(y2),int(z2)))
    b=np.array((int(x1),int(y1),int(z1)))
    dist = np.linalg.norm(a-b)
    animals_dist.append(an)
    type_dist.append(t2)
    dist_dist.append(dist)

dist_df = pd.DataFrame(data = {'animal': animals_dist, 'type':type_dist,'distance':dist_dist})

