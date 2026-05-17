param(
    [string]$Run = "00",
    [string]$ForecastHour = "006",
    [double]$LeftLon = -8,
    [double]$RightLon = 16,
    [double]$TopLat = 60,
    [double]$BottomLat = 50
)

$ErrorActionPreference = "Stop"

$date = (Get-Date).ToUniversalTime().ToString("yyyyMMdd")

$url = "https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl" +
       "?file=gfs.t${Run}z.pgrb2.0p25.f${ForecastHour}" +
       "&lev_10_m_above_ground=on" +
       "&lev_surface=on" +
       "&lev_mean_sea_level=on" +
       "&var_UGRD=on" +
       "&var_VGRD=on" +
       "&var_GUST=on" +
       "&var_PRMSL=on" +
       "&var_APCP=on" +
       "&subregion=" +
       "&leftlon=$LeftLon" +
       "&rightlon=$RightLon" +
       "&toplat=$TopLat" +
       "&bottomlat=$BottomLat" +
       "&dir=%2Fgfs.$date%2F$Run%2Fatmos"

$outDir = Join-Path $PSScriptRoot "out"
New-Item -ItemType Directory -Force $outDir | Out-Null

$outFile = Join-Path $outDir "angel_gfs_latest.grb2"

Write-Host "Downloading:"
Write-Host $url
Write-Host "To: $outFile"

Invoke-WebRequest -Uri $url -OutFile $outFile

$size = (Get-Item $outFile).Length
Write-Host "Downloaded $size bytes"

if ($size -le 0) {
    throw "Downloaded file is empty"
}
