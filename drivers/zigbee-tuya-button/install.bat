#!/bin/bash
@REM # CLI Commands
@REM smartthings edge:channels:assign
@REM smartthings edge:channels:create
@REM smartthings edge:channels:delete %channel%
@REM smartthings edge:channels:drivers %channel%
@REM smartthings edge:channels:enroll %hub%
@REM smartthings edge:channels:enrollments %hub%
@REM smartthings edge:channels:unassign --channel %channel%
@REM smartthings edge:channels:unenroll %hub%
@REM smartthings edge:channels:update
@REM smartthings edge:channels:invitations:create
@REM smartthings edge:channels:invitations:delete
@REM smartthings edge:drivers:delete
@REM smartthings edge:drivers:install %driverId% --channel %channel% --hub %hub%
@REM smartthings edge:drivers:installed --hub %hub%
@REM smartthings edge:drivers:logcat --hub-address=%hub_address% --all
@REM smartthings edge:drivers:package ./
@REM smartthings edge:drivers:uninstall --hub %hub%

@REM # For window : zigee-tuya-button
set driverId=95b94182-0102-47ce-acef-553cbd8aa6d6
set channel=143f8c3b-5fcf-4013-a795-49bf690eb3b9
set hub=37d997a3-7579-47f2-8ae9-804fce729f7b
set hub_address=192.168.0.119

@REM # Each OS will show error like "command not found", but it's ok
smartthings edge:drivers:uninstall %driverId% --hub %hub%
smartthings edge:drivers:package ./
smartthings edge:drivers:publish %driverId% --channel %channel%
smartthings edge:drivers:install %driverId% --channel %channel% --hub %hub%
smartthings edge:drivers:logcat %driverId% --hub-address=%hub_address%

@REM # For Posix : zigee-tuya-button
@REM driverId=5bbfa147-9fc5-4fd3-85b3-b053937a4341
@REM channel=699fefe6-7b99-40b2-acfd-662ed510a84d
@REM hub=37d997a3-7579-47f2-8ae9-804fce729f7b
@REM hub_address=192.168.0.119

@REM smartthings edge:drivers:uninstall $driverId --hub $hub
@REM smartthings edge:drivers:package ./
@REM smartthings edge:drivers:publish $driverId --channel $channel
@REM smartthings edge:drivers:install $driverId --channel $channel --hub $hub
@REM smartthings edge:drivers:logcat --hub-address=$hub_address --all