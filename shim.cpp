#include "file_man.h"

#include <cstdlib>
#include <string>

extern "C" int add_ints(int a, int b)
{
    return a + b;
}

static char* to_cstr(const std::string& s)
{
    char* out = static_cast<char*>(malloc(s.size() + 1));
    if (out == nullptr) return nullptr;
    std::copy(s.begin(), s.end(), out);
    out[s.size()] = '\0';
    return out;
}

extern "C" const char* shelf_today(void)
{
    return to_cstr(get_current_date_str());
}

extern "C" const char* shelf_add_days(const char* date, int days)
{
    return to_cstr(add_days_to_date(date ? date : "", days));
}
