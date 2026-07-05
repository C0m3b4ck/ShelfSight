#include "shelfsight_gui.h"

int main(int argc, char** argv) {
    Fl::args(argc, argv);              // optional but fine
    Fl_Double_Window* w = make_window();
    if (!w) return 1;
    w->show();
    return Fl::run();
}
