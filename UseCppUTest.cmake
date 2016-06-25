include(CMakeParseArguments)
#include(CodeCoverage)
include(CTest)
find_package(CppUTest)

function(enable_unit_testing)
	if (NOT ENABLE_TESTING)
		return()
	endif()
	    
    include_directories(${CPPUTEST_INCLUDE_DIRS})
    include_directories(${CPPUTEST_EXT_INCLUDE_DIRS})

    set(CMAKE_CXX_FLAGS "-g -O0 -fprofile-arcs -ftest-coverage")
    set(CMAKE_C_FLAGS "-g -O0 -fprofile-arcs -ftest-coverage")
    set(CMAKE_EXE_LINKER_FLAGS="-fprofile-arcs -ftest-coverage")
endfunction(enable_unit_testing)

function(add_unit_test)
    cmake_parse_arguments(ARGS "" "TARGET" "SOURCES" ${ARGN})
    set(ut_target "test-${ARGS_TARGET}")

    if((NOT ENABLE_TESTING) OR (NOT CPPUTEST_FOUND))
        # skip if testing is not enabled or cpputest is not found
        message(STATUS "UT disabled. Skipping test target: ${ut_target} ... ")
        return()
    endif()

    add_executable(
        ${ut_target}
        EXCLUDE_FROM_ALL
        ${ARGS_SOURCES}
    )
    target_link_libraries(${ut_target} ${CPPUTEST_LIBRARIES} ${CPPUTEST_EXT_LIBRARIES})

    add_test(
        NAME ${ut_target}
        COMMAND $<TARGET_FILE:${ut_target}>
    )

    # make check depends on all test targets
    if (NOT TARGET check)
        add_custom_target(check COMMAND ${CMAKE_CTEST_COMMAND})
    endif()
    add_dependencies(check ${ut_target})

    # comment on coverage for now
    #SETUP_TARGET_FOR_COVERAGE(cov-${ut_target} ${ut_target} coverage-repot-${ut_target} "-v")
    #if (NOT TARGET coverage)
    #    add_custom_target(coverage)
    #endif()
    #add_dependencies(coverage cov-${ut_target})

endfunction(add_unit_test)
