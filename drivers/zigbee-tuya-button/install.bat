#!/bin/bash
@REM # CLI Commands
@REM # smartthings edge:channels:create
@REM # smartthings edge:channels:enroll %hub%
@REM # smartthings edge:channels:unenroll %hub%
@REM # smartthings edge:channels:enrollments %hub%
@REM # smartthings edge:channels:drivers %channel%
@REM # smartthings edge:channels:delete %channel%
@REM # smartthings edge:channels:invitations:create
@REM # smartthings edge:channels:invitations:delete
@REM # smartthings edge:drivers:delete
@REM # smartthings edge:drivers:installed --hub %hub%
@REM # smartthings edge:drivers:uninstall --hub %hub%

@REM # For window : zigee-tuya-button
set driverId=5bbfa147-9fc5-4fd3-85b3-b053937a4341
set channel=f86b30bb-00d0-4b90-8849-53beb1109dba
set hub=37d997a3-7579-47f2-8ae9-804fce729f7b
set hub_address=192.168.0.119

@REM # For Posix : zigee-tuya-button
driverId=5bbfa147-9fc5-4fd3-85b3-b053937a4341
channel=f86b30bb-00d0-4b90-8849-53beb1109dba
hub=37d997a3-7579-47f2-8ae9-804fce729f7b
hub_address=192.168.0.119

@REM # Each OS will show error like "command not found", but it's ok
smartthings edge:drivers:uninstall %driverId% --hub %hub%
smartthings edge:drivers:package ./
smartthings edge:drivers:publish %driverId% --channel %channel%
smartthings edge:drivers:install %driverId% --channel %channel% --hub %hub%
smartthings edge:drivers:logcat --hub-address=%hub_address% --all

smartthings edge:drivers:uninstall $driverId --hub $hub
smartthings edge:drivers:package ./
smartthings edge:drivers:publish $driverId --channel $channel
smartthings edge:drivers:install $driverId --channel $channel --hub $hub
smartthings edge:drivers:logcat --hub-address=$hub_address --all


52e42f69-a8ea-4ab6-91f2-3a3087fa9840