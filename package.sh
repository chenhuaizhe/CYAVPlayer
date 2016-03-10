xcodebuild -project CCYYAVPlayer.xcodeproj -scheme CCYYAVPlayer archive -archivePath ./build/CCYYAVPlayer.xcarchive && \
rm -rf ./build/CCYYAVPlayer.ipa && \
xcodebuild -exportArchive -exportFormat ipa -archivePath build/CCYYAVPlayer.xcarchive -exportPath build/CCYYAVPlayer.ipa && \
fir p build/CCYYAVPlayer.ipa -T e48d493ab47ac8c85588b68e871cade8