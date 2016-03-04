# Compilation of PostgreSQL, GEOS, Proj4, GDAL, CGAL, SFCGAL, and PostGIS 2

# Locale
locale-gen ${LANG}

# Update and apt-get basic packages
apt-get update && apt-get install -y build-essential python python-dev libreadline6-dev zlib1g-dev libssl-dev libxml2-dev libxslt-dev curl cmake libgmp-dev libmpfr-dev libboost-dev libboost-thread-dev libboost-system-dev


# Grab gosu
gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4

curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" > /dev/null 2>&1 && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" > /dev/null 2>&1 && gpg --verify /usr/local/bin/gosu.asc  > /dev/null 2>&1 && rm /usr/local/bin/gosu.asc  > /dev/null 2>&1 && chmod +x /usr/local/bin/gosu  > /dev/null 2>&1


# Untar
cd src ; tar -xjvf postgresql-${PG_VERSION}.tar.bz2 ; cd ..
cd src ; tar -xjvf geos-${GEOS_VERSION}.tar.bz2 ; cd ..
cd src ; tar -xvf proj-${PROJ4_VERSION}.tar.gz ; cd ..
cd src ; mkdir -p proj-datumgrid ; cd ..
cd src ; tar -xvf proj-datumgrid-1.5.tar.gz -C proj-datumgrid ; cd ..
cd src ; tar -xvf postgis-${POSTGIS_VERSION}.tar.gz ; cd ..
cd src ; tar -xvf gdal-${GDAL_VERSION}.tar.gz ; cd ..
cd src ; tar -xvf CGAL-${CGAL_VERSION}.tar.gz ; cd ..
cd src ; tar -xzvf SFCGAL-${SFCGAL_VERSION}.tar.gz ; cd ..


# Compilation of PostgreSQL
cd src/postgresql-${PG_VERSION} ; ./configure --prefix=/usr/local --with-pgport=5432 --with-python --with-openssl --with-libxml --with-libxslt --with-zlib ; cd ../..

cd src/postgresql-${PG_VERSION} ; make ; cd ../..

cd src/postgresql-${PG_VERSION} ; make install ; cd ../..

cd src/postgresql-${PG_VERSION}/contrib ; make all ; cd ../../..

cd src/postgresql-${PG_VERSION}/contrib ; make install ; cd ../../..

groupadd postgres

useradd -r postgres -g postgres

ldconfig



# Compilation of GEOS
cd src/geos-${GEOS_VERSION} ; ./configure ; cd ../..

cd src/geos-${GEOS_VERSION} ; make ; cd ../..

cd src/geos-${GEOS_VERSION} ; make install ; cd ../..

ldconfig


# Compilation of Proj 4
mv src/proj-datumgrid/* src/proj-${PROJ4_VERSION}/nad

mv src/pj_datums.c src/proj-${PROJ4_VERSION}/src

mv src/epsg src/proj-${PROJ4_VERSION}/nad/

mv src/PENR2009.gsb src/proj-${PROJ4_VERSION}/nad/

cd src/proj-${PROJ4_VERSION} ; ./configure ; cd ../..

cd src/proj-${PROJ4_VERSION} ; make ; cd ../..

cd src/proj-${PROJ4_VERSION} ; make install ; cd ../..

ldconfig


# Compilation of GDAL
cd src/gdal-${GDAL_VERSION} ; ./configure ; cd ../..

cd src/gdal-${GDAL_VERSION} ; make ; cd ../..

cd src/gdal-${GDAL_VERSION} ; make install ; cd ../..

mv src/epsg.wkt /usr/local/share/gdal

mv src/gcs.csv /usr/local/share/gdal

ldconfig


# Compilation of CGAL
cd src/cgal-releases-CGAL-${CGAL_VERSION} ; cmake -DWITH_CGAL_Core=ON -DWITH_CGAL_ImageIO=OFF -DWITH_CGAL_Qt3=OFF -DWITH_tests=OFF -DWITH_examples=OFF -DWITH_demos=OFF -DCMAKE_BUILD_TYPE=Release . ; cd ../..

cd src/cgal-releases-CGAL-${CGAL_VERSION} ; make ; cd ../..

cd src/cgal-releases-CGAL-${CGAL_VERSION} ; make install ; cd ../..

ldconfig


# Compilation of SFCGAL
cd src/SFCGAL-${SFCGAL_VERSION} ; cmake . ; cd ../..

cd src/SFCGAL-${SFCGAL_VERSION} ; make ; cd ../..

cd src/SFCGAL-${SFCGAL_VERSION} ; make install ; cd ../..

ldconfig


# Compilation of PostGIS
mv src/spatial_ref_sys.sql src/postgis-${POSTGIS_VERSION}/

cd src/postgis-${POSTGIS_VERSION} ; ./configure --with-topology --with-sfcgal --with-raster ; cd ../..

cd src/postgis-${POSTGIS_VERSION} ; make ; cd ../..

cd src/postgis-${POSTGIS_VERSION} ; make install ; cd ../..

ldconfig


# Clean up
rm -Rf /usr/local/src

chmod 755 /usr/local/bin/run.sh

chown postgres:postgres /usr/local/bin/run.sh

chmod 755 /usr/local/bin/make_backups

chown postgres:postgres /usr/local/bin/make_backups

chmod -R 644 /usr/local/share/gdal
