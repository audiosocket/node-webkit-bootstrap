namespace :app do
  desc "Run the app."
  task :run, [:mode, :platform] => "tmp/node-webkit" do |t, args|
    mode     = args[:mode]     || :dev
    platform = args[:platform] || "osx/ia32"
    FileUtils.cp "app/package.json.#{mode}", "app/package.json"
    sh "tmp/node-webkit/#{platform}/Contents/MacOS/node-webkit ./app"
  end
end
