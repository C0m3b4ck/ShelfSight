// for quick GUI development, FLUID 1.3.11 will be used
// to update the GUI, you need to regenerate code from FLUID
// this, however, removes manually-added code
// this is where manually-added code will be saved as to avoid being removed by FLUID
#include "cred_man.h"

// Button callback function
void BTN_CB(Fl_Widget* w, void* data) {
    // Cast the user data to the appropriate type (in this case, int)
    std::string function_data = *(std::string*)data;

    // debug
    std::cout << "BTN_CB called with " << function_data << " as data. \n";
    if (function_data == "login_btn")
    {
        std::cout << "Login button clicked! \n";
        //std::string usr = username_input->value(); // -> here, username_input would be the fl_input name
        //std::string pwd = password_input->value();


    }
    else { //incorrect function id
            std::cerr << "Unknown function data: " << function_data << " - this is a programmer error \n";
    }
}
