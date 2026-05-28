Pod::Spec.new do |s|
  s.name             = 'iconify_full'
  s.version          = '0.1.0'
  s.summary          = 'Iconify offline icons for Flutter'
  s.description      = 'Build-time Iconify SVG subsetting for Flutter apps'
  s.homepage         = 'https://github.com/iconify/icon-sets'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'iconify_full' => 'dev@iconify.local' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  s.script_phase = {
    :name => 'Iconify Subset',
    :script => <<-SCRIPT
set -e
APP_ROOT="${SRCROOT}/.."
CACHE="${APP_ROOT}/../.iconify_cache"
if [ ! -d "${CACHE}" ]; then
  CACHE="${APP_ROOT}/.iconify_cache"
fi
cd "${APP_ROOT}"
dart run iconify_full:iconify_subset --project . --cache "${CACHE}" --no-pubspec
SCRIPT
    ,
    :execution_position => :before_compile,
    :always_out_of_date => '1'
  }
end
