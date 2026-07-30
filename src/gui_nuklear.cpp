#define NK_IMPLEMENTATION
#define NK_INCLUDE_FIXED_TYPES
#define NK_INCLUDE_STANDARD_IO
#define NK_INCLUDE_DEFAULT_ALLOCATOR
#define NK_INCLUDE_VERTEX_BUFFER_OUTPUT
#define NK_INCLUDE_FONT_BAKING
#define NK_INCLUDE_DEFAULT_FONT
#include "nuklear.h"
#undef NK_IMPLEMENTATION

#include "gui_nuklear.h"
#include "file_man.h"
#include "glob_vars.h"

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>
#include <vector>
#include <fstream>
#include <sstream>
#include <GLFW/glfw3.h>

struct AppVertex { float pos[2]; float uv[2]; unsigned char col[4]; };

static struct nk_context g_ctx;
static struct nk_font_atlas g_atlas;
static GLuint g_font_tex;
static GLFWwindow* g_win;
static int g_ww, g_wh;

static void error_cb(int e, const char* d) { (void)e; fprintf(stderr, "GLFW: %s\n", d); }
static void scroll_cb(GLFWwindow* w, double dx, double dy) { (void)w; (void)dx; nk_input_scroll(&g_ctx, nk_vec2(0,(float)dy)); }
static void char_cb(GLFWwindow* w, unsigned int cp) { (void)w; nk_input_unicode(&g_ctx, cp); }

static void nk_new_frame()
{
    glfwPollEvents();
    glfwGetFramebufferSize(g_win, &g_ww, &g_wh);
    nk_input_begin(&g_ctx);
    double mx, my;
    glfwGetCursorPos(g_win, &mx, &my);
    nk_input_motion(&g_ctx, (int)mx, (int)my);
    nk_input_button(&g_ctx, NK_BUTTON_LEFT, (int)mx, (int)my,
        glfwGetMouseButton(g_win, GLFW_MOUSE_BUTTON_LEFT) == GLFW_PRESS);
    nk_input_button(&g_ctx, NK_BUTTON_MIDDLE, (int)mx, (int)my,
        glfwGetMouseButton(g_win, GLFW_MOUSE_BUTTON_MIDDLE) == GLFW_PRESS);
    nk_input_button(&g_ctx, NK_BUTTON_RIGHT, (int)mx, (int)my,
        glfwGetMouseButton(g_win, GLFW_MOUSE_BUTTON_RIGHT) == GLFW_PRESS);

    int s = glfwGetKey(g_win, GLFW_KEY_LEFT_SHIFT)||glfwGetKey(g_win, GLFW_KEY_RIGHT_SHIFT);
    nk_input_key(&g_ctx, NK_KEY_SHIFT, s);
    s = glfwGetKey(g_win, GLFW_KEY_LEFT_CONTROL)||glfwGetKey(g_win, GLFW_KEY_RIGHT_CONTROL);
    nk_input_key(&g_ctx, NK_KEY_CTRL, s);
    s = glfwGetKey(g_win, GLFW_KEY_DELETE); nk_input_key(&g_ctx, NK_KEY_DEL, s);
    s = glfwGetKey(g_win, GLFW_KEY_ENTER); nk_input_key(&g_ctx, NK_KEY_ENTER, s);
    s = glfwGetKey(g_win, GLFW_KEY_TAB); nk_input_key(&g_ctx, NK_KEY_TAB, s);
    s = glfwGetKey(g_win, GLFW_KEY_LEFT); nk_input_key(&g_ctx, NK_KEY_LEFT, s);
    s = glfwGetKey(g_win, GLFW_KEY_RIGHT); nk_input_key(&g_ctx, NK_KEY_RIGHT, s);
    s = glfwGetKey(g_win, GLFW_KEY_UP); nk_input_key(&g_ctx, NK_KEY_UP, s);
    s = glfwGetKey(g_win, GLFW_KEY_DOWN); nk_input_key(&g_ctx, NK_KEY_DOWN, s);
    s = glfwGetKey(g_win, GLFW_KEY_BACKSPACE); nk_input_key(&g_ctx, NK_KEY_BACKSPACE, s);
    s = glfwGetKey(g_win, GLFW_KEY_HOME); nk_input_key(&g_ctx, NK_KEY_TEXT_START, s);
    s = glfwGetKey(g_win, GLFW_KEY_END); nk_input_key(&g_ctx, NK_KEY_TEXT_END, s);
    nk_input_end(&g_ctx);
}

static GLuint upload_atlas(const void* img, int w, int h)
{
    GLuint tex;
    glGenTextures(1, &tex);
    glBindTexture(GL_TEXTURE_2D, tex);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, w, h, 0, GL_RGBA, GL_UNSIGNED_BYTE, img);
    return tex;
}

// --- OpenGL 1.1 immediate-mode renderer ---
static void nk_render()
{
    struct nk_buffer cmds, vbuf, ebuf;
    nk_buffer_init_fixed(&cmds, malloc(512*1024), 512*1024);
    nk_buffer_init_fixed(&vbuf, malloc(512*1024), 512*1024);
    nk_buffer_init_fixed(&ebuf, malloc(128*1024), 128*1024);

    struct nk_convert_config cfg;
    memset(&cfg, 0, sizeof(cfg));
    cfg.shape_AA = NK_ANTI_ALIASING_ON;
    cfg.line_AA = NK_ANTI_ALIASING_ON;
    cfg.circle_segment_count = 22;
    cfg.arc_segment_count = 22;
    cfg.curve_segment_count = 22;
    cfg.global_alpha = 1.0f;
    cfg.vertex_layout = (const struct nk_draw_vertex_layout_element[]) {
        {NK_VERTEX_POSITION, NK_FORMAT_FLOAT, NK_OFFSETOF(struct AppVertex, pos)},
        {NK_VERTEX_TEXCOORD, NK_FORMAT_FLOAT, NK_OFFSETOF(struct AppVertex, uv)},
        {NK_VERTEX_COLOR, NK_FORMAT_R8G8B8A8, NK_OFFSETOF(struct AppVertex, col)},
        {NK_VERTEX_LAYOUT_END}
    };
    cfg.vertex_size = sizeof(struct AppVertex);
    cfg.vertex_alignment = NK_ALIGNOF(struct AppVertex);
    cfg.tex_null = (nk_draw_null_texture){ nk_handle_id((int)g_font_tex) };

    nk_buffer_clear(&cmds); nk_buffer_clear(&vbuf); nk_buffer_clear(&ebuf);
    nk_convert(&g_ctx, &cmds, &vbuf, &ebuf, &cfg);

    glViewport(0, 0, g_ww, g_wh);
    glClear(GL_COLOR_BUFFER_BIT);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(0.0, (double)g_ww, (double)g_wh, 0.0, -1.0, 1.0);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_TEXTURE_2D);
    glDisable(GL_DEPTH_TEST);

    AppVertex* vtx = (AppVertex*)nk_buffer_memory(&vbuf);
    nk_draw_index* idx = (nk_draw_index*)nk_buffer_memory(&ebuf);
    const struct nk_draw_command* cmd = 0;
    nk_size offset = 0;

    nk_draw_foreach(cmd, &g_ctx, &cmds)
    {
        if (!cmd->elem_count) continue;
        glBindTexture(GL_TEXTURE_2D, (GLuint)(size_t)cmd->texture.id);
        glEnable(GL_SCISSOR_TEST);
        glScissor(
            (GLint)cmd->clip_rect.x,
            (GLint)(g_wh - (GLint)(cmd->clip_rect.y + cmd->clip_rect.h)),
            (GLint)cmd->clip_rect.w, (GLint)cmd->clip_rect.h);
        glBegin(GL_TRIANGLES);
        for (nk_size i = offset; i < offset + cmd->elem_count; i++)
        {
            AppVertex* v = &vtx[idx[i]];
            glColor4ub(v->col[0], v->col[1], v->col[2], v->col[3]);
            glTexCoord2f(v->uv[0], v->uv[1]);
            glVertex2f(v->pos[0], v->pos[1]);
        }
        glEnd();
        offset += cmd->elem_count;
    }

    glDisable(GL_SCISSOR_TEST);
    glDisable(GL_TEXTURE_2D);
    glDisable(GL_BLEND);

    free(nk_buffer_memory(&cmds));
    free(nk_buffer_memory(&vbuf));
    free(nk_buffer_memory(&ebuf));
}

// ----------- UI -----------

enum View { VIEW_LOGIN, VIEW_REGISTER, VIEW_ADD_BOOKS, VIEW_EDIT_BOOKS, VIEW_DELETE_BOOKS,
    VIEW_MANAGE_CATEGORIES, VIEW_ADD_READERS, VIEW_EDIT_READERS, VIEW_DELETE_READERS,
    VIEW_IMPORT_READERS, VIEW_ADD_LOANS, VIEW_RETURN_LOANS, VIEW_LIST_LOANS, VIEW_EDIT_LOANS,
    VIEW_REMOVE_LOANS, VIEW_MARK_LOST, VIEW_PROLONG, VIEW_EXPIRED, VIEW_SEARCH_LOANS,
    VIEW_SELECT_DB, VIEW_SETTINGS_ACCOUNT, VIEW_SETTINGS_THEME, VIEW_SETTINGS_PERF,
    VIEW_SETTINGS_NET, VIEW_SETTINGS_OTHER, VIEW_RESET_SETTINGS, VIEW_ABOUT };

static enum View g_view = VIEW_LOGIN;
static char g_buf[1024], g_buf2[1024], g_buf3[1024], g_buf4[1024];
static char g_msg[512];
static double g_msg_timer;
static int g_book_id, g_loan_id, g_cat_sel, g_status_sel, g_dur = 14;
static const char* g_statuses[] = {"Available","Checked Out","Reserved","Damaged","Lost"};

static void set_msg(const char* m)
{ strncpy(g_msg,m,sizeof(g_msg)-1); g_msg[sizeof(g_msg)-1]=0; g_msg_timer=glfwGetTime(); }

static void show_msg(struct nk_context* ctx)
{
    if (g_msg[0] && (glfwGetTime()-g_msg_timer)<3.0)
        nk_label_colored(ctx, g_msg, NK_TEXT_LEFT, nk_rgba(0,255,0,255));
}

static void menu_bar(struct nk_context* ctx)
{
    nk_menubar_begin(ctx);
    nk_layout_row_dynamic(ctx, 22, 7);
    if (nk_menu_begin_label(ctx, "Books", NK_TEXT_LEFT, nk_vec2(140,180)))
    {
        nk_layout_row_dynamic(ctx, 20, 1);
        if (nk_menu_item_label(ctx, "Add Book", NK_TEXT_LEFT))          g_view = VIEW_ADD_BOOKS;
        if (nk_menu_item_label(ctx, "Edit Book", NK_TEXT_LEFT))         g_view = VIEW_EDIT_BOOKS;
        if (nk_menu_item_label(ctx, "Delete Book", NK_TEXT_LEFT))       g_view = VIEW_DELETE_BOOKS;
        if (nk_menu_item_label(ctx, "Categories", NK_TEXT_LEFT))        g_view = VIEW_MANAGE_CATEGORIES;
        nk_menu_close(ctx);
    }
    if (nk_menu_begin_label(ctx, "Readers", NK_TEXT_LEFT, nk_vec2(140,180)))
    {
        nk_layout_row_dynamic(ctx, 20, 1);
        if (nk_menu_item_label(ctx, "Add Reader", NK_TEXT_LEFT))        g_view = VIEW_ADD_READERS;
        if (nk_menu_item_label(ctx, "Edit Reader", NK_TEXT_LEFT))       g_view = VIEW_EDIT_READERS;
        if (nk_menu_item_label(ctx, "Delete Reader", NK_TEXT_LEFT))     g_view = VIEW_DELETE_READERS;
        if (nk_menu_item_label(ctx, "Import", NK_TEXT_LEFT))            g_view = VIEW_IMPORT_READERS;
        nk_menu_close(ctx);
    }
    if (nk_menu_begin_label(ctx, "Loans", NK_TEXT_LEFT, nk_vec2(140,240)))
    {
        nk_layout_row_dynamic(ctx, 20, 1);
        if (nk_menu_item_label(ctx, "Add Loan", NK_TEXT_LEFT))          g_view = VIEW_ADD_LOANS;
        if (nk_menu_item_label(ctx, "Return", NK_TEXT_LEFT))            g_view = VIEW_RETURN_LOANS;
        if (nk_menu_item_label(ctx, "List", NK_TEXT_LEFT))              g_view = VIEW_LIST_LOANS;
        if (nk_menu_item_label(ctx, "Edit", NK_TEXT_LEFT))              g_view = VIEW_EDIT_LOANS;
        if (nk_menu_item_label(ctx, "Remove", NK_TEXT_LEFT))            g_view = VIEW_REMOVE_LOANS;
        if (nk_menu_item_label(ctx, "Mark Lost", NK_TEXT_LEFT))         g_view = VIEW_MARK_LOST;
        if (nk_menu_item_label(ctx, "Prolong", NK_TEXT_LEFT))           g_view = VIEW_PROLONG;
        if (nk_menu_item_label(ctx, "Expired", NK_TEXT_LEFT))           g_view = VIEW_EXPIRED;
        if (nk_menu_item_label(ctx, "Search", NK_TEXT_LEFT))            g_view = VIEW_SEARCH_LOANS;
        nk_menu_close(ctx);
    }
    if (nk_menu_begin_label(ctx, "DBs", NK_TEXT_LEFT, nk_vec2(140,60)))
    {
        nk_layout_row_dynamic(ctx, 20, 1);
        if (nk_menu_item_label(ctx, "Select DBs", NK_TEXT_LEFT))        g_view = VIEW_SELECT_DB;
        nk_menu_close(ctx);
    }
    if (nk_menu_begin_label(ctx, "Settings", NK_TEXT_LEFT, nk_vec2(140,200)))
    {
        nk_layout_row_dynamic(ctx, 20, 1);
        if (nk_menu_item_label(ctx, "Account", NK_TEXT_LEFT))           g_view = VIEW_SETTINGS_ACCOUNT;
        if (nk_menu_item_label(ctx, "Theme", NK_TEXT_LEFT))             g_view = VIEW_SETTINGS_THEME;
        if (nk_menu_item_label(ctx, "Performance", NK_TEXT_LEFT))       g_view = VIEW_SETTINGS_PERF;
        if (nk_menu_item_label(ctx, "Networking", NK_TEXT_LEFT))        g_view = VIEW_SETTINGS_NET;
        if (nk_menu_item_label(ctx, "Other", NK_TEXT_LEFT))             g_view = VIEW_SETTINGS_OTHER;
        if (nk_menu_item_label(ctx, "Reset", NK_TEXT_LEFT))             g_view = VIEW_RESET_SETTINGS;
        nk_menu_close(ctx);
    }
    if (nk_menu_begin_label(ctx, "Account", NK_TEXT_LEFT, nk_vec2(140,80)))
    {
        nk_layout_row_dynamic(ctx, 20, 1);
        if (nk_menu_item_label(ctx, "Login", NK_TEXT_LEFT))             g_view = VIEW_LOGIN;
        if (nk_menu_item_label(ctx, "Register", NK_TEXT_LEFT))          g_view = VIEW_REGISTER;
        nk_menu_close(ctx);
    }
    if (nk_button_label(ctx, "About")) g_view = VIEW_ABOUT;
    nk_menubar_end(ctx);
}

static void view_login(struct nk_context* ctx)
{
    nk_layout_row_dynamic(ctx, 25, 1); nk_label(ctx, "Login", NK_TEXT_LEFT);
    nk_layout_row_dynamic(ctx, 28, 1);
    nk_edit_string_zero_terminated(ctx, NK_EDIT_FIELD, g_buf, (int)sizeof(g_buf), nk_filter_default);
    nk_edit_string_zero_terminated(ctx, NK_EDIT_FIELD, g_buf2, (int)sizeof(g_buf2), nk_filter_default);
    nk_layout_row_dynamic(ctx, 28, 2);
    if (nk_button_label(ctx, "Login"))
    { login(g_buf2,g_buf,1); set_msg("Login attempted"); }
    if (nk_button_label(ctx, "Register")) g_view = VIEW_REGISTER;
    show_msg(ctx);
}

static void view_register(struct nk_context* ctx)
{
    nk_layout_row_dynamic(ctx, 25, 1); nk_label(ctx, "Register", NK_TEXT_LEFT);
    nk_layout_row_dynamic(ctx, 28, 1);
    nk_edit_string_zero_terminated(ctx, NK_EDIT_FIELD, g_buf, (int)sizeof(g_buf), nk_filter_default);
    nk_edit_string_zero_terminated(ctx, NK_EDIT_FIELD, g_buf2, (int)sizeof(g_buf2), nk_filter_default);
    nk_edit_string_zero_terminated(ctx, NK_EDIT_FIELD, g_buf3, (int)sizeof(g_buf3), nk_filter_default);
    nk_layout_row_dynamic(ctx, 28, 2);
    if (nk_button_label(ctx, "Register"))
    { if(strcmp(g_buf2,g_buf3)==0) signup(g_buf2,g_buf,1); set_msg("Register attempted"); }
    if (nk_button_label(ctx, "Back")) g_view = VIEW_LOGIN;
    show_msg(ctx);
}

static void view_add_books(struct nk_context* ctx)
{
    nk_layout_row_dynamic(ctx, 25, 1); nk_label(ctx, "Add Book", NK_TEXT_LEFT);
    nk_layout_row_dynamic(ctx, 28, 1);
    nk_edit_string_zero_terminated(ctx, NK_EDIT_FIELD, g_buf, (int)sizeof(g_buf), nk_filter_default);
    nk_edit_string_zero_terminated(ctx, NK_EDIT_FIELD, g_buf2, (int)sizeof(g_buf2), nk_filter_default);
    nk_edit_string_zero_terminated(ctx, NK_EDIT_FIELD, g_buf3, (int)sizeof(g_buf3), nk_filter_default);
    nk_property_int(ctx, "#ID:", 0, &g_book_id, 99999, 1, 1);

    std::vector<const char*> cats;
    for (const auto& c : g_categories) cats.push_back(c.c_str());
    nk_combobox(ctx, cats.data(), (int)cats.size(), &g_cat_sel, 20, nk_vec2(200,200));
    nk_combobox(ctx, g_statuses, 5, &g_status_sel, 20, nk_vec2(200,200));

    nk_layout_row_dynamic(ctx, 28, 1);
    if (nk_button_label(ctx, "Add") && g_buf[0] && g_buf2[0] && g_book_id>0)
    {
        if (!book_id_exists(std::to_string(g_book_id)))
            save_book(g_buf,g_buf2,g_buf3,std::to_string(g_book_id),g_categories[g_cat_sel],g_statuses[g_status_sel]);
        set_msg("Added");
    }
    show_msg(ctx);
}

static void resource_monitor(struct nk_context* ctx)
{
    static long rss = 0;
    static double last = 0;
    double now = glfwGetTime();
    if (now - last > 1.0)
    {
        last = now;
        std::ifstream sf("/proc/self/status");
        std::string ln;
        while (std::getline(sf, ln))
            if (ln.compare(0,6,"VmRSS:")==0) { sscanf(ln.c_str(),"%*s %ld",&rss); break; }
    }
    char buf[64];
    snprintf(buf, sizeof(buf), "RAM: %.2f MB", rss / 1024.0);
    nk_label_colored(ctx, buf, NK_TEXT_RIGHT, nk_rgba(0,255,0,255));
}

void gui_nuklear_run()
{
    glfwSetErrorCallback(error_cb);
    if (!glfwInit()) return;
    g_win = glfwCreateWindow(800, 600, "ShelfSight (Nuklear)", 0, 0);
    if (!g_win) { glfwTerminate(); return; }
    glfwMakeContextCurrent(g_win);
    glfwSwapInterval(1);
    glfwSetScrollCallback(g_win, scroll_cb);
    glfwSetCharCallback(g_win, char_cb);

    nk_init_default(&g_ctx, 0);
    nk_font_atlas_init_default(&g_atlas);
    nk_font_atlas_begin(&g_atlas);
    struct nk_font* font = nk_font_atlas_add_default(&g_atlas, 13, 0);
    int fw, fh;
    const void* img = nk_font_atlas_bake(&g_atlas, &fw, &fh, NK_FONT_ATLAS_RGBA32);
    g_font_tex = upload_atlas(img, fw, fh);
    nk_font_atlas_end(&g_atlas, nk_handle_id((int)g_font_tex), 0);
    nk_style_set_font(&g_ctx, &font->handle);

    load_settings();

    while (!glfwWindowShouldClose(g_win))
    {
        nk_new_frame();
        struct nk_context* ctx = &g_ctx;

        if (nk_begin(ctx, "ShelfSight", nk_rect(0,0,(float)g_ww,(float)g_wh),
            NK_WINDOW_NO_SCROLLBAR))
        {
            menu_bar(ctx);
            nk_layout_row_dynamic(ctx, (float)(g_wh - 70), 1);
            if (nk_group_begin(ctx, "content", 0))
            {
                switch (g_view)
                {
                    case VIEW_LOGIN:       view_login(ctx); break;
                    case VIEW_REGISTER:    view_register(ctx); break;
                    case VIEW_ADD_BOOKS:   view_add_books(ctx); break;
                    default: nk_layout_row_dynamic(ctx,25,1); nk_label(ctx,"Select a view from the menu",NK_TEXT_LEFT); break;
                }
                nk_group_end(ctx);
            }
            nk_layout_row_dynamic(ctx, 22, 1);
            resource_monitor(ctx);
        }
        nk_end(ctx);

        nk_render();
        glfwSwapBuffers(g_win);
    }

    nk_font_atlas_clear(&g_atlas);
    nk_free(&g_ctx);
    glfwDestroyWindow(g_win);
    glfwTerminate();
}
