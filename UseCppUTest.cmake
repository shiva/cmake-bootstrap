include(CMakeParseArguments)
include(CTest)

if(WITH_TESTS)
    find_package(CppUTest REQUIRED)
endif()

if(WITH_COVERAGE)
    include(CodeCoverage)
    # Enable code coverage.
    # Build with debugging information to make the output meaningful.
    # Disable optimizations to get the most accurate results.
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} --coverage -g -O0")
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} --coverage -g -O0")
endif()

function(add_unit_test)
    set(oneValueArgs TARGET)
    set(multiValueArgs SOURCES LIBRARIES)
    cmake_parse_arguments(ARGS "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    set(ut_target "test-${ARGS_TARGET}")

    if(NOT WITH_TESTS)
        # skip if testing is not enabled or cpputest is not found
        message(STATUS "UT disabled. Skipping test target: ${ut_target} ... ")
        return()
    endif()

    if(WITH_COVERAGE)
        SETUP_TARGET_FOR_COVERAGE(
            cov-${ut_target}
            ${ut_target} coverage-report-${ut_target} "-v")

        if (NOT TARGET coverage)
            add_custom_target(coverage)
        endif()
        add_dependencies(coverage cov-test-fdb)
    else()
        message(STATUS "COVERAGE disabled. ")
    endif()


    # include paths and setup test target
    include_directories(${CPPUTEST_INCLUDE_DIRS})
    include_directories(${CPPUTEST_EXT_INCLUDE_DIRS})

    add_executable(
        ${ut_target}
        ${ARGS_SOURCES}
    )
    target_link_libraries(
        ${ut_target}
        ${CPPUTEST_LIBRARIES}
        ${CPPUTEST_EXT_LIBRARIES}
        ${ARGS_LIBRARIES}
    )

    # make check depends on all test targets
    if (NOT TARGET check)
        add_custom_target(check COMMAND ${ut_target} -v)
    endif()
    add_dependencies(check ${ut_target})

endfunction(add_unit_test)
