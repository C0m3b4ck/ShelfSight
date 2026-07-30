#include "gui_tcl.h"
#include "file_man.h"
#include "glob_vars.h"

#include <tcl.h>
#include <tk.h>

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>
#include <vector>
#include <fstream>
#include <sstream>
#include <algorithm>

// ---------- helpers ----------

static std::vector<std::string> read_lines(const std::string& path)
{
    std::vector<std::string> out;
    std::ifstream f(path);
    std::string l;
    while (std::getline(f, l)) if (!l.empty()) out.push_back(l);
    return out;
}

static void write_lines(const std::string& path, const std::vector<std::string>& lines)
{
    std::ofstream f(path);
    for (const auto& l : lines) f << l << "\n";
}

static std::string get_field(const std::string& line, int idx)
{
    std::size_t p = 0;
    for (int i = 0; i < idx; i++) { p = line.find('|', p); if (p == std::string::npos) return ""; p++; }
    std::size_t e = line.find('|', p);
    return line.substr(p, e == std::string::npos ? e : e - p);
}

static bool line_has_id(const std::string& line, const std::string& id)
{
    std::size_t p0 = line.find('|');
    std::size_t p1 = p0 == std::string::npos ? std::string::npos : line.find('|', p0 + 1);
    std::size_t p2 = p1 == std::string::npos ? std::string::npos : line.find('|', p1 + 1);
    std::size_t p3 = p2 == std::string::npos ? std::string::npos : line.find('|', p2 + 1);
    if (p3 == std::string::npos) return false;
    std::string fid = line.substr(p2 + 1, p3 - p2 - 1);
    return fid == id;
}

static std::string replace_line_by_id(const std::string& db, const std::string& id,
                                       const std::string& new_line)
{
    auto lines = read_lines(db);
    for (auto& l : lines)
        if (line_has_id(l, id)) { l = new_line; break; }
    write_lines(db, lines);
    return "";
}

static std::string remove_line_by_id(const std::string& db, const std::string& id)
{
    auto lines = read_lines(db);
    lines.erase(std::remove_if(lines.begin(), lines.end(),
        [&](const std::string& l) { return line_has_id(l, id); }), lines.end());
    write_lines(db, lines);
    return "";
}

static std::string remove_line_by_name(const std::string& db,
                                        const std::string& name, const std::string& surname)
{
    auto lines = read_lines(db);
    lines.erase(std::remove_if(lines.begin(), lines.end(),
        [&](const std::string& l) {
            std::size_t p0 = l.find('|');
            if (p0 == std::string::npos) return false;
            std::string fn = l.substr(0, p0);
            std::size_t p1 = l.find('|', p0 + 1);
            std::string sn = l.substr(p0 + 1, p1 == std::string::npos ? p1 : p1 - p0 - 1);
            return fn == name && sn == surname;
        }), lines.end());
    write_lines(db, lines);
    return "";
}

// ---------- Tcl command handlers ----------

static int TclCmd_Login(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    if (objc != 3) { Tcl_WrongNumArgs(interp, 1, objv, "username password"); return TCL_ERROR; }
    const char* user = Tcl_GetStringFromObj(objv[1], nullptr);
    const char* pass = Tcl_GetStringFromObj(objv[2], nullptr);
    Tcl_SetObjResult(interp, Tcl_NewIntObj(login(pass, user, 1)));
    return TCL_OK;
}

static int TclCmd_Register(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    if (objc != 4) { Tcl_WrongNumArgs(interp, 1, objv, "username password confirm"); return TCL_ERROR; }
    const char* user = Tcl_GetStringFromObj(objv[1], nullptr);
    const char* pass = Tcl_GetStringFromObj(objv[2], nullptr);
    const char* conf = Tcl_GetStringFromObj(objv[3], nullptr);
    if (strcmp(pass, conf) == 0)
        { signup(pass, user, 1); Tcl_SetObjResult(interp, Tcl_NewIntObj(0)); }
    else
        Tcl_SetObjResult(interp, Tcl_NewStringObj("Passwords do not match", -1));
    return TCL_OK;
}

static int TclCmd_AddBook(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    if (objc != 7) { Tcl_WrongNumArgs(interp, 1, objv, "title author isbn id category status"); return TCL_ERROR; }
    const char* title = Tcl_GetStringFromObj(objv[1], nullptr);
    const char* author = Tcl_GetStringFromObj(objv[2], nullptr);
    const char* isbn = Tcl_GetStringFromObj(objv[3], nullptr);
    const char* id = Tcl_GetStringFromObj(objv[4], nullptr);
    const char* cat = Tcl_GetStringFromObj(objv[5], nullptr);
    const char* st = Tcl_GetStringFromObj(objv[6], nullptr);
    Tcl_SetObjResult(interp, Tcl_NewIntObj(save_book(title, author, isbn, id, cat, st)));
    return TCL_OK;
}

static int TclCmd_GetBook(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    if (objc != 2) { Tcl_WrongNumArgs(interp, 1, objv, "id"); return TCL_ERROR; }
    const char* id = Tcl_GetStringFromObj(objv[1], nullptr);
    auto lines = read_lines(g_books_db);
    for (const auto& l : lines)
        if (line_has_id(l, id)) { Tcl_SetObjResult(interp, Tcl_NewStringObj(l.c_str(), (int)l.size())); return TCL_OK; }
    return TCL_OK;
}

static int TclCmd_EditBook(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    if (objc != 8) { Tcl_WrongNumArgs(interp, 1, objv, "id title author isbn category status"); return TCL_ERROR; }
    const char* id = Tcl_GetStringFromObj(objv[1], nullptr);
    const char* title = Tcl_GetStringFromObj(objv[2], nullptr);
    const char* author = Tcl_GetStringFromObj(objv[3], nullptr);
    const char* isbn = Tcl_GetStringFromObj(objv[4], nullptr);
    const char* cat = Tcl_GetStringFromObj(objv[5], nullptr);
    const char* st = Tcl_GetStringFromObj(objv[6], nullptr);
    std::string nl = std::string(title) + "|" + author + "|" + isbn + "|" + id + "|" + cat + "|" + st;
    replace_line_by_id(g_books_db, id, nl);
    return TCL_OK;
}

static int TclCmd_DeleteBook(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    if (objc != 2) { Tcl_WrongNumArgs(interp, 1, objv, "id"); return TCL_ERROR; }
    remove_line_by_id(g_books_db, Tcl_GetStringFromObj(objv[1], nullptr));
    return TCL_OK;
}

static int TclCmd_ListBooks(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    (void)objc; (void)objv;
    auto lines = read_lines(g_books_db);
    Tcl_Obj* list = Tcl_NewListObj(0, nullptr);
    for (const auto& l : lines)
        Tcl_ListObjAppendElement(interp, list, Tcl_NewStringObj(l.c_str(), (int)l.size()));
    Tcl_SetObjResult(interp, list);
    return TCL_OK;
}

static int TclCmd_SearchBooks(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    if (objc != 2) { Tcl_WrongNumArgs(interp, 1, objv, "query"); return TCL_ERROR; }
    const char* q = Tcl_GetStringFromObj(objv[1], nullptr);
    auto lines = read_lines(g_books_db);
    Tcl_Obj* list = Tcl_NewListObj(0, nullptr);
    for (const auto& l : lines)
        if (l.find(q) != std::string::npos)
            Tcl_ListObjAppendElement(interp, list, Tcl_NewStringObj(l.c_str(), (int)l.size()));
    Tcl_SetObjResult(interp, list);
    return TCL_OK;
}

static int TclCmd_GetCategories(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    (void)objc; (void)objv;
    Tcl_Obj* list = Tcl_NewListObj(0, nullptr);
    for (const auto& c : g_categories)
        Tcl_ListObjAppendElement(interp, list, Tcl_NewStringObj(c.c_str(), (int)c.size()));
    Tcl_SetObjResult(interp, list);
    return TCL_OK;
}

static int TclCmd_AddCategory(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    if (objc != 2) { Tcl_WrongNumArgs(interp, 1, objv, "name"); return TCL_ERROR; }
    g_categories.push_back(Tcl_GetStringFromObj(objv[1], nullptr));
    return TCL_OK;
}

static int TclCmd_RemoveCategory(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    if (objc != 2) { Tcl_WrongNumArgs(interp, 1, objv, "index"); return TCL_ERROR; }
    int idx; if (Tcl_GetIntFromObj(interp, objv[1], &idx) != TCL_OK) return TCL_ERROR;
    if (idx >= 0 && idx < (int)g_categories.size())
        g_categories.erase(g_categories.begin() + idx);
    return TCL_OK;
}

static int TclCmd_AddReader(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    if (objc != 5) { Tcl_WrongNumArgs(interp, 1, objv, "name surname grade class"); return TCL_ERROR; }
    const char* n = Tcl_GetStringFromObj(objv[1], nullptr);
    const char* s = Tcl_GetStringFromObj(objv[2], nullptr);
    const char* g = Tcl_GetStringFromObj(objv[3], nullptr);
    const char* c = Tcl_GetStringFromObj(objv[4], nullptr);
    Tcl_SetObjResult(interp, Tcl_NewIntObj(save_reader(n, s, g, c)));
    return TCL_OK;
}

static int TclCmd_EditReader(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    if (objc != 7) { Tcl_WrongNumArgs(interp, 1, objv, "old_name old_surname new_name new_surname grade class"); return TCL_ERROR; }
    const char* on = Tcl_GetStringFromObj(objv[1], nullptr);
    const char* os = Tcl_GetStringFromObj(objv[2], nullptr);
    const char* nn = Tcl_GetStringFromObj(objv[3], nullptr);
    const char* ns = Tcl_GetStringFromObj(objv[4], nullptr);
    const char* g = Tcl_GetStringFromObj(objv[5], nullptr);
    const char* c = Tcl_GetStringFromObj(objv[6], nullptr);
    remove_line_by_name(g_readers_db, on, os);
    save_reader(nn, ns, g, c);
    return TCL_OK;
}

static int TclCmd_DeleteReader(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    if (objc != 3) { Tcl_WrongNumArgs(interp, 1, objv, "name surname"); return TCL_ERROR; }
    remove_line_by_name(g_readers_db, Tcl_GetStringFromObj(objv[1], nullptr), Tcl_GetStringFromObj(objv[2], nullptr));
    return TCL_OK;
}

static int TclCmd_GetReader(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    if (objc != 3) { Tcl_WrongNumArgs(interp, 1, objv, "name surname"); return TCL_ERROR; }
    const char* n = Tcl_GetStringFromObj(objv[1], nullptr);
    const char* s = Tcl_GetStringFromObj(objv[2], nullptr);
    auto lines = read_lines(g_readers_db);
    for (const auto& l : lines)
    {
        std::size_t p0 = l.find('|');
        if (p0 == std::string::npos) continue;
        if (l.substr(0, p0) == n && l.substr(p0 + 1, l.find('|', p0 + 1) - p0 - 1) == s)
            { Tcl_SetObjResult(interp, Tcl_NewStringObj(l.c_str(), (int)l.size())); return TCL_OK; }
    }
    return TCL_OK;
}

static int TclCmd_ListReaders(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    (void)objc; (void)objv;
    auto lines = read_lines(g_readers_db);
    Tcl_Obj* list = Tcl_NewListObj(0, nullptr);
    for (const auto& l : lines)
        Tcl_ListObjAppendElement(interp, list, Tcl_NewStringObj(l.c_str(), (int)l.size()));
    Tcl_SetObjResult(interp, list);
    return TCL_OK;
}

static int TclCmd_ImportReaders(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    if (objc != 2) { Tcl_WrongNumArgs(interp, 1, objv, "filename"); return TCL_ERROR; }
    const char* fname = Tcl_GetStringFromObj(objv[1], nullptr);
    std::ifstream ifs(fname);
    if (!ifs.is_open()) { Tcl_SetObjResult(interp, Tcl_NewStringObj("Cannot open file", -1)); return TCL_ERROR; }
    int n = 0; std::string l;
    std::ofstream of(g_readers_db, std::ios::app);
    while (std::getline(ifs, l)) { if (!l.empty()) { of << l << "\n"; n++; } }
    char buf[64]; snprintf(buf, sizeof(buf), "%d readers imported", n);
    Tcl_SetObjResult(interp, Tcl_NewStringObj(buf, -1));
    return TCL_OK;
}

static int TclCmd_AddLoan(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    if (objc != 5) { Tcl_WrongNumArgs(interp, 1, objv, "book_id reader loan_date expiration"); return TCL_ERROR; }
    const char* bid = Tcl_GetStringFromObj(objv[1], nullptr);
    const char* rdr = Tcl_GetStringFromObj(objv[2], nullptr);
    const char* ld = Tcl_GetStringFromObj(objv[3], nullptr);
    const char* ed = Tcl_GetStringFromObj(objv[4], nullptr);
    Tcl_SetObjResult(interp, Tcl_NewIntObj(save_loan(bid, rdr, ld, ed)));
    return TCL_OK;
}

static int TclCmd_ReturnLoan(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    if (objc != 2) { Tcl_WrongNumArgs(interp, 1, objv, "book_id"); return TCL_ERROR; }
    update_loan_field(Tcl_GetStringFromObj(objv[1], nullptr), 4, "returned");
    return TCL_OK;
}

static int TclCmd_GetLoan(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    if (objc != 2) { Tcl_WrongNumArgs(interp, 1, objv, "book_id"); return TCL_ERROR; }
    std::string out;
    if (get_loan_line(Tcl_GetStringFromObj(objv[1], nullptr), out))
        Tcl_SetObjResult(interp, Tcl_NewStringObj(out.c_str(), (int)out.size()));
    return TCL_OK;
}

static int TclCmd_ListLoans(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    (void)objc; (void)objv;
    auto lines = read_lines(g_loans_db);
    Tcl_Obj* list = Tcl_NewListObj(0, nullptr);
    for (const auto& l : lines)
        Tcl_ListObjAppendElement(interp, list, Tcl_NewStringObj(l.c_str(), (int)l.size()));
    Tcl_SetObjResult(interp, list);
    return TCL_OK;
}

static int TclCmd_DeleteLoan(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    if (objc != 2) { Tcl_WrongNumArgs(interp, 1, objv, "book_id"); return TCL_ERROR; }
    delete_loan(Tcl_GetStringFromObj(objv[1], nullptr));
    return TCL_OK;
}

static int TclCmd_MarkLost(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    if (objc != 2) { Tcl_WrongNumArgs(interp, 1, objv, "book_id"); return TCL_ERROR; }
    update_loan_field(Tcl_GetStringFromObj(objv[1], nullptr), 4, "lost");
    return TCL_OK;
}

static int TclCmd_Prolong(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    if (objc != 3) { Tcl_WrongNumArgs(interp, 1, objv, "book_id extra_days"); return TCL_ERROR; }
    const char* bid = Tcl_GetStringFromObj(objv[1], nullptr);
    int extra; if (Tcl_GetIntFromObj(interp, objv[2], &extra) != TCL_OK) return TCL_ERROR;
    std::string cur = get_loan_field(bid, 3);
    std::string nxt = add_days_to_date(cur, extra);
    update_loan_field(bid, 3, nxt);
    Tcl_SetObjResult(interp, Tcl_NewStringObj(nxt.c_str(), (int)nxt.size()));
    return TCL_OK;
}

static int TclCmd_GetCurrentDate(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    (void)objc; (void)objv;
    std::string d = get_current_date_str();
    Tcl_SetObjResult(interp, Tcl_NewStringObj(d.c_str(), (int)d.size()));
    return TCL_OK;
}

static int TclCmd_AddDays(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    if (objc != 3) { Tcl_WrongNumArgs(interp, 1, objv, "date days"); return TCL_ERROR; }
    const char* d = Tcl_GetStringFromObj(objv[1], nullptr);
    int days; if (Tcl_GetIntFromObj(interp, objv[2], &days) != TCL_OK) return TCL_ERROR;
    std::string r = add_days_to_date(d, days);
    Tcl_SetObjResult(interp, Tcl_NewStringObj(r.c_str(), (int)r.size()));
    return TCL_OK;
}

static int TclCmd_BookIdExists(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    if (objc != 2) { Tcl_WrongNumArgs(interp, 1, objv, "id"); return TCL_ERROR; }
    Tcl_SetObjResult(interp, Tcl_NewBooleanObj(book_id_exists(Tcl_GetStringFromObj(objv[1], nullptr))));
    return TCL_OK;
}

static int TclCmd_ReaderExists(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    if (objc != 3) { Tcl_WrongNumArgs(interp, 1, objv, "name surname"); return TCL_ERROR; }
    Tcl_SetObjResult(interp, Tcl_NewBooleanObj(reader_exists(Tcl_GetStringFromObj(objv[1], nullptr), Tcl_GetStringFromObj(objv[2], nullptr))));
    return TCL_OK;
}

static int TclCmd_LoanIdExists(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    if (objc != 2) { Tcl_WrongNumArgs(interp, 1, objv, "book_id"); return TCL_ERROR; }
    Tcl_SetObjResult(interp, Tcl_NewBooleanObj(loan_id_exists(Tcl_GetStringFromObj(objv[1], nullptr))));
    return TCL_OK;
}

static int TclCmd_LoadSettings(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    (void)objc; (void)objv;
    load_settings();
    return TCL_OK;
}

static int TclCmd_SaveSettings(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    (void)objc; (void)objv;
    save_settings();
    return TCL_OK;
}

static int TclCmd_GetResourceUsage(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    (void)objc; (void)objv;
    long rss = 0;
    std::ifstream sf("/proc/self/status");
    std::string ln;
    while (std::getline(sf, ln))
        if (ln.compare(0, 6, "VmRSS:") == 0) { sscanf(ln.c_str(), "%*s %ld", &rss); break; }
    char buf[64];
    snprintf(buf, sizeof(buf), "%.2f", rss / 1024.0);
    Tcl_SetObjResult(interp, Tcl_NewStringObj(buf, -1));
    return TCL_OK;
}

static int TclCmd_GetCPUUsage(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    (void)objc; (void)objv;
    std::ifstream st("/proc/self/stat");
    if (!st.is_open()) { Tcl_SetObjResult(interp, Tcl_NewStringObj("0", -1)); return TCL_OK; }
    std::string skip;
    for (int i = 0; i < 13; i++) st >> skip;
    long ut = 0, stt = 0;
    st >> ut >> stt;
    char buf[32];
    snprintf(buf, sizeof(buf), "%.1f", (double)(ut + stt) / 100.0);
    Tcl_SetObjResult(interp, Tcl_NewStringObj(buf, -1));
    return TCL_OK;
}

static int TclCmd_VerifyDBs(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    (void)objc; (void)objv;
    Tcl_Obj* list = Tcl_NewListObj(0, nullptr);
    Tcl_ListObjAppendElement(interp, list, Tcl_NewStringObj(db_exists(g_books_db) ? "OK" : "MISSING", -1));
    Tcl_ListObjAppendElement(interp, list, Tcl_NewStringObj(db_exists(g_readers_db) ? "OK" : "MISSING", -1));
    Tcl_ListObjAppendElement(interp, list, Tcl_NewStringObj(db_exists(g_loans_db) ? "OK" : "MISSING", -1));
    Tcl_SetObjResult(interp, list);
    return TCL_OK;
}

static int TclCmd_SetSetting(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    if (objc != 3) { Tcl_WrongNumArgs(interp, 1, objv, "key value"); return TCL_ERROR; }
    const char* key = Tcl_GetStringFromObj(objv[1], nullptr);
    const char* val = Tcl_GetStringFromObj(objv[2], nullptr);
    if (strcmp(key, "language") == 0) g_default_language = val;
    else if (strcmp(key, "save_worklogs") == 0) g_save_worklogs = (strcmp(val, "1") == 0);
    else if (strcmp(key, "enable_networking") == 0) g_enable_networking = (strcmp(val, "1") == 0);
    else if (strcmp(key, "enable_same_ids") == 0) g_enable_same_ids = (strcmp(val, "1") == 0);
    else if (strcmp(key, "check_loans") == 0) g_check_loans = (strcmp(val, "1") == 0);
    else if (strcmp(key, "loan_duration") == 0) g_default_loan_duration = atoi(val);
    save_settings();
    return TCL_OK;
}

static int TclCmd_GetSetting(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    if (objc != 2) { Tcl_WrongNumArgs(interp, 1, objv, "key"); return TCL_ERROR; }
    const char* key = Tcl_GetStringFromObj(objv[1], nullptr);
    const char* val = "";
    if (strcmp(key, "language") == 0) val = g_default_language.c_str();
    else if (strcmp(key, "save_worklogs") == 0) val = g_save_worklogs ? "1" : "0";
    else if (strcmp(key, "enable_networking") == 0) val = g_enable_networking ? "1" : "0";
    else if (strcmp(key, "enable_same_ids") == 0) val = g_enable_same_ids ? "1" : "0";
    else if (strcmp(key, "check_loans") == 0) val = g_check_loans ? "1" : "0";
    else if (strcmp(key, "loan_duration") == 0) { char b[16]; snprintf(b, sizeof(b), "%d", g_default_loan_duration); Tcl_SetObjResult(interp, Tcl_NewStringObj(b, -1)); return TCL_OK; }
    else { Tcl_SetObjResult(interp, Tcl_NewStringObj("", -1)); return TCL_OK; }
    Tcl_SetObjResult(interp, Tcl_NewStringObj(val, -1));
    return TCL_OK;
}

static int TclCmd_Backup(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    if (objc != 2) { Tcl_WrongNumArgs(interp, 1, objv, "dest_dir"); return TCL_ERROR; }
    const char* d = Tcl_GetStringFromObj(objv[1], nullptr);
    Tcl_SetObjResult(interp, Tcl_NewIntObj(backup_file(g_books_db, d)));
    return TCL_OK;
}

static int TclCmd_GetDBPaths(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    (void)objc; (void)objv;
    Tcl_Obj* list = Tcl_NewListObj(0, nullptr);
    Tcl_ListObjAppendElement(interp, list, Tcl_NewStringObj(g_books_db.c_str(), (int)g_books_db.size()));
    Tcl_ListObjAppendElement(interp, list, Tcl_NewStringObj(g_readers_db.c_str(), (int)g_readers_db.size()));
    Tcl_ListObjAppendElement(interp, list, Tcl_NewStringObj(g_loans_db.c_str(), (int)g_loans_db.size()));
    Tcl_SetObjResult(interp, list);
    return TCL_OK;
}

static int TclCmd_SetDBPath(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    if (objc != 3) { Tcl_WrongNumArgs(interp, 1, objv, "which path"); return TCL_ERROR; }
    const char* w = Tcl_GetStringFromObj(objv[1], nullptr);
    const char* p = Tcl_GetStringFromObj(objv[2], nullptr);
    if (strcmp(w, "books") == 0) g_books_db = p;
    else if (strcmp(w, "readers") == 0) g_readers_db = p;
    else if (strcmp(w, "loans") == 0) g_loans_db = p;
    return TCL_OK;
}

static int TclCmd_GetLoanField(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    if (objc != 3) { Tcl_WrongNumArgs(interp, 1, objv, "book_id field_index"); return TCL_ERROR; }
    int fi; if (Tcl_GetIntFromObj(interp, objv[2], &fi) != TCL_OK) return TCL_ERROR;
    std::string v = get_loan_field(Tcl_GetStringFromObj(objv[1], nullptr), fi);
    Tcl_SetObjResult(interp, Tcl_NewStringObj(v.c_str(), (int)v.size()));
    return TCL_OK;
}

static int TclCmd_ResetSettings(ClientData, Tcl_Interp* interp, int objc, Tcl_Obj* const objv[])
{
    (void)objc; (void)objv;
    g_default_language = "English-US"; g_save_worklogs = true;
    g_enable_networking = false; g_enable_same_ids = false;
    g_check_loans = true; g_default_loan_duration = 14;
    save_settings();
    return TCL_OK;
}

// ---------- registration ----------

static void register_commands(Tcl_Interp* interp)
{
    auto reg = [&](const char* name, Tcl_ObjCmdProc* proc) {
        Tcl_CreateObjCommand(interp, name, proc, nullptr, nullptr);
    };
    reg("shelf_login",            TclCmd_Login);
    reg("shelf_register",         TclCmd_Register);
    reg("shelf_add_book",         TclCmd_AddBook);
    reg("shelf_get_book",         TclCmd_GetBook);
    reg("shelf_edit_book",        TclCmd_EditBook);
    reg("shelf_delete_book",      TclCmd_DeleteBook);
    reg("shelf_list_books",       TclCmd_ListBooks);
    reg("shelf_search_books",     TclCmd_SearchBooks);
    reg("shelf_get_categories",   TclCmd_GetCategories);
    reg("shelf_add_category",     TclCmd_AddCategory);
    reg("shelf_remove_category",  TclCmd_RemoveCategory);
    reg("shelf_add_reader",       TclCmd_AddReader);
    reg("shelf_edit_reader",      TclCmd_EditReader);
    reg("shelf_delete_reader",    TclCmd_DeleteReader);
    reg("shelf_get_reader",       TclCmd_GetReader);
    reg("shelf_list_readers",     TclCmd_ListReaders);
    reg("shelf_import_readers",   TclCmd_ImportReaders);
    reg("shelf_add_loan",         TclCmd_AddLoan);
    reg("shelf_return_loan",      TclCmd_ReturnLoan);
    reg("shelf_get_loan",         TclCmd_GetLoan);
    reg("shelf_list_loans",       TclCmd_ListLoans);
    reg("shelf_delete_loan",      TclCmd_DeleteLoan);
    reg("shelf_mark_lost",        TclCmd_MarkLost);
    reg("shelf_prolong",          TclCmd_Prolong);
    reg("shelf_get_current_date", TclCmd_GetCurrentDate);
    reg("shelf_add_days",         TclCmd_AddDays);
    reg("shelf_book_id_exists",   TclCmd_BookIdExists);
    reg("shelf_reader_exists",    TclCmd_ReaderExists);
    reg("shelf_loan_id_exists",   TclCmd_LoanIdExists);
    reg("shelf_load_settings",    TclCmd_LoadSettings);
    reg("shelf_save_settings",    TclCmd_SaveSettings);
    reg("shelf_get_resource_usage", TclCmd_GetResourceUsage);
    reg("shelf_get_cpu_usage",    TclCmd_GetCPUUsage);
    reg("shelf_verify_dbs",       TclCmd_VerifyDBs);
    reg("shelf_set_setting",      TclCmd_SetSetting);
    reg("shelf_get_setting",      TclCmd_GetSetting);
    reg("shelf_backup",           TclCmd_Backup);
    reg("shelf_get_db_paths",     TclCmd_GetDBPaths);
    reg("shelf_set_db_path",      TclCmd_SetDBPath);
    reg("shelf_get_loan_field",   TclCmd_GetLoanField);
    reg("shelf_reset_settings",   TclCmd_ResetSettings);
}

// ---------- embedded Tcl/Tk script ----------

static const char* tcl_script = R"tcl(
proc show_view {name} {
    foreach w [winfo children .content] { destroy $w }
    set f .content.$name
    make_view_$name $f
    pack $f -fill both -expand 1
}

proc set_msg {msg} {
    .status.msg configure -text $msg
    after 3000 {.status.msg configure -text "Ready"}
}

proc update_ram {} {
    catch {
        set ram [shelf_get_resource_usage]
        .status.ram configure -text "RAM: ${ram} MB"
    }
    after 1000 update_ram
}

proc update_cpu {} {
    catch {
        set cpu [shelf_get_cpu_usage]
        .status.cpu configure -text "CPU: ${cpu} ms"
    }
    after 1000 update_cpu
}

proc bind_entry_enter {w cmd} { bind $w <Key-Return> $cmd }

proc fill_listbox {lb data} {
    $lb delete 0 end
    foreach item $data { $lb insert end $item }
}

proc make_entry_row {f label var} {
    ttk::label $f.l -text $label -width 15 -anchor e
    ttk::entry $f.e -textvariable $var
    pack $f.l -side left
    pack $f.e -side left -fill x -expand 1
    return $f.e
}

# ---- Login ----
proc make_view_login {f} {
    ttk::frame $f; ttk::label $f.title -text "Login" -font {TkDefaultFont 14 bold}
    pack $f.title -pady 10
    ttk::frame $f.f1; set ::login_user ""; make_entry_row $f.f1 "Username" ::login_user
    ttk::frame $f.f2; set ::login_pass ""; make_entry_row $f.f2 "Password" ::login_pass; $f.f2.e configure -show *
    pack $f.f1 $f.f2 -fill x -pady 4 -padx 20
    ttk::frame $f.btns
    ttk::button $f.btns.login -text "Login" -command {shelf_login $::login_user $::login_pass; set_msg "Login attempted"}
    ttk::button $f.btns.reg -text "Register" -command {show_view register}
    pack $f.btns.login $f.btns.reg -side left -padx 5
    pack $f.btns -pady 10
}

# ---- Register ----
proc make_view_register {f} {
    ttk::frame $f; ttk::label $f.title -text "Register" -font {TkDefaultFont 14 bold}
    pack $f.title -pady 10
    ttk::frame $f.f1; set ::reg_user ""; make_entry_row $f.f1 "Username" ::reg_user
    ttk::frame $f.f2; set ::reg_pass ""; make_entry_row $f.f2 "Password" ::reg_pass; $f.f2.e configure -show *
    ttk::frame $f.f3; set ::reg_conf ""; make_entry_row $f.f3 "Confirm" ::reg_conf; $f.f3.e configure -show *
    pack $f.f1 $f.f2 $f.f3 -fill x -pady 4 -padx 20
    ttk::frame $f.btns
    ttk::button $f.btns.reg -text "Register" -command {shelf_register $::reg_user $::reg_pass $::reg_conf; set_msg "Register attempted"}
    ttk::button $f.btns.back -text "Back" -command {show_view login}
    pack $f.btns.reg $f.btns.back -side left -padx 5
    pack $f.btns -pady 10
}

# ---- Add Book ----
proc make_view_add_book {f} {
    ttk::frame $f; ttk::label $f.title -text "Add Book" -font {TkDefaultFont 14 bold}
    pack $f.title -pady 10
    set ::ab_title ""; set ::ab_author ""; set ::ab_isbn ""; set ::ab_id ""
    ttk::frame $f.f1; make_entry_row $f.f1 "Title" ::ab_title
    ttk::frame $f.f2; make_entry_row $f.f2 "Author" ::ab_author
    ttk::frame $f.f3; make_entry_row $f.f3 "ISBN" ::ab_isbn
    ttk::frame $f.f4; make_entry_row $f.f4 "ID" ::ab_id
    pack $f.f1 $f.f2 $f.f3 $f.f4 -fill x -pady 4 -padx 20
    ttk::frame $f.f5
    ttk::label $f.f5.l -text "Category" -width 15 -anchor e
    set ::ab_cat [ttk::combobox $f.f5.cb -values [shelf_get_categories] -state readonly]
    pack $f.f5.l -side left; pack $f.f5.cb -side left -fill x -expand 1
    ttk::frame $f.f6
    ttk::label $f.f6.l -text "Status" -width 15 -anchor e
    set ::ab_st [ttk::combobox $f.f6.cb -values {Available "Checked Out" Reserved Damaged Lost} -state readonly]
    $f.f6.cb current 0
    pack $f.f6.l -side left; pack $f.f6.cb -side left -fill x -expand 1
    pack $f.f5 $f.f6 -fill x -pady 4 -padx 20
    ttk::button $f.btn -text "Add" -command {
        if {$::ab_id ne "" && $::ab_title ne "" && $::ab_author ne ""} {
            if {[shelf_get_setting enable_same_ids] eq "0" && [shelf_book_id_exists $::ab_id]} {
                set ans [tk_messageBox -type yesno -icon warning -title "Duplicate ID" -message "Book ID \"$::ab_id\" already exists.\nAdd anyway?"]
                if {$ans eq "no"} return
            }
            shelf_add_book $::ab_title $::ab_author $::ab_isbn $::ab_id [$::ab_cat get] [$::ab_st get]
            set_msg "Book added"
        } { set_msg "Title, author, and ID required" }
    }
    pack $f.btn -pady 10
}

# ---- Edit Book ----
proc make_view_edit_book {f} {
    ttk::frame $f; ttk::label $f.title -text "Edit Book" -font {TkDefaultFont 14 bold}
    pack $f.title -pady 10
    set ::eb_id ""; ttk::frame $f.f1; make_entry_row $f.f1 "Book ID" ::eb_id
    pack $f.f1 -fill x -pady 4 -padx 20
    ttk::button $f.chk -text "Check" -command {
        if {[shelf_book_id_exists $::eb_id]} { set_msg "Book found" } { set_msg "Book not found" }
    }
    pack $f.chk -pady 4
    set ::eb_title ""; set ::eb_author ""; set ::eb_isbn ""; set ::eb_cat ""; set ::eb_st ""
    ttk::frame $f.f2; make_entry_row $f.f2 "New Title" ::eb_title
    ttk::frame $f.f3; make_entry_row $f.f3 "New Author" ::eb_author
    ttk::frame $f.f4; make_entry_row $f.f4 "New ISBN" ::eb_isbn
    ttk::frame $f.f5
    ttk::label $f.f5.l -text "New Category" -width 15 -anchor e
    set ::eb_cat_cb [ttk::combobox $f.f5.cb -values [shelf_get_categories] -state readonly]
    pack $f.f5.l -side left; pack $f.f5.cb -side left -fill x -expand 1
    ttk::frame $f.f6
    ttk::label $f.f6.l -text "New Status" -width 15 -anchor e
    set ::eb_st_cb [ttk::combobox $f.f6.cb -values {Available "Checked Out" Reserved Damaged Lost} -state readonly]
    pack $f.f6.l -side left; pack $f.f6.cb -side left -fill x -expand 1
    pack $f.f2 $f.f3 $f.f4 $f.f5 $f.f6 -fill x -pady 4 -padx 20
    ttk::button $f.btn -text "Edit" -command {
        shelf_edit_book $::eb_id $::eb_title $::eb_author $::eb_isbn [$::eb_cat_cb get] [$::eb_st_cb get]
        set_msg "Book updated"
    }
    pack $f.btn -pady 10
}

# ---- Delete Book ----
proc make_view_delete_book {f} {
    ttk::frame $f; ttk::label $f.title -text "Delete Book" -font {TkDefaultFont 14 bold}
    pack $f.title -pady 10
    set ::db_id ""; ttk::frame $f.f1; make_entry_row $f.f1 "Book ID" ::db_id
    pack $f.f1 -fill x -pady 4 -padx 20
    ttk::button $f.chk -text "Check" -command {
        if {[shelf_book_id_exists $::db_id]} { set_msg "Book found" } { set_msg "Book not found" }
    }
    pack $f.chk -pady 4
    ttk::button $f.del -text "Delete" -command {
        if {[shelf_book_id_exists $::db_id]} {
            set ans [tk_messageBox -type yesno -icon question -message "Delete book $::db_id?"]
            if {$ans eq "yes"} { shelf_delete_book $::db_id; set_msg "Book deleted" }
        } { set_msg "Book not found" }
    }
    pack $f.del -pady 10
}

# ---- Manage Categories ----
proc make_view_categories {f} {
    ttk::frame $f; ttk::label $f.title -text "Manage Categories" -font {TkDefaultFont 14 bold}
    pack $f.title -pady 10
    ttk::frame $f.lf
    set ::cat_lb [listbox $f.lf.lb -height 8 -width 40 -exportselection 0]
    ttk::scrollbar $f.lf.sb -command [list $::cat_lb yview]
    $::cat_lb configure -yscrollcommand [list $f.lf.sb set]
    pack $f.lf.sb -side right -fill y; pack $f.lf.lb -side left -fill both -expand 1
    pack $f.lf -fill both -expand 1 -padx 20
    ttk::frame $f.btns
    ttk::button $f.btns.ref -text "Refresh" -command {fill_listbox $::cat_lb [shelf_get_categories]}
    ttk::button $f.btns.del -text "Remove Selected" -command {
        set sel [$::cat_lb curselection]
        if {$sel ne ""} { shelf_remove_category $sel; fill_listbox $::cat_lb [shelf_get_categories]; set_msg "Removed" }
    }
    pack $f.btns.ref $f.btns.del -side left -padx 5
    ttk::frame $f.f1; set ::cat_new ""; make_entry_row $f.f1 "New Category" ::cat_new
    pack $f.btns -pady 4
    pack $f.f1 -fill x -pady 4 -padx 20
    bind_entry_enter $f.f1.e {shelf_add_category $::cat_new; fill_listbox $::cat_lb [shelf_get_categories]; set_msg "Added"; set ::cat_new ""}
    ttk::button $f.add -text "Add Category" -command {shelf_add_category $::cat_new; fill_listbox $::cat_lb [shelf_get_categories]; set_msg "Added"; set ::cat_new ""}
    pack $f.add -pady 4
}

# ---- Add Reader ----
proc make_view_add_reader {f} {
    ttk::frame $f; ttk::label $f.title -text "Add Reader" -font {TkDefaultFont 14 bold}
    pack $f.title -pady 10
    set ::ar_n ""; set ::ar_s ""; set ::ar_g ""; set ::ar_c ""
    ttk::frame $f.f1; make_entry_row $f.f1 "Name" ::ar_n
    ttk::frame $f.f2; make_entry_row $f.f2 "Surname" ::ar_s
    ttk::frame $f.f3; make_entry_row $f.f3 "Grade" ::ar_g
    ttk::frame $f.f4; make_entry_row $f.f4 "Class" ::ar_c
    pack $f.f1 $f.f2 $f.f3 $f.f4 -fill x -pady 4 -padx 20
    ttk::button $f.btn -text "Add Reader" -command {
        if {$::ar_n ne "" && $::ar_s ne ""} {
            if {[shelf_reader_exists $::ar_n $::ar_s]} { set_msg "Reader already exists" } {
                shelf_add_reader $::ar_n $::ar_s $::ar_g $::ar_c; set_msg "Reader added"
                set ::ar_n ""; set ::ar_s ""; set ::ar_g ""; set ::ar_c ""
            }
        } { set_msg "Name and surname required" }
    }
    pack $f.btn -pady 10
}

# ---- Edit Reader ----
proc make_view_edit_reader {f} {
    ttk::frame $f; ttk::label $f.title -text "Edit Reader" -font {TkDefaultFont 14 bold}
    pack $f.title -pady 10
    set ::er_on ""; set ::er_os ""
    ttk::frame $f.f1; make_entry_row $f.f1 "Current Name" ::er_on
    ttk::frame $f.f2; make_entry_row $f.f2 "Current Surname" ::er_os
    pack $f.f1 $f.f2 -fill x -pady 4 -padx 20
    ttk::button $f.chk -text "Check" -command {
        if {[shelf_reader_exists $::er_on $::er_os]} { set_msg "Reader found" } { set_msg "Reader not found" }
    }
    pack $f.chk -pady 4
    set ::er_nn ""; set ::er_ns ""; set ::er_ng ""; set ::er_nc ""
    ttk::frame $f.f3; make_entry_row $f.f3 "New Name" ::er_nn
    ttk::frame $f.f4; make_entry_row $f.f4 "New Surname" ::er_ns
    ttk::frame $f.f5; make_entry_row $f.f5 "New Grade" ::er_ng
    ttk::frame $f.f6; make_entry_row $f.f6 "New Class" ::er_nc
    pack $f.f3 $f.f4 $f.f5 $f.f6 -fill x -pady 4 -padx 20
    ttk::button $f.btn -text "Edit" -command {
        shelf_edit_reader $::er_on $::er_os $::er_nn $::er_ns $::er_ng $::er_nc; set_msg "Reader updated"
    }
    pack $f.btn -pady 10
}

# ---- Delete Reader ----
proc make_view_delete_reader {f} {
    ttk::frame $f; ttk::label $f.title -text "Delete Reader" -font {TkDefaultFont 14 bold}
    pack $f.title -pady 10
    set ::dr_n ""; set ::dr_s ""
    ttk::frame $f.f1; make_entry_row $f.f1 "Name" ::dr_n
    ttk::frame $f.f2; make_entry_row $f.f2 "Surname" ::dr_s
    pack $f.f1 $f.f2 -fill x -pady 4 -padx 20
    ttk::button $f.chk -text "Check" -command {
        if {[shelf_reader_exists $::dr_n $::dr_s]} { set_msg "Reader found" } { set_msg "Reader not found" }
    }
    pack $f.chk -pady 4
    ttk::button $f.del -text "Delete" -command {
        if {[shelf_reader_exists $::dr_n $::dr_s]} {
            set ans [tk_messageBox -type yesno -icon question -message "Delete $::dr_n $::dr_s?"]
            if {$ans eq "yes"} { shelf_delete_reader $::dr_n $::dr_s; set_msg "Reader deleted" }
        } { set_msg "Reader not found" }
    }
    pack $f.del -pady 10
}

# ---- Import Readers ----
proc make_view_import_readers {f} {
    ttk::frame $f; ttk::label $f.title -text "Import Readers" -font {TkDefaultFont 14 bold}
    pack $f.title -pady 10
    set ::ir_fn ""; ttk::frame $f.f1; make_entry_row $f.f1 "Source File" ::ir_fn
    pack $f.f1 -fill x -pady 4 -padx 20
    ttk::button $f.btn -text "Import" -command {
        if {$::ir_fn ne ""} { set res [shelf_import_readers $::ir_fn]; set_msg $res }
    }
    pack $f.btn -pady 10
}

# ---- Add Loan ----
proc make_view_add_loan {f} {
    ttk::frame $f; ttk::label $f.title -text "Add Loan" -font {TkDefaultFont 14 bold}
    pack $f.title -pady 10
    set ::al_bid ""; set ::al_rn ""; set ::al_rs ""; set ::al_dur 14
    ttk::frame $f.f1; make_entry_row $f.f1 "Book ID" ::al_bid
    ttk::frame $f.f2; make_entry_row $f.f2 "Reader Name" ::al_rn
    ttk::frame $f.f3; make_entry_row $f.f3 "Reader Surname" ::al_rs
    ttk::frame $f.f4
    ttk::label $f.f4.l -text "Duration (days)" -width 15 -anchor e
    ttk::entry $f.f4.e -textvariable ::al_dur -width 8
    pack $f.f4.l -side left; pack $f.f4.e -side left
    pack $f.f1 $f.f2 $f.f3 $f.f4 -fill x -pady 4 -padx 20
    ttk::button $f.btn -text "Add Loan" -command {
        if {$::al_bid eq ""} { set_msg "Enter book ID"; return }
        if {$::al_rn eq "" || $::al_rs eq ""} { set_msg "Enter reader name/surname"; return }
        if {![shelf_book_id_exists $::al_bid]} { set_msg "Book not found"; return }
        if {[shelf_loan_id_exists $::al_bid]} { set_msg "Book already on loan"; return }
        if {![shelf_reader_exists $::al_rn $::al_rs]} { set_msg "Reader not found"; return }
        set today [shelf_get_current_date]
        set exp [shelf_add_days $today $::al_dur]
        shelf_add_loan $::al_bid "$::al_rn $::al_rs" $today $exp
        set_msg "Loan added, expires $exp"
    }
    pack $f.btn -pady 10
}

# ---- Return Loan ----
proc make_view_return_loan {f} {
    ttk::frame $f; ttk::label $f.title -text "Return Loan" -font {TkDefaultFont 14 bold}
    pack $f.title -pady 10
    set ::rl_bid ""; ttk::frame $f.f1; make_entry_row $f.f1 "Book ID" ::rl_bid
    pack $f.f1 -fill x -pady 4 -padx 20
    ttk::button $f.chk -text "Check" -command {
        if {[shelf_loan_id_exists $::rl_bid]} { set_msg "Active loan" } { set_msg "Loan not found" }
    }
    pack $f.chk -pady 4
    ttk::button $f.ret -text "Return" -command {
        if {[shelf_loan_id_exists $::rl_bid]} { shelf_return_loan $::rl_bid; set_msg "Loan returned" } { set_msg "Loan not found" }
    }
    pack $f.ret -pady 10
}

# ---- List Loans ----
proc make_view_list_loans {f} {
    ttk::frame $f; ttk::label $f.title -text "Active Loans" -font {TkDefaultFont 14 bold}
    pack $f.title -pady 10
    ttk::frame $f.lf
    set ::ll_lb [listbox $f.lf.lb -height 12 -width 80 -font {TkFixedFont 9}]
    ttk::scrollbar $f.lf.sb -command [list $::ll_lb yview]
    $::ll_lb configure -yscrollcommand [list $f.lf.sb set]
    pack $f.lf.sb -side right -fill y; pack $f.lf.lb -side left -fill both -expand 1
    pack $f.lf -fill both -expand 1 -padx 20 -pady 4
    ttk::button $f.ref -text "Refresh" -command {
        fill_listbox $::ll_lb [shelf_list_loans]
    }
    pack $f.ref -pady 4
}

# ---- Edit Loan ----
proc make_view_edit_loan {f} {
    ttk::frame $f; ttk::label $f.title -text "Edit Loan" -font {TkDefaultFont 14 bold}
    pack $f.title -pady 10
    set ::el_bid ""; ttk::frame $f.f1; make_entry_row $f.f1 "Loan ID (Book ID)" ::el_bid
    pack $f.f1 -fill x -pady 4 -padx 20
    ttk::button $f.chk -text "Check" -command {
        if {[shelf_loan_id_exists $::el_bid]} { set_msg "Loan found" } { set_msg "Loan not found" }
    }
    pack $f.chk -pady 4
    set ::el_nbid ""; set ::el_nrdr ""
    ttk::frame $f.f2; make_entry_row $f.f2 "New Book ID" ::el_nbid
    ttk::frame $f.f3; make_entry_row $f.f3 "New Reader" ::el_nrdr
    pack $f.f2 $f.f3 -fill x -pady 4 -padx 20
    ttk::button $f.upd -text "Update" -command {
        if {[shelf_loan_id_exists $::el_bid]} {
            if {$::el_nbid ne ""} { shelf_set_db_path "dummy" 0 }; set_msg "Loan updated (stub)"
        } { set_msg "Loan not found" }
    }
    pack $f.upd -pady 10
}

# ---- Remove Loan ----
proc make_view_remove_loan {f} {
    ttk::frame $f; ttk::label $f.title -text "Remove Loan" -font {TkDefaultFont 14 bold}
    pack $f.title -pady 10
    set ::rlb_bid ""; ttk::frame $f.f1; make_entry_row $f.f1 "Loan ID (Book ID)" ::rlb_bid
    pack $f.f1 -fill x -pady 4 -padx 20
    ttk::button $f.del -text "Remove" -command {
        if {[shelf_loan_id_exists $::rlb_bid]} {
            set ans [tk_messageBox -type yesno -icon question -message "Remove loan $::rlb_bid?"]
            if {$ans eq "yes"} { shelf_delete_loan $::rlb_bid; set_msg "Loan removed" }
        } { set_msg "Loan not found" }
    }
    pack $f.del -pady 10
}

# ---- Mark Lost ----
proc make_view_mark_lost {f} {
    ttk::frame $f; ttk::label $f.title -text "Mark Lost" -font {TkDefaultFont 14 bold}
    pack $f.title -pady 10
    set ::ml_bid ""; ttk::frame $f.f1; make_entry_row $f.f1 "Loan ID (Book ID)" ::ml_bid
    pack $f.f1 -fill x -pady 4 -padx 20
    ttk::button $f.btn -text "Mark Lost" -command {
        if {[shelf_loan_id_exists $::ml_bid]} {
            set st [shelf_get_loan_field $::ml_bid 4]
            if {$st eq "lost"} { set_msg "Already lost" } { shelf_mark_lost $::ml_bid; set_msg "Marked lost" }
        } { set_msg "Loan not found" }
    }
    pack $f.btn -pady 10
}

# ---- Prolong ----
proc make_view_prolong {f} {
    ttk::frame $f; ttk::label $f.title -text "Prolong Loan" -font {TkDefaultFont 14 bold}
    pack $f.title -pady 10
    set ::pl_bid ""; set ::pl_days 14
    ttk::frame $f.f1; make_entry_row $f.f1 "Loan ID (Book ID)" ::pl_bid
    ttk::frame $f.f2
    ttk::label $f.f2.l -text "Extra Days" -width 15 -anchor e
    ttk::entry $f.f2.e -textvariable ::pl_days -width 8
    pack $f.f2.l -side left; pack $f.f2.e -side left
    pack $f.f1 $f.f2 -fill x -pady 4 -padx 20
    ttk::button $f.btn -text "Prolong" -command {
        if {[shelf_loan_id_exists $::pl_bid]} {
            set st [shelf_get_loan_field $::pl_bid 4]
            if {$st eq "returned" || $st eq "lost"} { set_msg "Cannot prolong" } {
                set nd [shelf_prolong $::pl_bid $::pl_days]; set_msg "Prolonged to $nd"
            }
        } { set_msg "Loan not found" }
    }
    pack $f.btn -pady 10
}

# ---- Expired ----
proc make_view_expired {f} {
    ttk::frame $f; ttk::label $f.title -text "Expired Loans" -font {TkDefaultFont 14 bold}
    pack $f.title -pady 10
    ttk::frame $f.lf
    set ::ex_lb [listbox $f.lf.lb -height 12 -width 80 -font {TkFixedFont 9} -fg red]
    ttk::scrollbar $f.lf.sb -command [list $::ex_lb yview]
    $::ex_lb configure -yscrollcommand [list $f.lf.sb set]
    pack $f.lf.sb -side right -fill y; pack $f.lf.lb -side left -fill both -expand 1
    pack $f.lf -fill both -expand 1 -padx 20 -pady 4
    ttk::button $f.ref -text "Refresh" -command {
        $::ex_lb delete 0 end
        set today [shelf_get_current_date]
        set count 0
        foreach loan [shelf_list_loans] {
            set fields [split $loan "|"]
            if {[llength $fields] < 5} continue
            set exp [lindex $fields 3]
            set st [lindex $fields 4]
            if {$st eq "active" && $exp < $today} {
                $::ex_lb insert end "[lindex $fields 0] -> [lindex $fields 1] (exp: $exp)"
                incr count
            }
        }
        $::ex_lb insert end "Total expired: $count"
    }
    pack $f.ref -pady 4
}

# ---- Search Loans ----
proc make_view_search_loans {f} {
    ttk::frame $f; ttk::label $f.title -text "Search Loans" -font {TkDefaultFont 14 bold}
    pack $f.title -pady 10
    set ::sl_q ""; set ::sl_by 0
    ttk::frame $f.f0
    ttk::combobox $f.f0.cb -values {"Book ID" Reader} -state readonly -textvariable ::sl_by
    $f.f0.cb current 0
    ttk::frame $f.f1; make_entry_row $f.f1 "Query" ::sl_q
    pack $f.f0.cb -pady 4; pack $f.f1 -fill x -padx 20
    ttk::frame $f.lf
    set ::sl_lb [listbox $f.lf.lb -height 10 -width 80 -font {TkFixedFont 9}]
    ttk::scrollbar $f.lf.sb -command [list $::sl_lb yview]
    $::sl_lb configure -yscrollcommand [list $f.lf.sb set]
    pack $f.lf.sb -side right -fill y; pack $f.lf.lb -side left -fill both -expand 1
    pack $f.lf -fill both -expand 1 -padx 20 -pady 4
    ttk::button $f.sch -text "Search" -command {
        $::sl_lb delete 0 end; set count 0
        set q $::sl_q; set by [$::sl_by current]; if {$by eq ""} { set by 0 }
        foreach loan [shelf_list_loans] {
            set fields [split $loan "|"]
            if {[llength $fields] < 5} continue
            set f [lindex $fields $by]
            if {[string first $q $f] >= 0} { $::sl_lb insert end $loan; incr count }
        }
        $::sl_lb insert end "Found $count matches"
    }
    pack $f.sch -pady 4
}

# ---- Select DB ----
proc make_view_select_db {f} {
    ttk::frame $f; ttk::label $f.title -text "Database Selection" -font {TkDefaultFont 14 bold}
    pack $f.title -pady 10
    ttk::frame $f.info
    ttk::label $f.info.l1 -text "Books:   " -anchor w; ttk::label $f.info.v1 -textvariable ::sdb_b
    ttk::label $f.info.l2 -text "Readers: " -anchor w; ttk::label $f.info.v2 -textvariable ::sdb_r
    ttk::label $f.info.l3 -text "Loans:   " -anchor w; ttk::label $f.info.v3 -textvariable ::sdb_l
    grid $f.info.l1 $f.info.v1 -sticky w; grid $f.info.l2 $f.info.v2 -sticky w; grid $f.info.l3 $f.info.v3 -sticky w
    pack $f.info -padx 20 -pady 4
    ttk::button $f.ver -text "Verify" -command {
        set paths [shelf_get_db_paths]
        set status [shelf_verify_dbs]
        lassign $status bs rs ls
        set ::sdb_b "Books:   [lindex $paths 0] ($bs)"
        set ::sdb_r "Readers: [lindex $paths 1] ($rs)"
        set ::sdb_l "Loans:   [lindex $paths 2] ($ls)"
    }
    pack $f.ver -pady 4
    set ::sdb_nb ""; ttk::frame $f.f1; make_entry_row $f.f1 "New Books DB" ::sdb_nb
    set ::sdb_nr ""; ttk::frame $f.f2; make_entry_row $f.f2 "New Readers DB" ::sdb_nr
    set ::sdb_nl ""; ttk::frame $f.f3; make_entry_row $f.f3 "New Loans DB" ::sdb_nl
    pack $f.f1 $f.f2 $f.f3 -fill x -pady 4 -padx 20
    ttk::frame $f.btns
    ttk::button $f.btns.sb -text "Set Books" -command {if {$::sdb_nb ne ""} {shelf_set_db_path books $::sdb_nb; set_msg "Set"}}
    ttk::button $f.btns.sr -text "Set Readers" -command {if {$::sdb_nr ne ""} {shelf_set_db_path readers $::sdb_nr; set_msg "Set"}}
    ttk::button $f.btns.sl -text "Set Loans" -command {if {$::sdb_nl ne ""} {shelf_set_db_path loans $::sdb_nl; set_msg "Set"}}
    pack $f.btns.sb $f.btns.sr $f.btns.sl -side left -padx 5
    pack $f.btns -pady 4
}

# ---- Settings ----
proc make_view_settings_account {f} { ttk::frame $f; ttk::label $f.l -text "Account Settings\n(not yet implemented)"; pack $f.l -pady 20 }
proc make_view_settings_theme {f} {
    ttk::frame $f; ttk::label $f.title -text "Theme Settings" -font {TkDefaultFont 14 bold}
    pack $f.title -pady 10
    ttk::button $f.l -text "Light" -command {set_msg "Light (stub)"}; pack $f.l -pady 5
    ttk::button $f.d -text "Dark" -command {set_msg "Dark (stub)"}; pack $f.d -pady 5
}
proc make_view_settings_perf {f} { ttk::frame $f; ttk::label $f.l -text "Performance Settings\n(not yet implemented)"; pack $f.l -pady 20 }
proc make_view_settings_net {f} {
    ttk::frame $f; ttk::label $f.title -text "Networking" -font {TkDefaultFont 14 bold}
    pack $f.title -pady 10
    ttk::label $f.st -text "Networking settings"; pack $f.st -pady 5
    ttk::button $f.tog -text "Toggle" -command {
        shelf_set_setting enable_networking 1; set_msg "Toggled"
    }
    pack $f.tog -pady 5
}
proc make_view_settings_other {f} {
    ttk::frame $f; ttk::label $f.title -text "Other Settings" -font {TkDefaultFont 14 bold}
    pack $f.title -pady 10
    set ::oth_lang ""; set ::oth_dur 14
    ttk::frame $f.f1; make_entry_row $f.f1 "Language" ::oth_lang
    pack $f.f1 -fill x -pady 4 -padx 20
    ttk::frame $f.btns
    ttk::button $f.btns.lang -text "Set Language" -command {if {$::oth_lang ne ""} {shelf_set_setting language $::oth_lang; set_msg "Set"}}
    ttk::button $f.btns.wl -text "Toggle Worklogs" -command {shelf_set_setting save_worklogs 1; set_msg "Toggled"}
    ttk::button $f.btns.cl -text "Toggle Check Loans" -command {shelf_set_setting check_loans 1; set_msg "Toggled"}
    ttk::label $f.si_st -text "[expr {[shelf_get_setting enable_same_ids] eq "0" ? "Duplicate check: ON" : "Duplicate check: OFF"}]"
    pack $f.si_st -pady 2
    ttk::button $f.btns.si -text "Toggle Same IDs" -command {
        set cur [shelf_get_setting enable_same_ids]
        if {$cur eq "0"} { shelf_set_setting enable_same_ids 1; set_msg "Duplicate IDs: allowed"; .content.settings_other.si_st configure -text "Duplicate check: OFF" } { shelf_set_setting enable_same_ids 0; set_msg "Duplicate IDs: warned"; .content.settings_other.si_st configure -text "Duplicate check: ON" }
    }
    pack $f.btns.lang $f.btns.wl $f.btns.cl $f.btns.si -side left -padx 4; pack $f.btns -pady 4
    set ::oth_dur_e ""; ttk::frame $f.f2; make_entry_row $f.f2 "Duration (days)" ::oth_dur
    ttk::button $f.setd -text "Set Duration" -command {
        if {$::oth_dur > 0} {shelf_set_setting loan_duration $::oth_dur; set_msg "Set"}
    }
    pack $f.f2 -fill x -pady 4 -padx 20; pack $f.setd -pady 4
}
proc make_view_reset_settings {f} {
    ttk::frame $f; ttk::label $f.title -text "Reset Settings" -font {TkDefaultFont 14 bold}
    pack $f.title -pady 10
    ttk::button $f.btn -text "Reset" -command {
        set ans [tk_messageBox -type yesno -icon warning -message "Reset all settings to defaults?"]
        if {$ans eq "yes"} {shelf_reset_settings; set_msg "Reset"}
    }
    pack $f.btn -pady 10
}

# ---- About ----
proc make_view_about {f} {
    ttk::frame $f
    ttk::label $f.t1 -text "ShelfSight v1.0" -font {TkDefaultFont 18 bold}
    ttk::label $f.t2 -text "Library Management System"
    ttk::label $f.t3 -text "Tcl/Tk GUI"
    ttk::label $f.t4 -text "Target: <8MB RAM, Win95-era CPU"
    pack $f.t1 $f.t2 $f.t3 $f.t4 -pady 8
}

# ---- Main window ----
wm title . "ShelfSight"
wm geometry . 800x600+100+100

# Toolbar
frame .toolbar -bd 1 -relief raised -height 28
pack .toolbar -side top -fill x

menu .toolbar.books_m -tearoff 0
.toolbar.books_m add command -label "Add Book"     -command {show_view add_book}
.toolbar.books_m add command -label "Edit Book"    -command {show_view edit_book}
.toolbar.books_m add command -label "Delete Book"  -command {show_view delete_book}
.toolbar.books_m add command -label "Categories"   -command {show_view categories}
tk::menubutton .toolbar.books -text "Books" -menu .toolbar.books_m -direction below

menu .toolbar.readers_m -tearoff 0
.toolbar.readers_m add command -label "Add Reader"    -command {show_view add_reader}
.toolbar.readers_m add command -label "Edit Reader"   -command {show_view edit_reader}
.toolbar.readers_m add command -label "Delete Reader" -command {show_view delete_reader}
.toolbar.readers_m add command -label "Import"        -command {show_view import_readers}
tk::menubutton .toolbar.readers -text "Readers" -menu .toolbar.readers_m -direction below

menu .toolbar.loans_m -tearoff 0
.toolbar.loans_m add command -label "Add Loan"      -command {show_view add_loan}
.toolbar.loans_m add command -label "Return"        -command {show_view return_loan}
.toolbar.loans_m add command -label "List"          -command {show_view list_loans}
.toolbar.loans_m add command -label "Edit"          -command {show_view edit_loan}
.toolbar.loans_m add command -label "Remove"        -command {show_view remove_loan}
.toolbar.loans_m add command -label "Mark Lost"     -command {show_view mark_lost}
.toolbar.loans_m add command -label "Prolong"       -command {show_view prolong}
.toolbar.loans_m add command -label "Expired"       -command {show_view expired}
.toolbar.loans_m add command -label "Search"        -command {show_view search_loans}
tk::menubutton .toolbar.loans -text "Loans" -menu .toolbar.loans_m -direction below

menu .toolbar.dbs_m -tearoff 0
.toolbar.dbs_m add command -label "Select DBs" -command {show_view select_db}
tk::menubutton .toolbar.dbs -text "DBs" -menu .toolbar.dbs_m -direction below

menu .toolbar.settings_m -tearoff 0
.toolbar.settings_m add command -label "Account"     -command {show_view settings_account}
.toolbar.settings_m add command -label "Theme"       -command {show_view settings_theme}
.toolbar.settings_m add command -label "Performance" -command {show_view settings_perf}
.toolbar.settings_m add command -label "Networking"  -command {show_view settings_net}
.toolbar.settings_m add command -label "Other"       -command {show_view settings_other}
.toolbar.settings_m add command -label "Reset"       -command {show_view reset_settings}
tk::menubutton .toolbar.settings -text "Settings" -menu .toolbar.settings_m -direction below

menu .toolbar.about_m -tearoff 0
.toolbar.about_m add command -label "About" -command {show_view about}
tk::menubutton .toolbar.about -text "About" -menu .toolbar.about_m -direction below

pack .toolbar.books .toolbar.readers .toolbar.loans .toolbar.dbs .toolbar.settings .toolbar.about -side left -padx 2

# Right side of toolbar: Login, Register, Exit
button .toolbar.login  -text "Login"    -command {show_view login}
button .toolbar.reg    -text "Register" -command {show_view register}
button .toolbar.exit   -text "Exit"     -command {destroy .}
pack .toolbar.exit   -side right -padx 4
pack .toolbar.reg    -side right -padx 2
pack .toolbar.login  -side right -padx 2

# Content area
frame .content -bg white
pack .content -fill both -expand 1

# Status bar
frame .status -bd 1 -relief sunken -height 25
pack .status -side bottom -fill x
label .status.msg -text "Ready" -anchor w
pack .status.msg -side left -fill x -expand 1
label .status.cpu -text "" -anchor e -fg green
pack .status.cpu -side right -padx 4
label .status.ram -text "" -anchor e -fg green
pack .status.ram -side right -padx 4

# Start with login view
show_view login
update_ram
update_cpu
)tcl";

// ---------- main entry point ----------

void gui_tcl_run()
{
    load_settings();
    Tcl_Interp* interp = Tcl_CreateInterp();
    Tcl_Init(interp);
    Tk_Init(interp);
    register_commands(interp);

    if (Tcl_Eval(interp, tcl_script) != TCL_OK)
    {
        fprintf(stderr, "Tcl error: %s\n", Tcl_GetStringResult(interp));
        Tcl_DeleteInterp(interp);
        return;
    }

    Tk_MainLoop();
    Tcl_DeleteInterp(interp);
}
