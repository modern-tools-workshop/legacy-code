import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon
import cartopy.crs as ccrs
import matplotlib.patches as mpatches
import matplotlib.ticker as mticker
from cartopy.mpl.gridliner import LONGITUDE_FORMATTER, LATITUDE_FORMATTER
import h5py
import time
plt.rcParams.update({'font.size': 16})


# Sample file path/names:
geofile = 'data/GDNBO_j01_d20230825_t0700543_e0702188_b29878_c20230825074232550000_oebc_ops.h5'
radfile = 'data/SVDNB_j01_d20230825_t0700543_e0702188_b29878_c20230825074447069000_oebc_ops.h5'

# Open the sample geo file, extract the lat, lon coordinates
# Note: Scaling the grid by 100 to save processing time, for demo purposes only
fid = h5py.File(geofile, 'r')
lon_viirs = fid['/All_Data/VIIRS-DNB-GEO_All/Longitude_TC'][:,:]
lat_viirs = fid['/All_Data/VIIRS-DNB-GEO_All/Latitude_TC'][:,:]

# Open the sample radiance file, extract the lat, lon coordinates
fid_rad = h5py.File(radfile, 'r')
rad_viirs = fid_rad['/All_Data/VIIRS-DNB-SDR_All/Radiance'][:,:]

# Sample point
targetlat = 53.0
targetlon = -78.0

# Create a map using PlateCarree projection 
fig = plt.figure(figsize=[8,6])
ax = plt.axes(projection=ccrs.PlateCarree())

xx = lon_viirs.flatten()
yy = lat_viirs.flatten()

# VIIRS
xx = lon_viirs.flatten()
yy = lat_viirs.flatten()
zz = rad_viirs.flatten()
tmp_rad = ax.scatter(xx[::1000], yy[::1000], c=zz[::1000], transform=ccrs.PlateCarree(), s=0.5)
# plt.colorbar(tmp_rad)

# Search point
ax.scatter(-71.55289, 51.44279, color='red', label='Search Point', transform=ccrs.PlateCarree())

# Set map features
ax.set_extent([-100, 0, 40, 65], ccrs.PlateCarree())  # Adjust the extent for Canada

ax.coastlines()
ax.gridlines()

# Add gridlines with lat/lon labels
gl = ax.gridlines(draw_labels=True, linestyle='--', color='gray')
gl.xformatter = LONGITUDE_FORMATTER
gl.yformatter = LATITUDE_FORMATTER
gl.xlabels_top = False
gl.ylabels_right = False

ax.set_aspect('equal', adjustable='datalim')
ax.legend(loc='upper right', borderaxespad=1)

ax.set_title("VIIRS DNB Aug 25, 2023 07:00:54 UTC")

plt.savefig('test_data.png')
plt.close()