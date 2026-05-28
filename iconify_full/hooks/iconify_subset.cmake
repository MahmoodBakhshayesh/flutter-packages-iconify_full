# iconify_full — subset SVGs before desktop builds (included or inlined by apply_hooks).
if(NOT TARGET iconify_subset)
  set(ICONIFY_APP_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/..")
  set(ICONIFY_CACHE_DIR "${ICONIFY_APP_ROOT}/../.iconify_cache")
  if(NOT EXISTS "${ICONIFY_CACHE_DIR}")
    set(ICONIFY_CACHE_DIR "${ICONIFY_APP_ROOT}/.iconify_cache")
  endif()
  add_custom_target(iconify_subset
    COMMAND dart run iconify_full:iconify_subset
      --project "${ICONIFY_APP_ROOT}"
      --cache "${ICONIFY_CACHE_DIR}"
      --no-pubspec
    WORKING_DIRECTORY "${ICONIFY_APP_ROOT}"
    COMMENT "Subsetting Iconify SVG assets (iconify_full)"
    VERBATIM
  )
endif()
