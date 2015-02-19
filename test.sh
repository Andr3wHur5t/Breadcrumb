gem install xcpretty --no-rdoc --no-ri --no-document --quiet
set -o pipefail && xcodebuild -workspace Breadcrumb.xcworkspace -sdk iphonesimulator -scheme Breadcrumb -configuration Debug test | xcpretty -c

# xctool is broken ref: https://github.com/facebook/xctool/issues/415
# xctool -workspace Breadcrumb.xcworkspace -scheme Breadcrumb -sdk iphonesimulator test
