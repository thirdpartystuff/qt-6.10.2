
function(_myqt_install_library target targetDir prefix file)
    set(outdir)
    set(suffix)
    if(NOT MSVC)
        set(outdir "${targetDir}/${prefix}")
        set(suffix "")
    else()
        set(outdir "${targetDir}/$<CONFIG>/${prefix}")
        set(suffix "$<$<CONFIG:Debug>:d>")
    endif()
    add_custom_command(TARGET "${target}"
        PRE_BUILD COMMAND
            "${CMAKE_COMMAND}"
                "-DTARGET=${target}"
                "-DCONFIG=$<CONFIG>"
                "-DSOURCE_FILE=${file}"
                "-DTARGET_DIR=${outdir}"
                "-DPREFIX=${prefix}"
                "-DSUFFIX=${suffix}"
                 -P "${QT_ROOT}/InstallFile.cmake"
        )
endfunction()

function(_myqt_install_plugins target targetDir file)
    get_filename_component(path "${file}" DIRECTORY)
    get_filename_component(path "${path}" DIRECTORY)
    foreach(plugin IN LISTS ARGN)
        get_filename_component(prefix "${plugin}" DIRECTORY)
        set(file "${path}/plugins/${plugin}${CMAKE_SHARED_LIBRARY_SUFFIX}")
        _myqt_install_library("${target}" "${targetDir}" "${prefix}/" "${file}")
    endforeach()
endfunction()

function(_myqt_use_libraries target outdir)
    foreach(name IN LISTS ARGN)
        set(lib "Qt6::${name}")
        if(MSVC OR MINGW)
            get_target_property(file "${lib}" LOCATION_RELEASE)
            _myqt_install_library("${target}" "${outdir}" "" "${file}")
            if("${lib}" STREQUAL "Qt6::Gui")
                _myqt_install_plugins("${target}" "${outdir}" "${file}"
                    platforms/qwindows
                    styles/qmodernwindowsstyle
                    )
            endif()
            if("${lib}" STREQUAL "Qt6::Network")
                _myqt_install_plugins("${target}" "${outdir}" "${file}"
                    tls/qschannelbackend
                    )
            endif()
        endif()
        target_link_libraries("${target}" "${lib}")
    endforeach()
endfunction()

function(_myqt_install_mingw_libraries target outdir)
    if(MINGW)
        get_filename_component(gccdir "${CMAKE_CXX_COMPILER}" DIRECTORY)
        foreach(file libgcc_s_dw2-1.dll libgcc_s_seh-1.dll libwinpthread-1.dll libstdc++-6.dll libgomp-1.dll)
            if(EXISTS "${gccdir}/${file}")
                _myqt_install_library("${target}" "${outdir}" "" "${gccdir}/${file}")
            endif()
        endforeach()
    endif()
endfunction()
