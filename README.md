Node-webkit-bootstrap
=====================

The `node-webkit-gem` Ruby gem provides a framework for bootstraping, running, building
and testing your [node-webkit](https://github.com/rogerwang/node-webkit) applications.

How to use?
-----------

`node-webkit-gem` provides a set of `rake` tasks that automatize the following tasks:
* Downloading `node-webkit`
* Preparing a runtime directory
* Bundling a stand-alone version of your app
* Running tests using `node-webkit`

### Basic Layout

Here is a typical layout:
```
(root)
|-- Gemfile
|-- Rakefile
|-- app/{index.html, js/, ...}
       |-- vemdor/arch/win/ia32/win.js
       |-- vendor/arch/osx/ia32/osx.js
|-- vendor/node-webkit-bootstrap/node-webkit/win/ia32/foo.dll
|-- vendor/node-webkit-bootstrap/node-webkit/osx/ia32/Contents/Frameworks/node-webkit Helper.app/Contents/MacOS/libfoo.so
|-- test/{index.html, js, ...}
```

With:
```
% cat Gemfile
(...)
gem "node-webkit-bootstrap", "~> 1.0.0"
```

```
% cat Rakefile
(...)
require "node-webkit-bootstrap/rake"

NodeWebkitBootstrap::Rake.register do |config|
  config.app = "my-awesome-app"
  
  here = File.expand_path "..", __FILE__
  config.app_path  = "#{here}/app"
  config.test_path = "#{here}/test" 

  config.run_package = {
    name: config.app,
    main: "index.html",
    window: {
      toolbar: true,
      width:   660,
      height:  500
    }
  }

  config.build_package = {
    name: config.app,
    main: "index.html",
    window: {
      toolbar: false,
      width:   660,
      height:  500
    }
  }

  config.test_package = {
    name: config.app,
    main: "index.html",
    window: {
      show: false
    }
  }
end
```

This will configure the following rake tasks:
```
% rake -T
(...)
rake my-awesome-app:build[platform]    # Build my-awesome-task (platform is one of: "win", "linux", "osx" or "all", default: "all").
rake my-awesome-app:download[version]  # Download latest node-webkit code (default version: 0.4.2).
rake my-awesome-app:run                # Run my-awesome-task.
rake my-awesome-app:test               # Run my-awesome-task tests.
```

### Downloading node-webkit

The download task will download `node-webkit` binaries for all available architectures and create
a `tmp/node-webkit/#{platform}/#{arch}`. Available architectures at the time of writing are:
```
# format: platform => [architectures]
{ linux:  [:ia32, :x64],
   osx:    [:ia32],
   win:    [:ia32] }
```

Running the download task yields:
```
% rake my-awesome-app:download
(...)
Downloading node-wekbit binary for osx ia32
Downloading https://s3.amazonaws.com/node-webkit/v0.4.2/node-webkit-v0.4.2-osx-ia32.zip to tmp/node-webkit-v0.4.2-osx-ia32.zip
Decompressing tmp/node-webkit-v0.4.2-osx-ia32.zip
(...)
Extracting Contents/Frameworks/node-webkit Helper.app/Contents/MacOS/node-webkit Helper
Extracting Contents/Frameworks/node-webkit Helper.app/Contents/PkgInfo
Extracting Contents/Info.plist
Extracting Contents/MacOS
Extracting Contents/MacOS/node-webkit
Extracting Contents/PkgInfo
Extracting Contents/Resources
Extracting Contents/Resources/nw.icns
Vendoring Contents/Frameworks/node-webkit Framework.framework/Libraries/ffmpegsumo.so
Vendoring Contents/Frameworks/node-webkit Helper.app/Contents/MacOS/libfoo.so
Done!

Downloading node-wekbit binary for win ia32
(...)
```

All the files from `node-webkit`'s archive are thus extracted and the `libfoo.so` file is picked
from the `vendor/node-webkit-bootstrap/node-webkit/osx/ia32` folder.

All files placed in to a `vendor/node-webkit-bootstrap/node-webkit/#{platform}/#{arch}` folder
will likewise be added to the corresponding `node-webkit`'s directory.

Please note that, be default. `node-webkit-bootstrap` will vendor GPL versions of the `ffmpeg`
library to gain proper multimedia playback.
