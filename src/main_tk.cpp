#include "main.h"
#include "file_man.h"
#include "gui_tcl.h"

#include <cstdlib>
#include <csignal>
#include <iostream>

static volatile std::sig_atomic_t exit_requested = 0;

void shutdown()
{
	std::cout << "Cleaning up resources...\n";
	std::cout << "Shut down! Goodbye!\n";
}

void clear_cli() {}

bool is_exit_requested() { return exit_requested != 0; }

void consume_exit_request() { exit_requested = 0; }

void request_exit() { exit_requested = 1; }

static void handle_signal(int sig)
{
	exit_requested = 1;
	(void)sig;
}

int main()
{
	std::signal(SIGINT,  handle_signal);
	std::signal(SIGTERM, handle_signal);
	std::atexit(shutdown);

	std::ios_base::sync_with_stdio(false);

	load_settings();
	gui_tcl_run();
	return 0;
}
