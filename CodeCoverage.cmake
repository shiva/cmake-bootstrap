include(CMakeParseArguments)

# Check prereqs
FIND_PROGRAM( GCOV_PATH gcov )
FIND_PROGRAM( LCOV_PATH lcov )
FIND_PROGRAM( GENHTML_PATH genhtml )
FIND_PROGRAM( GCOVR_PATH gcovr PATHS ${CMAKE_SOURCE_DIR}/tests)

IF(NOT GCOV_PATH)
    MESSAGE(FATAL_ERROR "gcov not found! Aborting...")
ENDIF() # NOT GCOV_PATH

IF("${CMAKE_CXX_COMPILER_ID}" MATCHES "(Apple)?[Cc]lang")
    IF("${CMAKE_CXX_COMPILER_VERSION}" VERSION_LESS 3)
        MESSAGE(FATAL_ERROR "Clang version must be 3.0.0 or greater! Aborting...")
    ENDIF()
ELSEIF(NOT CMAKE_COMPILER_IS_GNUCXX)
    MESSAGE(FATAL_ERROR "Compiler is not GNU gcc! Aborting...")
ENDIF() # CHECK VALID COMPILER

SET(CMAKE_CXX_FLAGS_COVERAGE
    "-g -O0 --coverage -fprofile-arcs -ftest-coverage"
    CACHE STRING "Flags used by the C++ compiler during coverage builds."
    FORCE )
SET(CMAKE_C_FLAGS_COVERAGE
    "-g -O0 --coverage -fprofile-arcs -ftest-coverage"
    CACHE STRING "Flags used by the C compiler during coverage builds."
    FORCE )
SET(CMAKE_EXE_LINKER_FLAGS_COVERAGE
    ""
    CACHE STRING "Flags used for linking binaries during coverage builds."
    FORCE )
SET(CMAKE_SHARED_LINKER_FLAGS_COVERAGE
    ""
    CACHE STRING "Flags used by the shared libraries linker during coverage builds."
    FORCE )
MARK_AS_ADVANCED(
    CMAKE_CXX_FLAGS_COVERAGE
    CMAKE_C_FLAGS_COVERAGE
    CMAKE_EXE_LINKER_FLAGS_COVERAGE
    CMAKE_SHARED_LINKER_FLAGS_COVERAGE )

IF ( NOT (CMAKE_BUILD_TYPE STREQUAL "Debug" OR CMAKE_BUILD_TYPE STREQUAL "Coverage"))
  MESSAGE( WARNING "Code coverage results with an optimized (non-Debug) build may be misleading" )
ENDIF() # NOT CMAKE_BUILD_TYPE STREQUAL "Debug"


# Param TARGET			The name of new the custom make target
# Param TESTRUNNER     	The name of the target which runs the tests.
#                       MUST return ZERO always, even on errors.
#                       If not, no coverage report will be created!
# Param OUTPUTNAME     	lcov output is generated as _outputname.info
#                       HTML report is generated in _outputname/index.html
# Param EXCLUDE 		paths to exclude (using a regex)
# Optional parameter is passed as arguments to TESTRUNNER
#   Pass them in list form, e.g.: "-j;2" for -j 2
function(add_coverage)
    set(oneValueArgs TARGET TESTRUNNER OUTPUTNAME)
    set(multiValueArgs EXCLUDE)
    cmake_parse_arguments(ARGS "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT LCOV_PATH)
        message(FATAL_ERROR "lcov not found! Aborting...")
    endif() # NOT LCOV_PATH

    if(NOT GENHTML_PATH)
        message(FATAL_ERROR "genhtml not found! Aborting...")
    endif() # NOT GENHTML_PATH

    set(COVERAGE_INFO "${CMAKE_BINARY_DIR}/${ARGS_OUTPUTNAME}.info")
    set(COVERAGE_CLEANED "${COVERAGE_INFO}.cleaned")

    separate_arguments(test_command UNIX_COMMAND "${ARGS_TESTRUNNER}")

	message(STATUS "${ARGS_TARGET} ${ARGS_TESTRUNNER} ${ARGS_OUTPUTNAME} ${ARGS_UNPARSED_ARGUMENTS}")
	message(STATUS "${COVERAGE_INFO} ${COVERAGE_CLEANED}") 
    # Setup target
    add_custom_target(${ARGS_TARGET}
        # Cleanup lcov
        COMMAND ${LCOV_PATH} --directory . --zerocounters

        # Run tests
        COMMAND ${test_command} ${ARGS_UNPARSED_ARGUMENTS}

        # Capturing lcov counters and generating report
        COMMAND ${LCOV_PATH} --directory . --capture --output-file ${COVERAGE_INFO}
        COMMAND ${LCOV_PATH} --remove ${COVERAGE_INFO} 'tests/*' '/usr/*' ${ARGS_EXCLUDE} --output-file ${COVERAGE_CLEANED}
        COMMAND ${GENHTML_PATH} -q -o ${ARGS_OUTPUTNAME} ${COVERAGE_CLEANED}
        COMMAND ${CMAKE_COMMAND} -E remove ${COVERAGE_INFO} ${COVERAGE_CLEANED}

        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}

        COMMENT "Resetting code coverage counters to zero.\nProcessing code coverage counters and generating report."
    )

    # Show info where to find the report
    add_custom_command(TARGET ${ARGS_TARGET} POST_BUILD
        COMMAND ;
        COMMENT "Open ./${ARGS_OUTPUTNAME}/index.html in your browser to view the coverage report."
    )

endfunction(add_coverage)
