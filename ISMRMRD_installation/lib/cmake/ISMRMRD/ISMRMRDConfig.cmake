#-----------------------------------------------------------------------------
#
# ISMRMRDConfig.cmake - ISMRMRD CMake configuration file for external projects.
#
# This file is configured by ISMRMRD and used by the UseISMRMRD.cmake module
# to load ISMRMRD's settings for an external project.


####### Expanded from @PACKAGE_INIT@ by configure_package_config_file() #######
####### Any changes to this file will be overwritten by the next CMake run ####
####### The input file was ISMRMRDConfig.cmake.in                            ########

get_filename_component(PACKAGE_PREFIX_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../" ABSOLUTE)

macro(set_and_check _var _file)
  set(${_var} "${_file}")
  if(NOT EXISTS "${_file}")
    message(FATAL_ERROR "File or directory ${_file} referenced by variable ${_var} does not exist !")
  endif()
endmacro()

macro(check_required_components _NAME)
  foreach(comp ${${_NAME}_FIND_COMPONENTS})
    if(NOT ${_NAME}_${comp}_FOUND)
      if(${_NAME}_FIND_REQUIRED_${comp})
        set(${_NAME}_FOUND FALSE)
      endif()
    endif()
  endforeach()
endmacro()

####################################################################################

get_filename_component(ISMRMRD_CMAKE_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)

include(${ISMRMRD_CMAKE_DIR}/ISMRMRDConfigVersion.cmake)

#   ISMRMRD_SCHEMA_DIR   - where to find ismrmrd.xsd 
set(ISMRMRD_SCHEMA_DIR   "/Users/felix/Research_Local/share/ismrmrd/schema")
#   ISMRMRD_INCLUDE_DIR  - where to find ismrmrd.h, etc.
set(ISMRMRD_INCLUDE_DIRS "/Users/felix/Research_Local/include;/usr/local/include")
#   ISMRMRD_LIBRARY_DIRS - where to search for libraries
set(ISMRMRD_LIBRARY_DIRS "/Users/felix/Research_Local/lib")
#   ISMRMRD_LIBRARIES    - i.e. ismrmrd
set(ISMRMRD_LIBRARIES    "ismrmrd")

set(USE_SYSTEM_PUGIXML OFF)

## For backwards compatibility use existing variable name
## Include directories can be lists, and should be plural
## to conform with naming schemes in many other cmake packages
set(ISMRMRD_INCLUDE_DIR  "/Users/felix/Research_Local/include;/usr/local/include")
set(ISMRMRD_LIB_DIR "/Users/felix/Research_Local/lib")

# ------------------------------------------------------------------------------

include(CMakeFindDependencyMacro)

list(INSERT CMAKE_MODULE_PATH 0 ${ISMRMRD_CMAKE_DIR})

if(USE_SYSTEM_PUGIXML)
  find_package(PugiXML CONFIG)
  if (NOT PugiXML_FOUND)
    find_dependency(PugiXML)
  endif()
endif()

if(CMAKE_VERSION VERSION_LESS 3.9)
  # CMake <= 3.8 find_dependency does not support COMPONENTS
  find_package(HDF5 COMPONENTS C)
else()
  find_dependency(HDF5 COMPONENTS C)
endif()

list(REMOVE_AT CMAKE_MODULE_PATH 0)

# ==============================================================================

set_and_check(ISMRMRDTargets "${ISMRMRD_CMAKE_DIR}/ISMRMRDTargets.cmake")
include(${ISMRMRDTargets})

# ==============================================================================
