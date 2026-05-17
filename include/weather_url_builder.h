#pragma once
#include <wx/string.h>

struct AngelWeatherRequest {
    wxString date_yyyymmdd;
    wxString run = "00";
    wxString forecast_hour = "006";
    double leftlon = -8.0;
    double rightlon = 16.0;
    double toplat = 60.0;
    double bottomlat = 50.0;
};

wxString BuildNoaaGfsUrl(const AngelWeatherRequest& request);
