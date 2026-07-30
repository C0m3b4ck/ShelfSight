#include "gui_imgui.h"
#include "imgui/imgui.h"
#include "imgui/imgui_impl_glfw.h"
#include "imgui/imgui_impl_opengl2.h"
#include "file_man.h"
#include "glob_vars.h"

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>
#include <vector>
#include <fstream>
#include <sstream>
#include <algorithm>
#include <GLFW/glfw3.h>

static GLFWwindow* g_window = 0;
static GuiView g_current_view = VIEW_LOGIN;
static char g_inp_buf[1024];
static char g_inp_buf2[1024];
static char g_inp_buf3[1024];
static char g_inp_buf4[1024];
static char g_msg[512];
static double g_msg_timer;
static int g_selected_cat = 0;
static int g_selected_status = 0;
static int g_book_id = 0;
static int g_loan_id = 0;

static const char* status_list[] = { "Available", "Checked Out", "Reserved", "Damaged", "Lost" };

static void set_msg(const char* m)
{
    strncpy(g_msg, m, sizeof(g_msg) - 1);
    g_msg[sizeof(g_msg) - 1] = 0;
    g_msg_timer = ImGui::GetTime();
}

static void show_msg()
{
    if (g_msg[0] && ImGui::GetTime() - g_msg_timer < 3.0)
        ImGui::TextColored(ImVec4(0,1,0,1), "%s", g_msg);
}

static void menu_bar()
{
    if (ImGui::BeginMenuBar())
    {
        if (ImGui::BeginMenu("Books"))
        {
            if (ImGui::MenuItem("Add Book"))          g_current_view = VIEW_ADD_BOOKS;
            if (ImGui::MenuItem("Edit Book"))         g_current_view = VIEW_EDIT_BOOKS;
            if (ImGui::MenuItem("Delete Book"))       g_current_view = VIEW_DELETE_BOOKS;
            if (ImGui::MenuItem("Manage Categories")) g_current_view = VIEW_MANAGE_CATEGORIES;
            ImGui::EndMenu();
        }
        if (ImGui::BeginMenu("Readers"))
        {
            if (ImGui::MenuItem("Add Reader"))        g_current_view = VIEW_ADD_READERS;
            if (ImGui::MenuItem("Edit Reader"))       g_current_view = VIEW_EDIT_READERS;
            if (ImGui::MenuItem("Delete Reader"))     g_current_view = VIEW_DELETE_READERS;
            if (ImGui::MenuItem("Import Readers"))    g_current_view = VIEW_IMPORT_READERS;
            ImGui::EndMenu();
        }
        if (ImGui::BeginMenu("Loans"))
        {
            if (ImGui::MenuItem("Add Loan"))          g_current_view = VIEW_ADD_LOANS;
            if (ImGui::MenuItem("Return Loan"))       g_current_view = VIEW_RETURN_LOANS;
            if (ImGui::MenuItem("List Loans"))        g_current_view = VIEW_LIST_LOANS;
            if (ImGui::MenuItem("Edit Loan"))         g_current_view = VIEW_EDIT_LOANS;
            if (ImGui::MenuItem("Remove Loan"))       g_current_view = VIEW_REMOVE_LOANS;
            if (ImGui::MenuItem("Mark Lost"))         g_current_view = VIEW_MARK_LOST;
            if (ImGui::MenuItem("Prolong"))           g_current_view = VIEW_PROLONG;
            if (ImGui::MenuItem("Expired Loans"))     g_current_view = VIEW_EXPIRED;
            if (ImGui::MenuItem("Search Loans"))      g_current_view = VIEW_SEARCH_LOANS;
            ImGui::EndMenu();
        }
        if (ImGui::BeginMenu("Databases"))
        {
            if (ImGui::MenuItem("Select DBs"))        g_current_view = VIEW_SELECT_DB;
            if (ImGui::MenuItem("Import VB6 CSV"))    g_current_view = VIEW_IMPORT_READERS;
            ImGui::EndMenu();
        }
        if (ImGui::BeginMenu("Settings"))
        {
            if (ImGui::MenuItem("Account"))           g_current_view = VIEW_SETTINGS_ACCOUNT;
            if (ImGui::MenuItem("Theme"))             g_current_view = VIEW_SETTINGS_THEME;
            if (ImGui::MenuItem("Performance"))       g_current_view = VIEW_SETTINGS_PERF;
            if (ImGui::MenuItem("Networking"))        g_current_view = VIEW_SETTINGS_NET;
            if (ImGui::MenuItem("Other"))             g_current_view = VIEW_SETTINGS_OTHER;
            if (ImGui::MenuItem("Reset Defaults"))    g_current_view = VIEW_RESET_SETTINGS;
            ImGui::EndMenu();
        }
        if (ImGui::BeginMenu("Account"))
        {
            if (ImGui::MenuItem("Login"))             g_current_view = VIEW_LOGIN;
            if (ImGui::MenuItem("Register"))          g_current_view = VIEW_REGISTER;
            ImGui::EndMenu();
        }
        if (ImGui::MenuItem("About")) { g_current_view = VIEW_ABOUT; }
        ImGui::EndMenuBar();
    }
}

static void view_login()
{
    ImGui::Text("Login");
    ImGui::Separator();
    ImGui::InputText("Username", g_inp_buf, sizeof(g_inp_buf));
    ImGui::InputText("Password", g_inp_buf2, sizeof(g_inp_buf2), ImGuiInputTextFlags_Password);
    if (ImGui::Button("Login"))
    {
        if (login(g_inp_buf2, g_inp_buf, 1) == 0)
            set_msg("Login successful");
        else
            set_msg("Login failed");
        g_inp_buf[0] = 0; g_inp_buf2[0] = 0;
    }
    ImGui::SameLine();
    if (ImGui::Button("Register")) g_current_view = VIEW_REGISTER;
    show_msg();
}

static void view_register()
{
    ImGui::Text("Register");
    ImGui::Separator();
    ImGui::InputText("Username", g_inp_buf, sizeof(g_inp_buf));
    ImGui::InputText("Password", g_inp_buf2, sizeof(g_inp_buf2), ImGuiInputTextFlags_Password);
    ImGui::InputText("Confirm", g_inp_buf3, sizeof(g_inp_buf3), ImGuiInputTextFlags_Password);
    if (ImGui::Button("Register"))
    {
        if (strcmp(g_inp_buf2, g_inp_buf3) == 0)
        {
            short r = signup(g_inp_buf2, g_inp_buf, 1);
            if (r == 0) set_msg("Registration OK");
            else { sprintf(g_inp_buf, "Error %d", r); set_msg(g_inp_buf); }
        }
        else set_msg("Passwords don't match");
    }
    ImGui::SameLine();
    if (ImGui::Button("Back to Login")) g_current_view = VIEW_LOGIN;
    show_msg();
}

static void view_add_books()
{
    ImGui::Text("Add Book");
    ImGui::Separator();
    ImGui::InputText("Title", g_inp_buf, sizeof(g_inp_buf));
    ImGui::InputText("Author", g_inp_buf2, sizeof(g_inp_buf2));
    ImGui::InputText("ISBN", g_inp_buf3, sizeof(g_inp_buf3));
    ImGui::InputInt("ID", &g_book_id);
    {
        static std::vector<const char*> cat_items;
        cat_items.clear();
        for (auto& c : g_categories) cat_items.push_back(c.c_str());
        ImGui::Combo("Category", &g_selected_cat, cat_items.data(), (int)cat_items.size());
    }
    ImGui::Combo("Status", &g_selected_status, status_list, 5);
    if (ImGui::Button("Add Book"))
    {
        if (g_inp_buf[0] && g_inp_buf2[0] && g_book_id > 0)
        {
            if (book_id_exists(std::to_string(g_book_id)))
                set_msg("Book ID already exists");
            else
            {
                save_book(g_inp_buf, g_inp_buf2, g_inp_buf3,
                    std::to_string(g_book_id), g_categories[g_selected_cat],
                    status_list[g_selected_status]);
                set_msg("Book added");
                g_inp_buf[0] = 0; g_inp_buf2[0] = 0; g_inp_buf3[0] = 0; g_book_id = 0;
            }
        }
        else set_msg("Title, Author and ID required");
    }
    show_msg();
}

static void view_edit_books()
{
    ImGui::Text("Edit Book");
    ImGui::Separator();
    ImGui::InputInt("Book ID", &g_book_id);
    if (ImGui::Button("Check"))
    {
        if (book_id_exists(std::to_string(g_book_id)))
            set_msg("Book found");
        else
            set_msg("Book not found");
    }
    ImGui::InputText("New Title", g_inp_buf, sizeof(g_inp_buf));
    ImGui::InputText("New Author", g_inp_buf2, sizeof(g_inp_buf2));
    if (ImGui::Button("Edit"))
        set_msg(g_book_id > 0 ? "Would edit book (stub)" : "Enter valid ID");
    show_msg();
}

static void view_delete_books()
{
    ImGui::Text("Delete Book");
    ImGui::Separator();
    ImGui::InputInt("Book ID", &g_book_id);
    if (ImGui::Button("Check"))
    {
        if (book_id_exists(std::to_string(g_book_id)))
            set_msg("Book found");
        else
            set_msg("Book not found");
    }
    if (ImGui::Button("Delete"))
    {
        if (book_id_exists(std::to_string(g_book_id)))
            ImGui::OpenPopup("Confirm Delete");
        else
            set_msg("Book not found");
    }
    if (ImGui::BeginPopupModal("Confirm Delete", 0, ImGuiWindowFlags_AlwaysAutoResize))
    {
        ImGui::Text("Delete book %d?", g_book_id);
        if (ImGui::Button("Yes")) { set_msg("Would delete (stub)"); ImGui::CloseCurrentPopup(); }
        ImGui::SameLine();
        if (ImGui::Button("No")) ImGui::CloseCurrentPopup();
        ImGui::EndPopup();
    }
    show_msg();
}

static void view_manage_categories()
{
    ImGui::Text("Manage Categories");
    ImGui::Separator();
    for (int i = 0; i < (int)g_categories.size(); i++)
    {
        ImGui::Text("%d: %s", i + 1, g_categories[i].c_str());
        ImGui::SameLine();
        char dl[64]; sprintf(dl, "X##cat%d", i);
        if (ImGui::SmallButton(dl))
            if (i < (int)g_categories.size()) g_categories.erase(g_categories.begin() + i);
    }
    ImGui::InputText("New Category", g_inp_buf, sizeof(g_inp_buf));
    if (ImGui::Button("Add Category") && g_inp_buf[0])
    { g_categories.push_back(g_inp_buf); g_inp_buf[0] = 0; set_msg("Category added"); }
    show_msg();
}

static void view_add_readers()
{
    ImGui::Text("Add Reader");
    ImGui::Separator();
    ImGui::InputText("Name", g_inp_buf, sizeof(g_inp_buf));
    ImGui::InputText("Surname", g_inp_buf2, sizeof(g_inp_buf2));
    ImGui::InputText("Grade", g_inp_buf3, sizeof(g_inp_buf3));
    ImGui::InputText("Class", g_inp_buf4, sizeof(g_inp_buf4));
    if (ImGui::Button("Add Reader"))
    {
        if (g_inp_buf[0] && g_inp_buf2[0])
        {
            if (reader_exists(g_inp_buf, g_inp_buf2))
                set_msg("Reader already exists");
            else
            {
                save_reader(g_inp_buf, g_inp_buf2, g_inp_buf3, g_inp_buf4);
                set_msg("Reader added");
                g_inp_buf[0]=0; g_inp_buf2[0]=0; g_inp_buf3[0]=0; g_inp_buf4[0]=0;
            }
        }
        else set_msg("Name and surname required");
    }
    show_msg();
}

static void view_edit_readers()
{
    ImGui::Text("Edit Reader");
    ImGui::Separator();
    ImGui::InputText("Current Name", g_inp_buf, sizeof(g_inp_buf));
    ImGui::InputText("Current Surname", g_inp_buf2, sizeof(g_inp_buf2));
    if (ImGui::Button("Check"))
        set_msg(reader_exists(g_inp_buf, g_inp_buf2) ? "Reader found" : "Reader not found");
    ImGui::InputText("New Name", g_inp_buf3, sizeof(g_inp_buf3));
    ImGui::InputText("New Surname", g_inp_buf4, sizeof(g_inp_buf4));
    if (ImGui::Button("Edit"))
        set_msg(g_inp_buf[0] ? "Would edit reader (stub)" : "Enter current name");
    show_msg();
}

static void view_delete_readers()
{
    ImGui::Text("Delete Reader");
    ImGui::Separator();
    ImGui::InputText("Name", g_inp_buf, sizeof(g_inp_buf));
    ImGui::InputText("Surname", g_inp_buf2, sizeof(g_inp_buf2));
    if (ImGui::Button("Check"))
        set_msg(reader_exists(g_inp_buf, g_inp_buf2) ? "Reader found" : "Reader not found");
    if (ImGui::Button("Delete"))
    {
        if (reader_exists(g_inp_buf, g_inp_buf2))
            ImGui::OpenPopup("Confirm Delete Reader");
        else set_msg("Reader not found");
    }
    if (ImGui::BeginPopupModal("Confirm Delete Reader", 0, ImGuiWindowFlags_AlwaysAutoResize))
    {
        ImGui::Text("Delete \"%s %s\"?", g_inp_buf, g_inp_buf2);
        if (ImGui::Button("Yes")) { set_msg("Would delete (stub)"); ImGui::CloseCurrentPopup(); }
        ImGui::SameLine();
        if (ImGui::Button("No")) ImGui::CloseCurrentPopup();
        ImGui::EndPopup();
    }
    show_msg();
}

static void view_import_readers()
{
    ImGui::Text("Import Readers (or VB6 CSV)");
    ImGui::Separator();
    ImGui::InputText("Source File", g_inp_buf, sizeof(g_inp_buf));
    if (ImGui::Button("Import Readers") && g_inp_buf[0])
    {
        std::ifstream ifs(g_inp_buf);
        if (!ifs.is_open()) { set_msg("Cannot open file"); }
        else
        {
            int n = 0; std::string l;
            std::ofstream of(g_readers_db, std::ios::app);
            while (std::getline(ifs, l)) { if (!l.empty()) { of << l << "\n"; n++; } }
            char buf[64]; sprintf(buf, "%d readers imported", n); set_msg(buf);
        }
    }
    show_msg();
}

static void view_add_loans()
{
    ImGui::Text("Add Loan");
    ImGui::Separator();
    ImGui::InputInt("Book ID", &g_book_id);
    ImGui::InputText("Reader Name", g_inp_buf, sizeof(g_inp_buf));
    ImGui::InputText("Reader Surname", g_inp_buf2, sizeof(g_inp_buf2));
    static int dur = 14;
    ImGui::InputInt("Duration (days)", &dur);
    if (dur <= 0) dur = g_default_loan_duration;
    if (ImGui::Button("Add Loan"))
    {
        if (g_book_id <= 0) set_msg("Enter valid book ID");
        else if (!g_inp_buf[0] || !g_inp_buf2[0]) set_msg("Enter reader name/surname");
        else if (!book_id_exists(std::to_string(g_book_id))) set_msg("Book not found");
        else if (loan_id_exists(std::to_string(g_book_id))) set_msg("Book already on loan");
        else if (!reader_exists(g_inp_buf, g_inp_buf2)) set_msg("Reader not found");
        else
        {
            std::string rdr = std::string(g_inp_buf) + " " + g_inp_buf2;
            std::string ld = get_current_date_str();
            std::string ed = add_days_to_date(ld, dur);
            save_loan(std::to_string(g_book_id), rdr, ld, ed);
            char buf[128]; sprintf(buf, "Loan added, expires: %s", ed.c_str());
            set_msg(buf);
        }
    }
    show_msg();
}

static void view_return_loans()
{
    ImGui::Text("Return Loan");
    ImGui::Separator();
    ImGui::InputInt("Loan ID", &g_loan_id);
    if (ImGui::Button("Check"))
    {
        if (loan_id_exists(std::to_string(g_loan_id)))
            set_msg(get_loan_field(std::to_string(g_loan_id), 4) == "returned"
                ? "Already returned" : "Active loan");
        else set_msg("Loan not found");
    }
    if (ImGui::Button("Return"))
    {
        if (loan_id_exists(std::to_string(g_loan_id)))
        { update_loan_field(std::to_string(g_loan_id), 4, "returned"); set_msg("Loan returned"); }
        else set_msg("Loan not found");
    }
    show_msg();
}

static void view_list_loans()
{
    ImGui::Text("Active Loans");
    ImGui::Separator();
    std::ifstream file(g_loans_db);
    if (!file.is_open()) { ImGui::Text("Cannot open loans DB"); return; }
    std::string line;
    int n = 0;
    if (ImGui::BeginTable("loans", 5, ImGuiTableFlags_Borders|ImGuiTableFlags_RowBg))
    {
        ImGui::TableSetupColumn("Book"); ImGui::TableSetupColumn("Reader");
        ImGui::TableSetupColumn("From"); ImGui::TableSetupColumn("To");
        ImGui::TableSetupColumn("Status");
        ImGui::TableHeadersRow();
        while (std::getline(file, line))
        {
            if (line.empty()) continue;
            std::size_t p0=line.find('|'), p1=line.find('|',p0+1);
            std::size_t p2=line.find('|',p1+1), p3=line.find('|',p2+1);
            if (p0==std::string::npos||p1==std::string::npos||p2==std::string::npos||p3==std::string::npos) continue;
            ImGui::TableNextRow();
            ImGui::TableNextColumn(); ImGui::Text("%s",line.substr(0,p0).c_str());
            ImGui::TableNextColumn(); ImGui::Text("%s",line.substr(p0+1,p1-p0-1).c_str());
            ImGui::TableNextColumn(); ImGui::Text("%s",line.substr(p1+1,p2-p1-1).c_str());
            ImGui::TableNextColumn(); ImGui::Text("%s",line.substr(p2+1,p3-p2-1).c_str());
            ImGui::TableNextColumn(); ImGui::Text("%s",line.substr(p3+1).c_str());
            n++;
        }
        ImGui::EndTable();
    }
    file.close();
    ImGui::Text("Total: %d loans", n);
}

static void view_search_loans()
{
    ImGui::Text("Search Loans");
    ImGui::Separator();
    static int sf = 0;
    ImGui::Combo("Search by", &sf, "Book ID\0Reader\0");
    ImGui::InputText("Query", g_inp_buf, sizeof(g_inp_buf));
    if (ImGui::Button("Search") && g_inp_buf[0])
    {
        std::string q = g_inp_buf;
        std::ifstream file(g_loans_db);
        std::string line;
        int n = 0;
        if (ImGui::BeginTable("sloans", 5, ImGuiTableFlags_Borders))
        {
            ImGui::TableSetupColumn("Book"); ImGui::TableSetupColumn("Reader");
            ImGui::TableSetupColumn("From"); ImGui::TableSetupColumn("To");
            ImGui::TableSetupColumn("Status");
            ImGui::TableHeadersRow();
            while (std::getline(file, line))
            {
                if (line.empty()) continue;
                std::size_t p0=line.find('|'), p1=line.find('|',p0+1);
                std::size_t p2=line.find('|',p1+1), p3=line.find('|',p2+1);
                if (p0==std::string::npos) continue;
                std::string f = (sf==0) ? line.substr(0,p0) : line.substr(p0+1,p1-p0-1);
                if (f.find(q)==std::string::npos) continue;
                ImGui::TableNextRow();
                ImGui::TableNextColumn(); ImGui::Text("%s",line.substr(0,p0).c_str());
                ImGui::TableNextColumn(); ImGui::Text("%s",line.substr(p0+1,p1-p0-1).c_str());
                ImGui::TableNextColumn(); ImGui::Text("%s",line.substr(p1+1,p2-p1-1).c_str());
                ImGui::TableNextColumn(); ImGui::Text("%s",line.substr(p2+1,p3-p2-1).c_str());
                ImGui::TableNextColumn(); ImGui::Text("%s",line.substr(p3+1).c_str());
                n++;
            }
            ImGui::EndTable();
        }
        file.close();
        char buf[64]; sprintf(buf, "Found %d matches", n); set_msg(buf);
    }
    show_msg();
}

static void view_edit_loans()
{
    ImGui::Text("Edit Loan");
    ImGui::Separator();
    ImGui::InputInt("Loan ID", &g_loan_id);
    if (ImGui::Button("Check"))
        set_msg(loan_id_exists(std::to_string(g_loan_id)) ? "Loan found" : "Loan not found");
    ImGui::InputInt("New Book ID", &g_book_id);
    ImGui::InputText("New Reader", g_inp_buf, sizeof(g_inp_buf));
    if (ImGui::Button("Update"))
    {
        std::string sid = std::to_string(g_loan_id);
        if (loan_id_exists(sid))
        {
            if (g_book_id > 0) update_loan_field(sid, 0, std::to_string(g_book_id));
            if (g_inp_buf[0]) update_loan_field(sid, 1, g_inp_buf);
            set_msg("Loan updated");
        }
        else set_msg("Loan not found");
    }
    show_msg();
}

static void view_remove_loans()
{
    ImGui::Text("Remove Loan");
    ImGui::Separator();
    ImGui::InputInt("Loan ID", &g_loan_id);
    if (ImGui::Button("Remove"))
    {
        if (loan_id_exists(std::to_string(g_loan_id)))
            ImGui::OpenPopup("Confirm Remove Loan");
        else set_msg("Loan not found");
    }
    if (ImGui::BeginPopupModal("Confirm Remove Loan", 0, ImGuiWindowFlags_AlwaysAutoResize))
    {
        ImGui::Text("Remove loan %d?", g_loan_id);
        if (ImGui::Button("Yes")) { delete_loan(std::to_string(g_loan_id)); set_msg("Loan removed"); ImGui::CloseCurrentPopup(); }
        ImGui::SameLine();
        if (ImGui::Button("No")) ImGui::CloseCurrentPopup();
        ImGui::EndPopup();
    }
    show_msg();
}

static void view_mark_lost()
{
    ImGui::Text("Mark Lost");
    ImGui::Separator();
    ImGui::InputInt("Loan ID", &g_loan_id);
    if (ImGui::Button("Mark Lost"))
    {
        std::string sid = std::to_string(g_loan_id);
        if (!loan_id_exists(sid)) set_msg("Loan not found");
        else if (get_loan_field(sid,4)=="lost") set_msg("Already lost");
        else { update_loan_field(sid,4,"lost"); set_msg("Marked lost"); }
    }
    show_msg();
}

static void view_prolong()
{
    ImGui::Text("Prolong Loan");
    ImGui::Separator();
    ImGui::InputInt("Loan ID", &g_loan_id);
    static int extra = 14;
    ImGui::InputInt("Extra Days", &extra);
    if (ImGui::Button("Prolong"))
    {
        std::string sid = std::to_string(g_loan_id);
        if (!loan_id_exists(sid)) set_msg("Loan not found");
        else
        {
            std::string st = get_loan_field(sid,4);
            if (st=="returned"||st=="lost") set_msg("Cannot prolong");
            else
            {
                std::string cur = get_loan_field(sid,3);
                std::string nxt = add_days_to_date(cur,extra);
                update_loan_field(sid,3,nxt);
                char buf[128]; sprintf(buf,"Prolonged to %s",nxt.c_str()); set_msg(buf);
            }
        }
    }
    show_msg();
}

static void view_expired()
{
    ImGui::Text("Expired Loans");
    ImGui::Separator();
    std::string today = get_current_date_str();
    std::ifstream file(g_loans_db);
    if (!file.is_open()) { ImGui::Text("Cannot open loans DB"); return; }
    std::string line;
    int n = 0;
    while (std::getline(file, line))
    {
        if (line.empty()) continue;
        std::size_t p0=line.find('|'), p1=line.find('|',p0+1);
        std::size_t p2=line.find('|',p1+1), p3=line.find('|',p2+1);
        if (p0==std::string::npos||p1==std::string::npos||p2==std::string::npos||p3==std::string::npos) continue;
        std::string exp = line.substr(p2+1,p3-p2-1);
        std::string st = line.substr(p3+1);
        if (st!="active") continue;
        if (exp < today)
        {
            ImGui::TextColored(ImVec4(1,0,0,1),"%s -> %s (exp: %s)",
                line.substr(0,p0).c_str(), line.substr(p0+1,p1-p0-1).c_str(), exp.c_str());
            n++;
        }
    }
    file.close();
    ImGui::TextColored(ImVec4(1,1,0,1),"Total expired: %d", n);
}

static void view_select_db()
{
    ImGui::Text("Database Selection");
    ImGui::Separator();
    ImGui::Text("Books DB:   %s", g_books_db.c_str());
    ImGui::Text("Readers DB: %s", g_readers_db.c_str());
    ImGui::Text("Loans DB:   %s", g_loans_db.c_str());
    if (ImGui::Button("Verify"))
    {
        ImGui::Text("Books:   %s", db_exists(g_books_db)?"OK":"MISSING");
        ImGui::Text("Readers: %s", db_exists(g_readers_db)?"OK":"MISSING");
        ImGui::Text("Loans:   %s", db_exists(g_loans_db)?"OK":"MISSING");
    }
    ImGui::Separator();
    ImGui::InputText("New Books DB", g_inp_buf, sizeof(g_inp_buf));
    if (ImGui::Button("Set Books") && g_inp_buf[0]) g_books_db = g_inp_buf;
    ImGui::InputText("New Readers DB", g_inp_buf2, sizeof(g_inp_buf2));
    if (ImGui::Button("Set Readers") && g_inp_buf2[0]) g_readers_db = g_inp_buf2;
    ImGui::InputText("New Loans DB", g_inp_buf3, sizeof(g_inp_buf3));
    if (ImGui::Button("Set Loans") && g_inp_buf3[0]) g_loans_db = g_inp_buf3;
    show_msg();
}

static void view_settings_account()
{
    ImGui::Text("Account Settings"); ImGui::Separator(); ImGui::Text("(not yet implemented)");
}

static void view_settings_theme()
{
    ImGui::Text("Theme Settings"); ImGui::Separator();
    if (ImGui::Button("Light Theme")) set_msg("Light (stub)");
    ImGui::SameLine();
    if (ImGui::Button("Dark Theme")) set_msg("Dark (stub)");
    show_msg();
}

static void view_settings_perf()
{
    ImGui::Text("Performance Settings"); ImGui::Separator(); ImGui::Text("(not yet implemented)");
}

static void view_settings_net()
{
    ImGui::Text("Networking"); ImGui::Separator();
    ImGui::Text("Networking: %s", g_enable_networking?"Enabled":"Disabled");
    if (ImGui::Button("Toggle")) { g_enable_networking=!g_enable_networking; save_settings(); set_msg("Toggled"); }
    show_msg();
}

static void view_settings_other()
{
    ImGui::Text("Other Settings");
    ImGui::Separator();
    ImGui::Text("Language: %s", g_default_language.c_str());
    ImGui::Text("Save Worklogs: %s", g_save_worklogs?"Yes":"No");
    ImGui::Text("Check Loans: %s", g_check_loans?"Yes":"No");
    ImGui::Text("Allow Same IDs: %s", g_enable_same_ids?"Yes":"No");
    ImGui::Text("Default Loan Duration: %d days", g_default_loan_duration);
    ImGui::Separator();
    ImGui::InputText("Language", g_inp_buf, sizeof(g_inp_buf));
    if (ImGui::Button("Set Language") && g_inp_buf[0]) { g_default_language=g_inp_buf; save_settings(); set_msg("Set"); }
    if (ImGui::Button("Toggle Worklogs")) { g_save_worklogs=!g_save_worklogs; save_settings(); set_msg("Toggled"); }
    if (ImGui::Button("Toggle Check Loans")) { g_check_loans=!g_check_loans; save_settings(); set_msg("Toggled"); }
    if (ImGui::Button("Toggle Same IDs")) { g_enable_same_ids=!g_enable_same_ids; save_settings(); set_msg("Toggled"); }
    static int nd=14;
    ImGui::InputInt("Duration", &nd);
    if (ImGui::Button("Set Duration") && nd>0) { g_default_loan_duration=nd; save_settings(); set_msg("Set"); }
    show_msg();
}

static void view_reset_settings()
{
    ImGui::Text("Reset Settings"); ImGui::Separator();
    if (ImGui::Button("Reset"))
    {
        g_default_language="English-US"; g_save_worklogs=true;
        g_enable_networking=false; g_enable_same_ids=false;
        g_check_loans=true; g_default_loan_duration=14;
        save_settings(); set_msg("Reset");
    }
    show_msg();
}

static void view_about()
{
    ImGui::Text("ShelfSight v1.0");
    ImGui::Separator();
    ImGui::Text("Library Management System");
    ImGui::Text("ImGui GUI (GLFW + OpenGL 1.1)");
    ImGui::Text("Target: <8MB RAM, Win95-era CPU");
}

static void resource_usage()
{
    static long rss = 0;
    static double cpu_ms = 0;
    static double last = 0;
    double now = ImGui::GetTime();
    if (now - last > 1.0)
    {
        last = now;
        std::ifstream sf("/proc/self/status");
        std::string ln;
        while (std::getline(sf, ln))
            if (ln.compare(0,6,"VmRSS:")==0) { sscanf(ln.c_str(),"%*s %ld",&rss); break; }
        std::ifstream st("/proc/self/stat");
        if (st.is_open())
        {
            long ut, stt;
            st >> ln>>ln>>ln>>ln>>ln>>ln>>ln>>ln>>ln>>ln>>ln>>ln>>ln>>ut>>stt;
            cpu_ms = (double)(ut + stt) / 100.0;
        }
    }
    ImGui::TextColored(ImVec4(0,1,0,1), "RAM: %.2f MB  CPU: %.1f ms", rss / 1024.0, cpu_ms);
}

void gui_imgui_run()
{
    if (!glfwInit()) { fprintf(stderr,"GLFW init failed\n"); return; }
    glfwWindowHint(GLFW_RESIZABLE, GLFW_TRUE);
    g_window = glfwCreateWindow(800, 600, "ShelfSight", 0, 0);
    if (!g_window) { glfwTerminate(); return; }
    glfwMakeContextCurrent(g_window);
    glfwSwapInterval(1);

    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO();
    io.IniFilename = 0;
    io.Fonts->AddFontDefault();

    ImGui_ImplGlfw_InitForOpenGL(g_window, true);
    ImGui_ImplOpenGL2_Init();

    load_settings();

    while (!glfwWindowShouldClose(g_window))
    {
        glfwPollEvents();
        ImGui_ImplOpenGL2_NewFrame();
        ImGui_ImplGlfw_NewFrame();
        ImGui::NewFrame();

        ImGui::SetNextWindowSize(ImVec2(780, 560), ImGuiCond_FirstUseEver);
        ImGui::Begin("ShelfSight", 0,
            ImGuiWindowFlags_NoScrollbar |
            ImGuiWindowFlags_MenuBar | ImGuiWindowFlags_NoSavedSettings);

        menu_bar();

        if (ImGui::BeginChild("content", ImVec2(0,-20), false))
        {
            switch (g_current_view)
            {
                case VIEW_LOGIN:             view_login(); break;
                case VIEW_REGISTER:          view_register(); break;
                case VIEW_ADD_BOOKS:         view_add_books(); break;
                case VIEW_EDIT_BOOKS:        view_edit_books(); break;
                case VIEW_DELETE_BOOKS:      view_delete_books(); break;
                case VIEW_MANAGE_CATEGORIES: view_manage_categories(); break;
                case VIEW_ADD_READERS:       view_add_readers(); break;
                case VIEW_EDIT_READERS:      view_edit_readers(); break;
                case VIEW_DELETE_READERS:    view_delete_readers(); break;
                case VIEW_IMPORT_READERS:    view_import_readers(); break;
                case VIEW_ADD_LOANS:         view_add_loans(); break;
                case VIEW_RETURN_LOANS:      view_return_loans(); break;
                case VIEW_LIST_LOANS:        view_list_loans(); break;
                case VIEW_EDIT_LOANS:        view_edit_loans(); break;
                case VIEW_REMOVE_LOANS:      view_remove_loans(); break;
                case VIEW_MARK_LOST:         view_mark_lost(); break;
                case VIEW_PROLONG:           view_prolong(); break;
                case VIEW_EXPIRED:           view_expired(); break;
                case VIEW_SEARCH_LOANS:      view_search_loans(); break;
                case VIEW_SELECT_DB:         view_select_db(); break;
                case VIEW_SETTINGS_ACCOUNT:  view_settings_account(); break;
                case VIEW_SETTINGS_THEME:    view_settings_theme(); break;
                case VIEW_SETTINGS_PERF:     view_settings_perf(); break;
                case VIEW_SETTINGS_NET:      view_settings_net(); break;
                case VIEW_SETTINGS_OTHER:    view_settings_other(); break;
                case VIEW_RESET_SETTINGS:    view_reset_settings(); break;
                case VIEW_ABOUT:             view_about(); break;
                default:                     view_login(); break;
            }
        }
        ImGui::EndChild();

        resource_usage();
        ImGui::End();

        ImGui::Render();
        ImGui_ImplOpenGL2_RenderDrawData(ImGui::GetDrawData());
        glfwSwapBuffers(g_window);
    }

    ImGui_ImplOpenGL2_Shutdown();
    ImGui_ImplGlfw_Shutdown();
    ImGui::DestroyContext();
    glfwDestroyWindow(g_window);
    glfwTerminate();
}
