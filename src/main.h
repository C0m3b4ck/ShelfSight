#pragma once

#include <string>

constexpr auto RST  = "\033[0m";
constexpr auto RED  = "\033[31m";
constexpr auto GRN  = "\033[32m";
constexpr auto YLW  = "\033[33m";
constexpr auto CYN  = "\033[36m";

void shutdown();
void clear_cli();
bool is_exit_requested();
void consume_exit_request();