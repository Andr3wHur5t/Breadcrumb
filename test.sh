gem install xcpretty --no-rdoc --no-ri --no-document --quiet
set -o pipefail && xcodebuild -workspace Breadcrumb.xcworkspace -sdk iphonesimulator -scheme Breadcrumb -configuration Debug test | xcpretty -c
