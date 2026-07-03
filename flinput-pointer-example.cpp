Fl_Input* username_input;
Fl_Input* password_input;
Fl_Input* password_again_input;

Fl_Double_Window* make_window() {
  Fl_Double_Window* w;
  { Fl_Double_Window* o = new Fl_Double_Window(542, 378, "ShelfSeeker");
    w = o;

    { Fl_Input* o = username_input = new Fl_Input(105, 75, 420, 30, "Username");
      o->labelsize(19);
    }

    { Fl_Input* o = password_input = new Fl_Input(105, 115, 420, 30, "Password");
      o->labelsize(19);
    }

    { Fl_Input* o = password_again_input = new Fl_Input(110, 155, 415, 30, "Password again");
      o->labelsize(19);
    }

    { Fl_Button* o = new Fl_Button(375, 290, 155, 75, "Register");
      o->callback([](Fl_Widget*, void*) {
        printf("Username: %s\n", username_input->value());
        printf("Password: %s\n", password_input->value());
        printf("Again: %s\n", password_again_input->value());
      });
    }

    o->end();
  }
  return w;
}
