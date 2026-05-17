#include "angelgrib_pi.h"
#include "grib_url_builder.h"

#include <memory>

#include <wx/filefn.h>
#include <wx/filename.h>
#include <wx/msgdlg.h>
#include <wx/sstream.h>
#include <wx/url.h>
#include <wx/wfstream.h>

extern "C" DECL_EXP opencpn_plugin* create_pi(void* ppimgr)
{
    return new angelgrib_pi(ppimgr);
}

extern "C" DECL_EXP void destroy_pi(opencpn_plugin* p)
{
    delete p;
}

angelgrib_pi::angelgrib_pi(void* ppimgr)
    : opencpn_plugin_118(ppimgr)
{
}

angelgrib_pi::~angelgrib_pi() = default;

int angelgrib_pi::Init()
{
    AddLocaleCatalog("opencpn-angelgrib_pi");

    wxString icon_svg = GetPluginDataDir("angelgrib_pi")
        + wxFileName::GetPathSeparator()
        + "angelgrib.svg";

    m_toolbar_item_id = InsertPlugInToolSVG(
        "AngelGRIB",
        icon_svg,
        icon_svg,
        icon_svg,
        wxITEM_NORMAL,
        "Download GRIB",
        "Download NOAA GFS GRIB and open in GRIB plugin",
        nullptr,
        -1,
        0,
        this
    );

    return WANTS_TOOLBAR_CALLBACK;
}

bool angelgrib_pi::DeInit()
{
    if (m_toolbar_item_id >= 0) {
        RemovePlugInTool(m_toolbar_item_id);
        m_toolbar_item_id = -1;
    }

    return true;
}

int angelgrib_pi::GetAPIVersionMajor() { return 1; }
int angelgrib_pi::GetAPIVersionMinor() { return 18; }

int angelgrib_pi::GetPlugInVersionMajor() { return 0; }
int angelgrib_pi::GetPlugInVersionMinor() { return 1; }
int angelgrib_pi::GetPlugInVersionPatch() { return 0; }

wxString angelgrib_pi::GetCommonName() { return "AngelGRIB"; }

wxString angelgrib_pi::GetShortDescription()
{
    return "Download NOAA GFS GRIB files";
}

wxString angelgrib_pi::GetLongDescription()
{
    return "AngelGRIB downloads a small NOAA GFS GRIB2 file and opens it in OpenCPN's GRIB Weather plugin.";
}

void angelgrib_pi::OnToolbarToolCallback(int id)
{
    wxUnusedVar(id);

    if (!DownloadAndOpenGrib()) {
        wxMessageBox(
            "Could not download or open the GRIB file. Check your internet connection and make sure the GRIB Weather plugin is enabled.",
            "AngelGRIB",
            wxOK | wxICON_WARNING
        );
    }
}

wxString angelgrib_pi::GetOutputFilePath() const
{
    wxString base = *GetpPrivateApplicationDataLocation();
    wxString dir = base + wxFileName::GetPathSeparator() + "angelgrib";

    if (!wxDirExists(dir)) {
        wxMkdir(dir);
    }

    return dir + wxFileName::GetPathSeparator() + "angel_gfs_latest.grb2";
}

bool angelgrib_pi::DownloadAndOpenGrib()
{
    AngelGribRequest request;
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

bool angelgrib_pi::DownloadFile(const wxString& url, const wxString& output_file)
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
