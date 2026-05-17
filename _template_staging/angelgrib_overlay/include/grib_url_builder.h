#pragma once

#include <wx/string.h>

struct AngelGribRequest {
    wxString date_yyyymmdd = "";
    wxString run = "00";
    wxString forecast_hour = "006";

    double leftlon = -8.0;
    double rightlon = 16.0;
    double toplat = 60.0;
    double bottomlat = 50.0;

    bool wind = true;
    bool gust = true;
    bool pressure = true;
    bool precipitation = true;
};

wxString BuildNoaaGfsUrl(const AngelGribRequest& request);
