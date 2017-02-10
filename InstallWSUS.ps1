Install-WindowsFeature -Name UpdateServices -IncludeManagementTools
New-Item -Path D: -Name WsusContent -ItemType Directory
sleep -Seconds '20'
cd “C:\Program Files\Update Services\Tools”
sleep -Seconds '20'
.\wsusutil.exe postinstall CONTENT_DIR=D:\WsusContent