#include "angel_cpn_weather_pi.h"
#include "weather_url_builder.h"

#include <memory>
#include <wx/filefn.h>
#include <wx/filename.h>
#include <wx/msgdlg.h>
#include <wx/url.h>
#include <wx/wfstream.h>

extern "C" DECL_EXP opencpn_plugin* create_pi(void* ppimgr)
{
    return new angel_cpn_weather_pi(ppimgr);
}

extern "C" DECL_EXP void destroy_pi(opencpn_plugin* p)
{
    delete p;
}

angel_cpn_weather_pi::angel_cpn_weather_pi(void* ppimgr)
    : opencpn_plugin_118(ppimgr)
{
}

angel_cpn_weather_pi::~angel_cpn_weather_pi() = default;

int angel_cpn_weather_pi::Init()
{
    AddLocaleCatalog("opencpn-angel_cpn_weather_pi");

    wxString icon_svg = GetPluginDataDir("angel_cpn_weather_pi")
        + wxFileName::GetPathSeparator()
        + "angel_cpn_weather.svg";

    m_toolbar_item_id = InsertPlugInToolSVG(
        "Angel CPN Weather",
        icon_svg,
        icon_svg,
        icon_svg,
        wxITEM_NORMAL,
        "Download Weather",
        "Download NOAA GFS weather GRIB and open it in the GRIB plugin",
        nullptr,
        -1,
        0,
        this
    );

    return WANTS_TOOLBAR_CALLBACK;
}

bool angel_cpn_weather_pi::DeInit()
{
    if (m_toolbar_item_id >= 0) {
        RemovePlugInTool(m_toolbar_item_id);
        m_toolbar_item_id = -1;
    }
    return true;
}

int angel_cpn_weather_pi::GetAPIVersionMajor() { return 1; }
int angel_cpn_weather_pi::GetAPIVersionMinor() { return 18; }
int angel_cpn_weather_pi::GetPlugInVersionMajor() { return 0; }
int angel_cpn_weather_pi::GetPlugInVersionMinor() { return 1; }
int angel_cpn_weather_pi::GetPlugInVersionPatch() { return 0; }

wxString angel_cpn_weather_pi::GetCommonName() { return "Angel CPN Weather"; }
wxString angel_cpn_weather_pi::GetShortDescription() { return "Download NOAA GFS weather GRIB files"; }
wxString angel_cpn_weather_pi::GetLongDescription()
{
    return "Angel CPN Weather downloads a small NOAA GFS GRIB2 file and opens it in OpenCPN's GRIB Weather plugin.";
}

void angel_cpn_weather_pi::OnToolbarToolCallback(int id)
{
    wxUnusedVar(id);
    if (!DownloadAndOpenGrib()) {
        wxMessageBox(
            "Could not download or open the weather GRIB file. Check your internet connection and make sure the GRIB Weather plugin is enabled.",
            "Angel CPN Weather",
            wxOK | wxICON_WARNING
        );
    }
}

wxString angel_cpn_weather_pi::GetOutputFilePath() const
{
    wxString base = *GetpPrivateApplicationDataLocation();
    wxString dir = base + wxFileName::GetPathSeparator() + "angel_cpn_weather";
    if (!wxDirExists(dir)) {
        wxMkdir(dir);
    }
    return dir + wxFileName::GetPathSeparator() + "angel_weather_latest.grb2";
}

bool angel_cpn_weather_pi::DownloadAndOpenGrib()
{
    AngelWeatherRequest request;
    wxString url = BuildNoaaGfsUrl(request);
    wxString output = GetOutputFilePath();

    if (!DownloadFile(url, output)) {
        return false;
    }

    if (!wxFileExists(output) || wxFileName(output).GetSize().GetValue() <= 0) {
        return false;
    }

    wxString jsonPath = output;
    jsonPath.Replace("\\", "/");

    wxString json;
    json.Printf("{\"grib_file\":\"%s\"}", jsonPath);

    SendPluginMessage("GRIB_APPLY_JSON_CONFIG", json);
    return true;
}

bool angel_cpn_weather_pi::DownloadFile(const wxString& url, const wxString& output_file)
{
    wxURL downloader(url);
    if (downloader.GetError() != wxURL_NOERR) {
        return false;
    }

    std::unique_ptr<wxInputStream> input(downloader.GetInputStream());
    if (!input || !input->IsOk()) {
        return false;
    }

    wxFileOutputStream output(output_file);
    if (!output.IsOk()) {
        return false;
    }

    output.Write(*input);
    return output.IsOk();
}
