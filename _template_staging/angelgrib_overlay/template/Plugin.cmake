# AngelGRIB Plugin.cmake draft
#
# This is a draft adapter for a real OpenCPN plugin-template repo.
# Do not use this standalone.
#
# After importing a real template, merge these settings into the template's expected Plugin.cmake/CMakeLists structure.

set(PKG_NAME angelgrib_pi)
set(PKG_VERSION 0.1.0)
set(PKG_PRERELEASE beta)

set(PKG_SUMMARY "Download NOAA GFS GRIB files and open them in OpenCPN GRIB plugin")
set(PKG_DESCRIPTION "AngelGRIB adds a toolbar button to download a small NOAA GFS GRIB2 file and pass it to OpenCPN's built-in GRIB Weather plugin.")
set(PKG_AUTHOR "Rasmus Jessen")
set(PKG_LICENSE "GPL-3.0-or-later")

set(SRC
  src/angelgrib_pi.cpp
  src/grib_url_builder.cpp
)

set(HDR
  include/angelgrib_pi.h
  include/grib_url_builder.h
)
