#include "menu_cli.h"

#include <cstdlib>
#include <csignal>
#include <iostream>

static volatile std::sig_atomic_t exit_requested = 0;

void shutdown()
{
	std::cout << "Cleaning up resources...\n";
	// flush pending writes, close database handles, free allocations, etc.
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
