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
  # Ruby 4 / CocoaPods: comma must follow the heredoc identifier, not a
  # standalone line after SCRIPT (that used to parse on Ruby 3).
  s.script_phase = {
    :name => 'Iconify Subset',
    :script => <<-SCRIPT,
set -euo pipefail

# Resolve Flutter app ios/ folder (Pods SRCROOT is usually ios/Pods).
APP_IOS=""
for candidate in "${PODS_ROOT}/.." "${SRCROOT}/.." "${SRCROOT}/../.." "${PROJECT_DIR}/.."; do
  if [ -f "${candidate}/Flutter/Generated.xcconfig" ]; then
    APP_IOS="$(cd "${candidate}" && pwd)"
    break
  fi
done
if [ -z "${APP_IOS}" ]; then
  echo "error: could not locate Flutter/Generated.xcconfig from Iconify script." >&2
  exit 1
fi

PROJECT_ROOT="$(cd "${APP_IOS}/.." && pwd)"

# Xcode Archive / GUI builds do not put Flutter's dart on PATH.
if [ -z "${FLUTTER_ROOT:-}" ]; then
  FLUTTER_ROOT="$(grep -E '^FLUTTER_ROOT=' "${APP_IOS}/Flutter/Generated.xcconfig" | cut -d= -f2- | tr -d '\r')"
fi
if [ -z "${FLUTTER_ROOT:-}" ] && [ -f "${APP_IOS}/Flutter/flutter_export_environment.sh" ]; then
  # shellcheck disable=SC1091
  . "${APP_IOS}/Flutter/flutter_export_environment.sh"
fi

DART=""
if [ -n "${FLUTTER_ROOT:-}" ] && [ -x "${FLUTTER_ROOT}/bin/dart" ]; then
  export PATH="${FLUTTER_ROOT}/bin:${PATH}"
  DART="${FLUTTER_ROOT}/bin/dart"
elif command -v dart >/dev/null 2>&1; then
  DART="$(command -v dart)"
fi

if [ -z "${DART}" ]; then
  echo "error: dart not found (FLUTTER_ROOT='${FLUTTER_ROOT:-}')." >&2
  exit 1
fi

cd "${PROJECT_ROOT}"
"${DART}" run iconify_full:iconify_subset --project . --no-pubspec
SCRIPT
    :execution_position => :before_compile,
    :always_out_of_date => '1'
  }
end
