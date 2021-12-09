#!/bin/sh
#$1 = yaml file path
#$2 = App Id
#$3 = App Name
echo "Configurating"

#Launcher Icon
flutter pub run --no-sound-null-safety flutter_launcher_icons:main -f env/$1

#variable config
flutter pub run --no-sound-null-safety environment_config:generate --config=env/$1

#adjust path to outer layer first where rename will find for android and ios folder
cd ../../

#App PackageId
dart pub global run rename --bundleId $2

#App Name
dart pub global run rename --appname $3



echo "Done"
