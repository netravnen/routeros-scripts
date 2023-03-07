#!rsc by RouterOS
# RouterOS script: capsman-rolling-upgrade
# Copyright (c) 2018-2023 Christian Hesse <mail@eworm.de>
#                         Michael Gisbers <michael@gisbers.de>
# https://git.eworm.de/cgit/routeros-scripts/about/COPYING.md
#
# upgrade CAPs one after another
# https://git.eworm.de/cgit/routeros-scripts/about/doc/capsman-rolling-upgrade.md

:local 0 "capsman-rolling-upgrade";
:global GlobalFunctionsReady;
:while ($GlobalFunctionsReady != true) do={ :delay 500ms; }

:global LogPrintExit2;
:global ScriptLock;

$ScriptLock $0;

:local InstalledVersion [ /system/package/update/get installed-version ];

:local RemoteCapCount [ :len [ /caps-man/remote-cap/find ] ];
:if ($RemoteCapCount > 0) do={
  :local Delay (600 / $RemoteCapCount);
  :if ($Delay > 120) do={ :set Delay 120; }
  :foreach RemoteCap in=[ /caps-man/remote-cap/find where version!=$InstalledVersion ] do={
    :local RemoteCapVal [ /caps-man/remote-cap/get $RemoteCap ];
    :if ([ :len $RemoteCapVal ] > 1) do={
      $LogPrintExit2 info $0 ("Starting upgrade for " . $RemoteCapVal->"name" . \
        " (" . $RemoteCapVal->"identity" . ")...") false;
      /caps-man/remote-cap/upgrade $RemoteCap;
    } else={
      $LogPrintExit2 warning $0 ("Remote CAP vanished, skipping upgrade.") false;
    }
    :delay ($Delay . "s");
  }
}
