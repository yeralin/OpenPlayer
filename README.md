[![codebeat badge](https://codebeat.co/badges/c8c60acc-0e63-4690-bc53-72508ee184f0)](https://codebeat.co/projects/github-com-yeralin-openplayer-master)

# Supported Features

## Start web file server over Wi-Fi
![](https://i.imgur.com/GPgBLIm.gif)

## Upload music through iTunes "File Sharing" (no sync required!)
![](https://i.imgur.com/oVrWYzd.jpg)

## Download music from a remote server
https://github.com/yeralin/OpenPlayer-Server

# Building

```bash
pod install
open MusicPlayer.xcworkspace
```

If your OpenPlayer-Server requires a username and password, copy
`Config/Secrets.example.xcconfig` to `Config/Secrets.xcconfig` (gitignored) and
fill them in. Without that file the app talks to the server unauthenticated.

# Security notes

- **The Wi-Fi web server has no password.** While it is switched on, anyone on
  the same network can open its address and upload, rename or delete files in
  the app's music folder. Only turn it on on networks you trust, and turn it
  off when you are done.
- **Plain HTTP is allowed.** The app turns off App Transport Security
  (`NSAllowsArbitraryLoads`) so it can reach self-hosted servers without TLS.
  Server credentials are then sent unencrypted; use `https://` where your
  server supports it.
