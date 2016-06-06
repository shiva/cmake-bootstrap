include(CMakeParseArguments)
include(CodeCoverage)
include(CTest)

function(enable_unit_testing)
    if(DEFINED ENV{CPPUTEST_HOME})
        message("Using CppUTest found in $ENV{CPPUTEST_HOME}")
    else()
        message("Disabling unit-tests. CPPUTEST_HOME is not set; You must tell CMake where to find CppUTest if you want to enable unit-testing.")
    endif()
endfunction(enable_unit_testing)

function(add_unit_test)
    cmake_parse_arguments(ARGS "" "TARGET" "SOURCES" ${ARGN})

    # set the target binary and nim cache directory
    set(ut_target "test-${ARGS_TARGET}")

    SET(CMAKE_CXX_FLAGS "-g -O0 -fprofile-arcs -ftest-coverage")
    SET(CMAKE_C_FLAGS "-g -O0 -fprofile-arcs -ftest-coverage")
    SET(CMAKE_EXE_LINKER_FLAGS="-fprofile-arcs -ftest-coverage")

    include_directories($ENV{CPPUTEST_HOME}/include)
    add_library(imp_cpputest STATIC IMPORTED)
    set_target_properties(imp_cpputest PROPERTIES
        IMPORTED_LOCATION $ENV{CPPUTEST_HOME}/lib/libCppUTest.a)

    add_executable(
        ${ut_target}
        EXCLUDE_FROM_ALL
        ${ARGS_SOURCES}
    )
    target_link_libraries(${ut_target} imp_cpputest)
    add_test(
        NAME ${ut_target}
        COMMAND $<TARGET_FILE:${ut_target}>
    )

    if (NOT TARGET check)
        add_custom_target(check COMMAND ${CMAKE_CTEST_COMMAND})
    endif()
    add_dependencies(check ${ut_target})

    SETUP_TARGET_FOR_COVERAGE(cov-${ut_target} ${ut_target} coverage-repot-${ut_target} "-v")
    if (NOT TARGET coverage)
        add_custom_target(coverage)
    endif()
    add_dependencies(coverage cov-${ut_target})

endfunction(add_unit_test)
