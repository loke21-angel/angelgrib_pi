#pragma once

#include "ocpn_plugin.h"

#include <wx/string.h>

class angelgrib_pi : public opencpn_plugin_118
{
public:
    explicit angelgrib_pi(void* ppimgr);
    ~angelgrib_pi() override;

    int Init() override;
    bool DeInit() override;

    int GetAPIVersionMajor() override;
    int GetAPIVersionMinor() override;

    int GetPlugInVersionMajor() override;
    int GetPlugInVersionMinor() override;
    int GetPlugInVersionPatch() override;

    wxString GetCommonName() override;
    wxString GetShortDescription() override;
    wxString GetLongDescription() override;

    void OnToolbarToolCallback(int id) override;

private:
    int m_toolbar_item_id = -1;

    bool DownloadAndOpenGrib();
    bool DownloadFile(const wxString& url, const wxString& output_file);
    wxString GetOutputFilePath() const;
};
