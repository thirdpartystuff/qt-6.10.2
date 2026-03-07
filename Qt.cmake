
get_filename_component(QT_ROOT "${CMAKE_CURRENT_LIST_FILE}" DIRECTORY)
if(MSVC)
    set(USE_QT "${QT_ROOT}/msvc2022_64")
elseif(MINGW)
    set(USE_QT "${QT_ROOT}/mingw_64")
endif()

include("${QT_ROOT}/Install.cmake")

if(MSVC OR MINGW)
    if(MSVC)
        set(d "d")
    else()
        set(d "")
    endif()
    set(ZLIB_FOUND TRUE CACHE INTERNAL "" FORCE)
    set(ZLIB_USE_STATIC_LIBS TRUE CACHE INTERNAL "" FORCE)
    set(ZLIB_INCLUDE_DIR "${USE_QT}/include/QtZlib" CACHE INTERNAL "" FORCE)
    set(ZLIB_LIBRARY_DEBUG "${USE_QT}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}Qt6Core${d}${CMAKE_STATIC_LIBRARY_SUFFIX}" CACHE INTERNAL "" FORCE)
    set(ZLIB_LIBRARY_RELEASE "${USE_QT}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}Qt6Core${CMAKE_STATIC_LIBRARY_SUFFIX}" CACHE INTERNAL "" FORCE)
    set(JPEG_FOUND TRUE CACHE INTERNAL "" FORCE)
    set(JPEG_INCLUDE_DIR "${USE_QT}/include/QtJpeg" CACHE INTERNAL "" FORCE)
    set(JPEG_LIBRARY_DEBUG "${USE_QT}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}Qt6BundledLibjpeg${d}${CMAKE_STATIC_LIBRARY_SUFFIX}" CACHE INTERNAL "" FORCE)
    set(JPEG_LIBRARY_RELEASE "${USE_QT}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}Qt6BundledLibjpeg${CMAKE_STATIC_LIBRARY_SUFFIX}" CACHE INTERNAL "" FORCE)
endif()

function(_myqt_smart_write_file file contents)
    if(EXISTS "${file}")
        file(READ "${file}" old)
        if("${old}" STREQUAL "${contents}")
            return()
        endif()
    endif()
    message(STATUS "Writing: ${file}")
    file(WRITE "${file}" "${contents}")
endfunction()

function(_myqt_resources_unity out_prefix gen_cpp)
    set(counter 1)
    set(out "${out_prefix}")
    foreach(file ${ARGN})
        get_filename_component(full "${file}" ABSOLUTE)
        set(out "${out}\n")
        set(out "${out}#define qt_resource_name qt_resource_name_${counter}\n")
        set(out "${out}#define qt_resource_data qt_resource_data_${counter}\n")
        set(out "${out}#define qt_resource_struct qt_resource_struct_${counter}\n")
        set(out "${out}#define dummy dummy_${counter}\n")
        set(out "${out}#define initializer initializer_${counter}\n")
        set(out "${out}#include \"${full}\"\n")
        set(out "${out}#undef qt_resource_name\n")
        set(out "${out}#undef qt_resource_data\n")
        set(out "${out}#undef qt_resource_struct\n")
        set(out "${out}#undef dummy\n")
        set(out "${out}#undef initializer\n")
        math(EXPR counter "${counter} + 1")
    endforeach()
    set_source_files_properties(${ARGN} PROPERTIES HEADER_FILE_ONLY TRUE)
    _myqt_smart_write_file("${gen_cpp}" "${out}")
endfunction()

macro(_myqt_include_source_file basedir folder file)
    get_filename_component(ext "${file}" EXT)
    get_filename_component(path "${file}" DIRECTORY)

    if (path STREQUAL "")
        string(REPLACE "/" "\\" group "Source Files/${folder}")
    else()
        string(REPLACE "/" "\\" group "Source Files/${folder}/${path}")
    endif()
    source_group("${group}" FILES "${basedir}/${file}")

    list(APPEND src "${basedir}/${file}")
endmacro()

function(myqt_add_source_directory target folder basedir)
    set(gen)
    set(moc)
    set(rcc)

    file(GLOB_RECURSE glob
        RELATIVE "${basedir}"
        CONFIGURE_DEPENDS
        "${basedir}/*.cpp"
        "${basedir}/*.h"
        "${basedir}/*.ui"
        "${basedir}/*.qrc"
        )

    set(src)
    foreach(file ${glob})
        _myqt_include_source_file("${basedir}" "${folder}" "${file}")
        if(ext STREQUAL ".h")
            file(READ "${basedir}/${file}" contents)
            if(contents MATCHES "\n[ \t]*Q_OBJECT[ \t]*\r?\n")
                qt6_wrap_cpp(moc "${basedir}/${file}")
            endif()
        elseif(ext STREQUAL ".ui")
            qt6_wrap_ui(gen "${basedir}/${file}")
        elseif(ext STREQUAL ".qrc")
            qt6_add_resources(rcc "${basedir}/${file}")
        endif()
    endforeach()

    list(LENGTH moc num1)
    list(LENGTH rcc num2)
    if("${num1}" GREATER 0 OR "${num2}" GREATER 0)
        set(out)
        foreach(file ${moc})
            get_filename_component(full "${file}" ABSOLUTE)
            set(out "${out}#include \"${full}\"\n")
        endforeach()
        set_source_files_properties(${moc} PROPERTIES HEADER_FILE_ONLY TRUE)

        set(gen_cpp "${CMAKE_CURRENT_BINARY_DIR}/${folder}_generated.cpp")
        list(APPEND gen "${gen_cpp}")
        _myqt_resources_unity("${out}" "${gen_cpp}" ${rcc})
    endif()

    source_group("Generated Files" FILES ${gen} ${moc} ${rcc})
    target_sources("${target}" PRIVATE ${src} ${gen} ${moc} ${rcc})
endfunction()

function(myqt_add_resource_directory target folder basedir)
    set(gen)
    set(rcc)

    file(GLOB_RECURSE glob
        RELATIVE "${basedir}"
        CONFIGURE_DEPENDS
        "${basedir}/*"
        )

    set(src)
    foreach(file ${glob})
        _myqt_include_source_file("${basedir}" "${folder}" "${file}")
        if(ext STREQUAL ".qrc")
            qt6_add_resources(rcc "${basedir}/${file}")
        else()
            set_source_files_properties("${basedir}/${file}" PROPERTIES HEADER_FILE_ONLY TRUE)
        endif()
    endforeach()

    list(LENGTH rcc num)
    if("${num}" GREATER 0)
        set(gen_cpp "${CMAKE_CURRENT_BINARY_DIR}/${folder}_generated.cpp")
        list(APPEND gen "${gen_cpp}")
        _myqt_resources_unity("" "${gen_cpp}" ${rcc})
    endif()

    source_group("Generated Files" FILES ${gen} ${rcc})
    target_sources("${target}" PRIVATE ${src} ${gen} ${rcc})
endfunction()

macro(myqt_create_executable target)
    set(_options)
    set(_single OUTDIR)
    set(_multi USES LIBRARIES)
    cmake_parse_arguments(_arg "${_options}" "${_single}" "${_multi}" ${ARGV})

    if(NOT _arg_OUTDIR OR "${_arg_OUTDIR}" STREQUAL "")
        set(_arg_OUTDIR "${CMAKE_BINARY_DIR}/_bin")
    endif()

    add_executable("${target}" WIN32)
    set_target_properties("${target}" PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "${_arg_OUTDIR}"
        CXX_SCAN_FOR_MODULES FALSE
        )

    find_package(Qt6 COMPONENTS ${_arg_USES} REQUIRED)
    target_link_libraries("${target}" ${_arg_LIBRARIES})
    _myqt_use_libraries("${target}" "${_arg_OUTDIR}" ${_arg_USES})
endmacro()
