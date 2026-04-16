include(CTest)

find_package(cmocka CONFIG REQUIRED
    HINTS /opt/homebrew/lib/cmake/cmocka
          /usr/local/lib/cmake/cmocka
          /usr/lib/cmake/cmocka
)

# add_unit_test(TARGET <name> SOURCES <files...> [LIBRARIES <libs...>])
function(add_unit_test)
    set(oneValueArgs TARGET)
    set(multiValueArgs SOURCES LIBRARIES)
    cmake_parse_arguments(ARGS "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT ARGS_TARGET)
        message(FATAL_ERROR "add_unit_test: TARGET is required")
    endif()

    if(NOT WITH_TESTS)
        message(STATUS "UT disabled. Skipping test target: test-${ARGS_TARGET}")
        return()
    endif()

    set(ut_target "test-${ARGS_TARGET}")

    add_executable(${ut_target} ${ARGS_SOURCES})
    target_link_libraries(${ut_target} PRIVATE cmocka::cmocka ${ARGS_LIBRARIES})

    add_test(
        NAME ${ut_target}
        COMMAND ${ut_target}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    )
endfunction()
