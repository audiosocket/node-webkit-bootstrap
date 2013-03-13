require "zip/zip"

namespace :app do
  namespace :build do
    desc "Build app for all platforms"
    task :all => ["win:ia32", "osx:ia32", "linux:ia32", "linux:x64"]

    namespace :osx do
      desc "Build OSX 32bit bundle"
      task :ia32 => ["tmp/app", "tmp/node-webkit"] do
        build_nw "osx-ia32"
        basedir = "/tmp/app-osx-ia32"

        FileUtils.rm_rf basedir
        FileUtils.cp_r  "tmp/node-webkit/osx/ia32", basedir
        FileUtils.cp    "build/app-osx-ia32.nw",    "#{basedir}/Contents/Resources/app.nw"

        archive = "build/app-osx-ia32.zip"
        puts "Creating #{archive}"

        FileUtils.rm_f archive
        Zip::ZipFile.open archive, Zip::ZipFile::CREATE do |zip|
          Dir["#{basedir}/**/*"].each do |file|
            file.gsub! "#{basedir}/", ""
            target = "node-webkit-bootstrap.app/#{file}"

            puts "Adding #{target}"
            zip.add target, "#{basedir}/#{file}"
          end
        end
      end
    end

    namespace :win do
      desc "Build windows 32bit bundle"
      task :ia32 => ["tmp/app", "tmp/node-webkit"] do
        build_nw "win-ia32"
        basedir = "tmp/app-win-ia32"

        FileUtils.rm_rf   basedir
        FileUtils.cp_r    "tmp/node-webkit/win/ia32", basedir
        sh "cat #{basedir}/nw.exe build/app-win-ia32.nw > #{basedir}/app.exe"
        FileUtils.rm      "#{basedir}/nw.exe"

        archive = "build/app-win-ia32.zip"
        puts "Creating #{archive}"

        FileUtils.rm_f archive
        Zip::ZipFile.open archive, Zip::ZipFile::CREATE do |zip|
          Dir["#{basedir}/**/*"].each do |file|
            file.gsub! "#{basedir}/", ""
            target = "node-webkit-bootstrap/#{file}"

            puts "Adding #{target}"
            zip.add target, "#{basedir}/#{file}"
          end
        end
      end
    end

    namespace :linux do
      desc "Build linux 32bit bundle"
      task :ia32 => ["tmp/app", "tmp/node-webkit"] do
        build_linux_app :ia32
      end

      desc "Build linux 64bit bundle"
      task :x64 => ["tmp/app", "tmp/node-webkit"] do
        build_linux_app :x64
      end
    end

    desc "Prepare .nw file"
    task :nw, [:platform] => "tmp/app" do |t, args|
      build_nw args[:platform]
    end

    file "tmp/app" => FileList["app/**/*"] do
      FileUtils.mkdir_p "tmp"
      FileUtils.rm_rf   "tmp/app"
      FileUtils.cp_r    "app", "tmp"
      FileUtils.cp_r    "tmp/app/package.json.production", "tmp/app/package.json"
      FileUtils.rm_f    "tmp/app/package.json.dev"
      FileUtils.rm_f    "tmp/app/package.json.production"
    end

    def build_nw platform = "osx-ia32"
      FileUtils.mkdir_p "build"
      FileUtils.rm_rf   "build/app-#{platform}.nw"
      archive = "build/app-#{platform}.nw"

      puts "Creating #{archive}"
      Zip::ZipFile.open archive, Zip::ZipFile::CREATE do |zip|
        FileList["tmp/app/**/*"].each do |file|
          target = file.sub("tmp/app/","")
          puts "Adding #{target}"
          zip.add target, file
        end
      end
    end

    def build_linux_app arch
      build_nw "linux-#{arch}"
      basedir = "tmp/app-linux-#{arch}"

      FileUtils.rm_rf   basedir
      FileUtils.cp_r    "tmp/node-webkit/linux/#{arch}", basedir
      sh "cat #{basedir}/nw build/app-linux-#{arch}.nw > #{basedir}/app"
      FileUtils.chmod   0755, "#{basedir}/app"
      FileUtils.rm      "#{basedir}/nw"

      archive = "build/app-linux-#{arch}.zip"
      puts "Creating #{archive}"

      FileUtils.rm_f archive
      Zip::ZipFile.open archive, Zip::ZipFile::CREATE do |zip|
        Dir["#{basedir}/**/*"].each do |file|
          file.gsub! "#{basedir}/", ""
          target = "node-webkit-bootstrap/#{file}"

          puts "Adding #{target}"
          zip.add target, "#{basedir}/#{file}"
        end
      end
    end
  end
end
