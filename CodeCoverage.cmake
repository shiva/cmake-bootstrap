# Check prereqs
find_program(GCOV_PATH gcov)
find_program(LCOV_PATH lcov)
find_program(GENHTML_PATH genhtml)

if(NOT GCOV_PATH)
    message(FATAL_ERROR "gcov not found! Aborting...")
endif()
if(NOT LCOV_PATH)
    message(FATAL_ERROR "lcov not found! Aborting...")
endif()
if(NOT GENHTML_PATH)
    message(FATAL_ERROR "genhtml not found! Aborting...")
endif()

if(NOT CMAKE_CXX_COMPILER_ID MATCHES "(Apple)?[Cc]lang" AND NOT CMAKE_COMPILER_IS_GNUCXX)
    message(FATAL_ERROR "Compiler is not Clang or GCC! Aborting...")
endif()

if(NOT (CMAKE_BUILD_TYPE STREQUAL "Debug" OR CMAKE_BUILD_TYPE STREQUAL "Coverage"))
    message(WARNING "Code coverage results with an optimized (non-Debug) build may be misleading")
endif()

# add_coverage(TARGET <name> TESTRUNNER <cmd> OUTPUTNAME <name> [EXCLUDE <patterns...>])
# HTML report generated in <OUTPUTNAME>/index.html
function(add_coverage)
    set(oneValueArgs TARGET TESTRUNNER OUTPUTNAME)
    set(multiValueArgs EXCLUDE)
    cmake_parse_arguments(ARGS "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT ARGS_TARGET)
        message(FATAL_ERROR "add_coverage: TARGET is required")
    endif()
    if(NOT ARGS_TESTRUNNER)
        message(FATAL_ERROR "add_coverage: TESTRUNNER is required")
    endif()
    if(NOT ARGS_OUTPUTNAME)
        message(FATAL_ERROR "add_coverage: OUTPUTNAME is required")
    endif()

    set(COVERAGE_INFO    "${CMAKE_BINARY_DIR}/${ARGS_OUTPUTNAME}.info")
    set(COVERAGE_CLEANED "${COVERAGE_INFO}.cleaned")

    separate_arguments(test_command UNIX_COMMAND "${ARGS_TESTRUNNER}")

    add_custom_target(${ARGS_TARGET}
        COMMAND ${LCOV_PATH} --directory . --zerocounters
        COMMAND ${test_command} ${ARGS_UNPARSED_ARGUMENTS}
        COMMAND ${LCOV_PATH} --ignore-errors unsupported --directory . --capture --output-file ${COVERAGE_INFO}
        COMMAND ${LCOV_PATH} --ignore-errors unused,unsupported --remove ${COVERAGE_INFO} ${ARGS_EXCLUDE} --output-file ${COVERAGE_CLEANED}
        COMMAND ${GENHTML_PATH} -q -o ${ARGS_OUTPUTNAME} ${COVERAGE_CLEANED}
        COMMAND ${CMAKE_COMMAND} -E remove ${COVERAGE_INFO} ${COVERAGE_CLEANED}
        COMMAND ${CMAKE_COMMAND} -E echo "Open ./${ARGS_OUTPUTNAME}/index.html in your browser to view the coverage report."
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Resetting code coverage counters to zero.\nProcessing code coverage counters and generating report."
    )
endfunction()