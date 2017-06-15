include(CMakeParseArguments)
include(CTest)

set(_CMAKE_SCRIPT_PATH ${CMAKE_CURRENT_LIST_DIR})

if(WITH_TESTS)
    find_package(CppUTest REQUIRED)
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

#    if(WITH_COVERAGE)
#        SETUP_TARGET_FOR_COVERAGE(
#            cov-${ut_target}
#            ${ut_target} coverage-report-${ut_target} "-v")
#
#        if (NOT TARGET coverage)
#            add_custom_target(coverage
#                COMMAND ${CMAKE_COMMAND} -DPROJECT_BINARY_DIR="${PROJECT_BINARY_DIR}" -P "${_CMAKE_SCRIPT_PATH}/CoverallsClear.cmake"
#                WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
#            )
#        endif()
#        add_dependencies(coverage cov-${ut_target})
#    else()
#        message(STATUS "COVERAGE disabled. ")
#    endif()


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
    
    # also add as a test to ctest
    add_test(
        NAME ${ut_target} 
        COMMAND ${ut_target} -v
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR})

endfunction(add_unit_test)
