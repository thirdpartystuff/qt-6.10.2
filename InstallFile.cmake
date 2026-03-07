
get_filename_component(name "${SOURCE_FILE}" NAME_WLE)
get_filename_component(ext  "${SOURCE_FILE}" LAST_EXT)
get_filename_component(path "${SOURCE_FILE}" DIRECTORY)

set(filename "${name}${SUFFIX}${ext}")
set(srcfile "${path}/${filename}")
set(dstfile "${TARGET_DIR}/${filename}")

if(EXISTS "${srcfile}" AND NOT EXISTS "${dstfile}")
    message(STATUS "Installing dependency ${PREFIX}${filename} for target ${TARGET} (${CONFIG})")
    configure_file("${srcfile}" "${dstfile}" COPYONLY)
endif()
