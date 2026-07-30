#include "menu_cli.h"
#include "file_man.h"
#include "gui_imgui.h"
#include "gui_tcl.h"

#include <cstdlib>
#include <csignal>
#include <cstring>
#include <iostream>

static volatile std::sig_atomic_t exit_requested = 0;

void shutdown()
{
	std::cout << "Cleaning up resources...\n";
	std::cout << "Shut down! Goodbye! \n";
}

void clear_cli()
{
#ifdef _WIN32
	system("cls");
#else
	system("clear");
#endif
}

bool is_exit_requested()
{
	return exit_requested != 0;
}

void consume_exit_request()
{
	exit_requested = 0;
}

void request_exit()
{
	exit_requested = 1;
}

static void handle_signal(int sig)
{
	exit_requested = 1;
	(void)sig;
}

int main(int argc, char** argv)
{
	std::signal(SIGINT,  handle_signal);
	std::signal(SIGTERM, handle_signal);
	std::atexit(shutdown);

	std::ios_base::sync_with_stdio(false);

	load_settings();

	if (argc > 1 && (strcmp(argv[1], "--gui") == 0 || strcmp(argv[1], "-g") == 0))
	{
		gui_imgui_run();
		return 0;
	}
	if (argc > 1 && (strcmp(argv[1], "--tk") == 0 || strcmp(argv[1], "-t") == 0))
	{
		gui_tcl_run();
		return 0;
	}

	try
	{
		short ret = mnu_cli();
		return static_cast<int>(ret);
	}
	catch (std::exception const& e)
	{
		std::cerr << "Fatal error: " << e.what() << '\n';
		return EXIT_FAILURE;
	}
}
