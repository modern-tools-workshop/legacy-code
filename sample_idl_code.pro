FUNCTION realdistance,lat1,lon1,lat2,lon2
;return real earth distance in km
    PI=3.14159265d
    temp=0.0d
    earth_radius=6378.0d ; //km
    ;convert all to radians:
    tmplat1=double(lat1*PI/180.0);
    tmplon1=double(lon1*PI/180.0);
    tmplat2=double(lat2*PI/180.0);
    tmplon2=double(lon2*PI/180.0);

    temp=sin(tmplat1)*sin(tmplat2) + cos(tmplat1)*cos(tmplat2)*cos(tmplon2-tmplon1);
    temp=acos(temp);
    temp=temp*earth_radius;
return, temp;
END

PRO areasearch, lat_viirs, _viirs, rad_viirs, targetlat, targetlon

    ; Searching in quarter degree
    x=where(abs(lat-targetlat) LE 1.0)

    ; calculate the distance between the remaining points
    d=realdistance(lat_viirs(x),lon_viirs(x),targetlat,targetlon);

    ; check if any of the remaining points are within 1km of the 
    ; given point
    xind=where(d LE 1.0); 

    ; The indices of all matches
    x1=x(xind);

    ; Find the max radiance value within the closest points
    mx=max(rad(x1),location); 
    ind= ARRAY_INDICES(rad, x1(location))
    ; Use the location of the maximum pixel to find all neighboring points
    I0=ind(0);
    J0=ind(1);
    offset=1
    i1=I0-offset
    i2=I0+offset
    j1=j0-offset
    j2=j0+offset

    ; Make sure the points are within 
    low=0	   
    height=768
    width=4064

	;make sure it is not on the edge:
	if ((i1 ge low) and (i1 lt height) and (i2 ge low) and (i2 lt height)$
             and (j1 ge low) and (j1 lt width) and (j2 ge low) and (j2 lt width)) then begin

        ;compute the total radiance within a rectangle around the brightest pixel
        radarea=total(rad(i1:i2,j1:j2))

        ;compute the min radiance within a rectangle around the brightest pixel
        minrad=Min(rad(i1:i2,j1:j2)) 
        
        ;compute the min radiance within a rectangle around the brightest pixel
        targetDist=realdistance(lat(I0,J0),lon(I0,J0),targetlat,targetlon);

		print,"Found."
		print, minrad, radarea, targetDist;

    endif
END

PRO mean
    targetlat=57.0;
    targetlon=-78.0;

    geofile = 'data/GDNBO_j01_d20230825_t0700543_e0702188_b29878_c20230825074232550000_oebc_ops.h5'
    radfile = 'data/SVDNB_j01_d20230825_t0700543_e0702188_b29878_c20230825074447069000_oebc_ops.h5'

    fid=h5f_open(geofile);
    lonid=h5d_open(fid,'/All_Data/VIIRS-DNB-GEO_All/Longitude_TC');
    lon_viirs=h5d_read(lonid) &  h5d_close,lonid
    latid=h5d_open(fid,'/All_Data/VIIRS-DNB-GEO_All/Latitude_TC'); 
    lat_viirs=h5d_read(latid) &  h5d_close,latid;
    h5f_close,fid

    ; open radiance fields for file
    fid=h5f_open(radfile);
    radid=h5d_open(fid,'/All_Data/VIIRS-DNB-SDR_All/Radiance');
    rad_viirs=h5d_read(radid) &  h5d_close,radid;
    h5f_close,fid

    areasearch, lat_viirs, lon_viirs, rad_viirs, targetlat, targetlon

END