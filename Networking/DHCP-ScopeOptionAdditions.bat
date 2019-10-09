@ECHO OFF
:StartOver
echo.
echo Manually adding DHCP Scope Options if Domain Controller is too old to handle PowerShell cmdlets to do this...
echo.
SET /p DHCPsrv ="Enter IP of the DHCP Server (ex: 10.0.0.35): "
SET /p Scope="Enter ScopeId of Scope currently lacking options (ex: 10.0.27.0): "
SET Router=%Scope:~0,-1%
SET Router=%Router%1
SET /p RouterResult="Is "%Router%" the correct Router address? (y/n): "
IF /i "%RouterResult%" == "y" GOTO RouterGood
IF /i "%RouterResult%" == "Y" GOTO RouterGood
:RouterManual
SET /p Router="Enter Router IP Value for %Scope% : "
:RouterGood
echo.
echo Choose one of the following for the type of scope you're adding:
echo 1: Workstation
echo 2: Phone
echo 3: Secure_WLAN
echo 4: Workstation/Phone
echo.
SET /p Type="Type: "
IF /i "%Type%" == "1" GOTO Workstation
IF /i "%Type%" == "2" GOTO Phone
IF /i "%Type%" == "3" GOTO Wireless
IF /i "%Type%" == "4" GOTO WorkstationPhone
ECHO Invalid Option
GOTO end
:Workstation
ECHO.
ECHO "Adding Workstation Scope Options to %Scope%"
netsh dhcp server %DHCPsrv% scope %Scope% set optionvalue 003 IPADDRESS %Router%
netsh dhcp server %DHCPsrv% scope %Scope% set optionvalue 176 STRING "L2Q=1,L2QVLAN=11"
netsh dhcp server %DHCPsrv% scope %Scope% set optionvalue 186 IPADDRESS 10.0.13.96
netsh dhcp server %DHCPsrv% scope %Scope% set optionvalue 190 WORD 443 
netsh dhcp server %DHCPsrv% scope %Scope% set optionvalue 242 STRING "L2Q=1,L2QVLAN=11"
netsh dhcp server %DHCPsrv% scope %Scope% set optionvalue 252 STRING "http://fny-proxysg:8081/accelerated_pac_base.pac"
goto end
:Phone
ECHO.
ECHO "Adding Phone Scope Options to %Scope%"
netsh dhcp server %DHCPsrv% scope %Scope% set optionvalue 003 IPADDRESS %Router%
netsh dhcp server %DHCPsrv% scope %Scope% set optionvalue 176 STRING "MCIPADD=10.0.48.105,MCPORT=1719,HTTPSRVR=10.0.48.110,VLANTEST=0"
netsh dhcp server %DHCPsrv% scope %Scope% set optionvalue 242 STRING "MCIPADD=10.0.48.105,MCPORT=1719,HTTPSRVR=10.0.48.110,VLANTEST=0"
goto end
:Wireless
ECHO.
ECHO "Adding Wireless Scope Options to %Scope%"
netsh dhcp server %DHCPsrv% scope %Scope% set optionvalue 003 IPADDRESS %Router%
netsh dhcp server %DHCPsrv% scope %Scope% set optionvalue 252 STRING "http://fny-proxysg:8081/accelerated_pac_base.pac"
goto end
:WorkstationPhone
ECHO.
ECHO "Adding Workstation Scope Options to %Scope%"
netsh dhcp server %DHCPsrv% scope %Scope% set optionvalue 003 IPADDRESS %Router%
netsh dhcp server %DHCPsrv% scope %Scope% set optionvalue 176 STRING "MCIPADD=10.0.48.105,MCPORT=1719,HTTPSRVR=10.0.48.110,VLANTEST=0"
netsh dhcp server %DHCPsrv% scope %Scope% set optionvalue 186 IPADDRESS 10.0.13.96
netsh dhcp server %DHCPsrv% scope %Scope% set optionvalue 190 WORD 443 
netsh dhcp server %DHCPsrv% scope %Scope% set optionvalue 242 STRING "MCIPADD=10.0.48.105,MCPORT=1719,HTTPSRVR=10.0.48.110,VLANTEST=0"
netsh dhcp server %DHCPsrv% scope %Scope% set optionvalue 252 STRING "http://fny-proxysg:8081/accelerated_pac_base.pac"
goto end
:end
echo.
SET /p StartOver="Run again? (y/n): "
IF /i "%StartOver%" == "y" GOTO StartOver
PAUSE
