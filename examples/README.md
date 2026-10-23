# Fire TV debloat lists

One folder per device, each with a `debloat.txt` of packages to switch off, grouped and commented. Comment out
anything you use. Fire OS 5 needs `HIDE=1` (see the 2nd-gen stick's header); Fire OS 6 and 7 take the default.

| Folder | TV | OS | Notes |
|---|---|---|---|
| `amazon-fire-tv-stick-2nd-gen-aftt/` | Amazon Fire TV Stick 2nd gen (AFTT, tank), India | Fire OS 5.2.9.5 / Android 5.1 | Set up with no physical remote (tools/firetv.py, then tools/remote.py); Fire OS 5.2.9.5 refuses pm disable-user for every package and pm hide for system ones, so only owner-installed apps are hidden (HIDE=1); animation scales 0.5; YouTube-only home from firehome/ (accessibility watcher over Amazon's home); Wi-Fi provisioning and remote API services kept |
| `amazon-fire-tv-stick-4k-2018/` | Amazon Fire TV Stick 4K, 1st gen 2018 (AFTMM, mantis) | Fire OS 6.7.1.1 / Android 7.1 | First Fire OS 6 list: Amazon telemetry, ad/recommendation feeders, Live tab and Fire TV Channels, Shopping, Kids, Music/Photos/Silk, whole-home audio, Alexa extras; unused streaming apps off by choice; ten protected packages noted; voice search, OTA, casting kept; debloat only, sponsored rows need DNS blocking |
| `insignia-ns55f301na25/` | Insignia 55" F30 4K Fire TV (NS-55F301NA25, AFTDCT31, duckie) | Fire OS 7 / Android 9 | Amazon ACR telemetry, Fire TV ads/shopping, Alexa, OTA updates; AirPlay and TIF HDMI inputs kept |
| `amazon-fire-tv-stick-3rd-gen-aftsss/` | Amazon Fire TV Stick 3rd gen (AFTSSS, sheldonp) | Fire OS 7.7.1.7 / Android 9 | Toshiba list plus Insignia's telemetry entries; three protected packages noted; com.amazon.tv.oobe kept (owns the saved Wi-Fi network); Netflix, FIFA+ and Prime Video off by choice; animation scales 0.5; firehome/ with UniTV, YouTube and Spotify tiles (Amazon's home shows for ~3-5 s after Home, Android's app-switch delay) |
| `toshiba-fire-tv-aftha004/` | Toshiba Fire TV (AFTHA004, hazel) | Fire OS 7 / Android 9 | Amazon ACR, metrics, shopping, tutorials, Miracast sink; streaming preloads off by choice; debloat only |
