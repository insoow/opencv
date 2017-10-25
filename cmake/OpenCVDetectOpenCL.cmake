set(OPENCL_FOUND ON CACHE BOOL "OpenCL library is found")
if(APPLE)
  set(OPENCL_LIBRARY "-framework OpenCL" CACHE STRING "OpenCL library")
  set(OPENCL_INCLUDE_DIR "" CACHE PATH "OpenCL include directory")
else(APPLE)
  set(OPENCL_LIBRARY "" CACHE STRING "OpenCL library")
  set(OPENCL_INCLUDE_DIR "${OpenCV_SOURCE_DIR}/3rdparty/include/opencl/1.2" CACHE PATH "OpenCL include directory")
endif(APPLE)
mark_as_advanced(OPENCL_INCLUDE_DIR OPENCL_LIBRARY)

if(OPENCL_FOUND)
  if(OPENCL_LIBRARY)
    set(HAVE_OPENCL_STATIC ON)
    set(OPENCL_LIBRARIES "${OPENCL_LIBRARY}")
  else()
    set(HAVE_OPENCL_STATIC OFF)
  endif()

  if(NOT HAVE_OPENCL_STATIC)
    try_compile(__VALID_OPENCL
      "${OpenCV_BINARY_DIR}"
      "${OpenCV_SOURCE_DIR}/cmake/checks/opencl.cpp"
      CMAKE_FLAGS "-DINCLUDE_DIRECTORIES:STRING=${OPENCL_INCLUDE_DIR}"
      OUTPUT_VARIABLE TRY_OUT
      )
    if(NOT TRY_OUT MATCHES "OpenCL is valid")
      message(WARNING "Can't use OpenCL")
      return()
    endif()
  endif()

  set(HAVE_OPENCL 1)

  if(WITH_OPENCL_SVM)
    set(HAVE_OPENCL_SVM 1)
  endif()

  set(OPENCL_INCLUDE_DIRS ${OPENCL_INCLUDE_DIR})

  if(WITH_OPENCLAMDFFT)
    find_path(CLAMDFFT_ROOT_DIR
              NAMES include/clAmdFft.h
              PATHS ENV CLAMDFFT_PATH ENV ProgramFiles
              PATH_SUFFIXES clAmdFft AMD/clAmdFft
              DOC "AMD FFT root directory"
              NO_DEFAULT_PATH)

    find_path(CLAMDFFT_INCLUDE_DIR
              NAMES clAmdFft.h
              HINTS ${CLAMDFFT_ROOT_DIR}
              PATH_SUFFIXES include
              DOC "clAmdFft include directory")

    if(CLAMDFFT_INCLUDE_DIR)
      set(HAVE_CLAMDFFT 1)
      list(APPEND OPENCL_INCLUDE_DIRS "${CLAMDFFT_INCLUDE_DIR}")
    endif()
  endif()

  if(WITH_OPENCLAMDBLAS)
    find_path(CLAMDBLAS_ROOT_DIR
              NAMES include/clAmdBlas.h
              PATHS ENV CLAMDBLAS_PATH ENV ProgramFiles
              PATH_SUFFIXES clAmdBlas AMD/clAmdBlas
              DOC "AMD FFT root directory"
              NO_DEFAULT_PATH)

    find_path(CLAMDBLAS_INCLUDE_DIR
              NAMES clAmdBlas.h
              HINTS ${CLAMDBLAS_ROOT_DIR}
              PATH_SUFFIXES include
              DOC "clAmdFft include directory")

    if(CLAMDBLAS_INCLUDE_DIR)
      set(HAVE_CLAMDBLAS 1)
      list(APPEND OPENCL_INCLUDE_DIRS "${CLAMDBLAS_INCLUDE_DIR}")
    endif()
  endif()

  if(WITH_CLINTELBLAS)
    find_path(CLINTELBLAS_ROOT_DIR
              NAMES oclBLAS.h
              PATHS ENV CLINTELBLAS_PATH ENV ProgramFiles 
              PATH_SUFFIXES include/oclBLAS 
              DOC "INTEL BLAS root directory")
      
    find_path(CLINTELBLAS_INCLUDE_DIR
              NAMES oclBLAS.h
              HINTS ${CLINTELBLAS_ROOT_DIR}
              PATH_SUFFIXES include
              DOC "oclBLAS include directory")

    #find_library(MFX_LIBRARY mfx PATHS "${root}/lib/${arch}" NO_DEFAULT_PATH)

    find_library(CLINTELBLAS_LIB
              NAMES oclBLAS
              HINTS 
                "/workspace/gen_library/genCL_primer/build/out"
                "${CLINTELBLAS_ROOT_DIR}"
                "${CLINTELBLAS_ROOT_DIR}/build/out"
              DOC "oclBLAS library directory"
              )
    MESSAGE("CLINTELBLAS_LIB ${CLINTELBLAS_LIB}")
    if(CLINTELBLAS_LIB)
      list(APPEND OPENCL_LIBRARIES "${CLINTELBLAS_LIB}")
    endif()

    if(CLINTELBLAS_INCLUDE_DIR)
      set(HAVE_CLINTELBLAS 1)
      list(APPEND OPENCL_INCLUDE_DIRS "${CLINTELBLAS_INCLUDE_DIR}")
    endif()

  endif()
endif()
