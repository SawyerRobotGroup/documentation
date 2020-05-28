fvm install stable
cp features.dart ~/fvm/versions/stable/packages/flutter_tools/lib/src/features.dart
rm ~/fvm/versions/stable/bin/cache/flutter_tools.snapshot
fvm use stable
./fvm doctor