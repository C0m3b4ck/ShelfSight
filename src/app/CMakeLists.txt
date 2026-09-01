cmake_minimum_required(VERSION 3.16)
project(ShelfSight VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

# Qt6 components
find_package(Qt6 REQUIRED COMPONENTS Widgets Sql Core)

# SQLiteCpp
add_subdirectory(${CMAKE_SOURCE_DIR}/../sqlitecpp ${CMAKE_BINARY_DIR}/sqlitecpp)

# Sodium
find_package(PkgConfig QUIET)
if(PKG_CONFIG_FOUND)
    pkg_check_modules(SODIUM REQUIRED libsodium)
else()
    find_library(SODIUM_LIBRARY sodium)
    find_path(SODIUM_INCLUDE_DIR sodium.h)
    set(SODIUM_LIBRARIES ${SODIUM_LIBRARY})
    set(SODIUM_INCLUDE_DIRS ${SODIUM_INCLUDE_DIR})
endif()

# Sources
set(SOURCES
    businesslogic.cpp
    createdatabasedialog.cpp
    crypto.cpp
    main.cpp
    mainwindow.cpp
    sanitize_string.cpp
    sqlite_dataaccess.cpp
)

set(HEADERS
    businesslogic.h
    createdatabasedialog.h
    crypto.h
    dataaccess.h
    domain.h
    logger.h
    mainwindow.h
    sqlite_dataaccess.h
    worklog.h
)

set(FORMS
    createdatabasedialog.ui
    mainwindow.ui
)

# Executable
add_executable(${PROJECT_NAME} ${SOURCES} ${HEADERS} ${FORMS})

target_link_libraries(${PROJECT_NAME}
    PRIVATE
        Qt6::Widgets
        Qt6::Sql
        Qt6::Core
        SQLiteCpp
        ${SODIUM_LIBRARIES}
)

target_include_directories(${PROJECT_NAME}
    PRIVATE
        ${CMAKE_SOURCE_DIR}/../sqlitecpp/include
        ${SODIUM_INCLUDE_DIRS}
        ${CMAKE_CURRENT_BINARY_DIR}
)

# Windows-specific settings
if(WIN32)
    target_compile_definitions(${PROJECT_NAME} PRIVATE _CRT_SECURE_NO_WARNINGS)
    target_link_libraries(${PROJECT_NAME} PRIVATE ssp)
    # Static runtime for MinGW
    if(MINGW)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -static-libgcc -static-libstdc++")
    endif()
endif()

# Install
install(TARGETS ${PROJECT_NAME} DESTINATION bin)

# Version
set_target_properties(${PROJECT_NAME} PROPERTIES VERSION ${PROJECT_VERSION})
if(WIN32)
    set_target_properties(${PROJECT_NAME} PROPERTIES WIN32_EXECUTABLE TRUE)
endif()