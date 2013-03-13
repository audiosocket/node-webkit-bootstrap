require "json"
require "zip/zip"

namespace NodeWebkitBootstrap::Rake.app do
  app     = NodeWebkitBootstrap::Rake.app
  package = NodeWebkitBootstrap::Rake.build_package
  path    = NodeWebkitBootstrap::Rake.path

  desc "Build #{app} (platform is one of: \"win\", \"linux\", \"osx\" or \"all\", default: \"all\")."
  task :build, [:platform] => ["tmp/node-webkit-bootstrap/#{app}-build", "tmp/node-webkit"] do |t, args|
    platform = args[:patform] || "all"

    if platform == "osx" or platform == "all"
      build_osx
    end
    if platform == "win" or platform == "all"
      build_win
    end
    if platform == "linux" or platform == "all"
      build_linux :ia32
      build_linux :x64
    end
  end

  file "tmp/node-webkit-bootstrap/#{app}-build" => FileList["#{path}/**/*"] do
    basedir = "tmp/node-webkit-bootstrap/#{app}-build"

    FileUtils.rm_rf   basedir
    FileUtils.mkdir_p basedir
    FileUtils.cp_r    FileList["#{path}/**/*"], basedir
    File.open "#{basedir}/package.json", "w" do |file|
      file.write JSON.pretty_generate(package)
    end
  end

  def build_osx
    app = NodeWebkitBootstrap::Rake.app

    build_nw "osx-ia32"
    basedir = "tmp/node-webkit-bootstrap/#{app}-osx-ia32"

    FileUtils.rm_rf basedir
    FileUtils.cp_r  "tmp/node-webkit/osx/ia32", basedir
    FileUtils.cp    "build/#{app}-osx-ia32.nw",    "#{basedir}/Contents/Resources/app.nw"

    archive = "build/#{app}-osx-ia32.zip"
    puts "Creating #{archive}"

    FileUtils.rm_f archive
    Zip::ZipFile.open archive, Zip::ZipFile::CREATE do |zip|
      Dir["#{basedir}/**/*"].each do |file|
        file.gsub! "#{basedir}/", ""
        target = "#{app}.app/#{file}"

        puts "Adding #{target}"
        zip.add target, "#{basedir}/#{file}"
      end
    end
  end

  def build_win
    app = NodeWebkitBootstrap::Rake.app

    build_nw "win-ia32"
    basedir = "tmp/node-webkit-bootstrap/#{app}-win-ia32"

    FileUtils.rm_rf   basedir
    FileUtils.cp_r    "tmp/node-webkit/win/ia32", basedir
    sh "cat #{basedir}/nw.exe build/#{app}-win-ia32.nw > #{basedir}/#{app}.exe"
    FileUtils.rm      "#{basedir}/nw.exe"

    archive = "build/#{app}-win-ia32.zip"
    puts "Creating #{archive}"

    FileUtils.rm_f archive
    Zip::ZipFile.open archive, Zip::ZipFile::CREATE do |zip|
      Dir["#{basedir}/**/*"].each do |file|
        file.gsub! "#{basedir}/", ""
        target = "#{app}/#{file}"

        puts "Adding #{target}"
        zip.add target, "#{basedir}/#{file}"
      end
    end
  end

  def build_nw platform = "osx-ia32"
    app = NodeWebkitBootstrap::Rake.app

    FileUtils.mkdir_p "build"
    FileUtils.rm_rf   "build/#{app}-#{platform}.nw"
    archive = "build/#{app}-#{platform}.nw"

    puts "Creating #{archive}"
    Zip::ZipFile.open archive, Zip::ZipFile::CREATE do |zip|
      FileList["tmp/node-webkit-bootstrap/#{app}-build/**/*"].each do |file|
        target = file.sub("tmp/node-webkit-bootstrap/#{app}-build/","")
        puts "Adding #{target}"
        zip.add target, file
      end
    end
  end

  def build_linux arch
    app = NodeWebkitBootstrap::Rake.app

    build_nw "linux-#{arch}"
    basedir = "tmp/node-webkit-bootstrap/#{app}-linux-#{arch}"

    FileUtils.rm_rf   basedir
    FileUtils.cp_r    "tmp/node-webkit/linux/#{arch}", basedir
    sh "cat #{basedir}/nw build/#{app}-linux-#{arch}.nw > #{basedir}/#{app}"
    FileUtils.chmod   0755, "#{basedir}/#{app}"
    FileUtils.rm      "#{basedir}/nw"

    archive = "build/#{app}-linux-#{arch}.zip"
    puts "Creating #{archive}"

    FileUtils.rm_f archive
    Zip::ZipFile.open archive, Zip::ZipFile::CREATE do |zip|
      Dir["#{basedir}/**/*"].each do |file|
        file.gsub! "#{basedir}/", ""
        target = "#{app}/#{file}"

        puts "Adding #{target}"
        zip.add target, "#{basedir}/#{file}"
      end
    end
  end
end
