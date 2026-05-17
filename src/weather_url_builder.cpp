#include "weather_url_builder.h"
#include <wx/datetime.h>

static wxString TodayUtcYyyyMmDd()
{
    return wxDateTime::Now().ToUTC().Format("%Y%m%d");
}

wxString BuildNoaaGfsUrl(const AngelWeatherRequest& request)
{
    wxString date = request.date_yyyymmdd;
    if (date.IsEmpty()) {
        date = TodayUtcYyyyMmDd();
    }

    wxString url;
    url.Printf(
        "https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl?"
        "file=gfs.t%sz.pgrb2.0p25.f%s"
        "&lev_10_m_above_ground=on"
        "&lev_surface=on"
        "&lev_mean_sea_level=on"
        "&var_UGRD=on"
        "&var_VGRD=on"
        "&var_GUST=on"
        "&var_PRMSL=on"
        "&var_APCP=on"
        "&subregion="
        "&leftlon=%.2f"
        "&rightlon=%.2f"
        "&toplat=%.2f"
        "&bottomlat=%.2f"
        "&dir=%%2Fgfs.%s%%2F%s%%2Fatmos",
        request.run,
        request.forecast_hour,
        request.leftlon,
        request.rightlon,
        request.toplat,
        request.bottomlat,
        date,
        request.run
    );
    return url;
}
