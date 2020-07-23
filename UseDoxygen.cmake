include(CMakeParseArguments)
include(CTest)

set(_CMAKE_SCRIPT_PATH ${CMAKE_CURRENT_LIST_DIR})

if(WITH_DOCS)
    find_package(Doxygen REQUIRED)
    if ( DOXYGEN_FOUND )
        set( DOXYGEN_OUTPUT_DIRECTORY doxygen )
        set( DOXYGEN_COLLABORATION_GRAPH YES )
        set( DOXYGEN_EXTRACT_ALL YES )
        set( DOXYGEN_CLASS_DIAGRAMS YES )
        set( DOXYGEN_HIDE_UNDOC_RELATIONS NO )
        set( DOXYGEN_HAVE_DOT YES )
        set( DOXYGEN_CLASS_GRAPH YES )
        set( DOXYGEN_CALL_GRAPH YES )
        set( DOXYGEN_CALLER_GRAPH YES )
        set( DOXYGEN_COLLABORATION_GRAPH YES )
        set( DOXYGEN_BUILTIN_STL_SUPPORT YES )
        set( DOXYGEN_EXTRACT_PRIVATE YES )
        set( DOXYGEN_EXTRACT_PACKAGE YES )
        set( DOXYGEN_EXTRACT_STATIC YES )
        set( DOXYGEN_EXTRACT_LOCALMETHODS YES )
        set( DOXYGEN_UML_LOOK YES )
        set( DOXYGEN_UML_LIMIT_NUM_FIELDS 50 )
        set( DOXYGEN_TEMPLATE_RELATIONS YES )
        set( DOXYGEN_DOT_GRAPH_MAX_NODES 100 )
        set( DOXYGEN_MAX_DOT_GRAPH_DEPTH 0 )
        set( DOXYGEN_DOT_TRANSPARENT YES )
    else()
        message("Doxygen need to be installed to generate project documentation.")
    endif()
endif()
# add folders to doxygenate
# eg: doxygen_add_docs(doxygen ${RPP_PROJECT_SOURCE_DIR} )
