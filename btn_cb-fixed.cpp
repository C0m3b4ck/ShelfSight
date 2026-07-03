// Assume you have a global or accessible AppUI pointer named app_ui
// and it contains: Fl_Input* inp_usr_log; Fl_Input* inp_pwd_log; (etc.)

struct AppUI
{
		Fl_Input* inp_usr_log;
}

void BTN_CB(Fl_Widget* w, void* data) {
  std::string function_data = *(std::string*)data;

  std::cout << "BTN_CB called with " << function_data << " as data. \n";

  if (function_data == "login_btn") {
    // ADDED: read login inputs from your AppUI
    std::string usr = (app_ui->inp_usr_log ? app_ui->inp_usr_log->value() : "");
    std::string pwd = (app_ui->inp_pwd_log ? app_ui->inp_pwd_log->value() : "");

    std::cout << "Login button clicked!\n";
    std::cout << "usr=" << usr << "\n";
    std::cout << "pwd=" << pwd << "\n";

    // Pass usr/pwd to your function here
    // login_function(usr, pwd);
  } else {
    std::cerr << "Unknown function data: " << function_data << " - this is a programmer error \n";
  }
}
