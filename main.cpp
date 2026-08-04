// main.cpp
// ---------------------------------------------------------------------------
// ShelfSight application entry point.  Creates the shared AppContext (opening
// the fixed app database), then the MainFrame, and hands control to wxWidgets.
//
// Usage:  ShelfSight [--db <path>]   (override the app/credentials database)
// ---------------------------------------------------------------------------

#include "gui/app_context.h"
#include "gui/main_frame.h"

#include <wx/wx.h>

#include <string>

namespace {

class ShelfSightApp : public wxApp {
public:
    // wxWidgets entry point, called once at startup.
    bool OnInit() override {
        // Parse the optional --db <path> command-line argument.
        std::string db_path = "shelfsight.db";
        for (int i = 1; i < argc; ++i) {
            if (std::string(argv[i]) == "--db" && i + 1 < argc) {
                db_path = argv[++i];
            }
        }

        // AppContext owns the databases; it lives for the whole session.
        auto* ctx = new shelfsight::AppContext(db_path);
        if (!ctx->init()) {
            wxMessageBox("Failed to open the database.", "ShelfSight",
                         wxOK | wxICON_ERROR);
            return false;
        }
        // Create and show the main window, then enter the event loop.
        auto* frame = new shelfsight::MainFrame(*ctx);
        frame->Show(true);
        return true;
    }
};

} // namespace

wxIMPLEMENT_APP(ShelfSightApp);