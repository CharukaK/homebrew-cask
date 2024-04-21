cask "choreo-cli" do
  version "v0.0.43"
  arch arm: "arm64", intel: "amd64"
  sha256 arm: "404574ea6c3876a7780d947510482adf68311943918b9281d59c834e296f31ae",
    intel: "d8a39673cb9fde0140241d07c30d6e4511e3e986c1b0a1ddc8051e4b53be6985"

  url "https://github.com/wso2/choreo-cli/releases/download/#{version}/choreo-cli-#{version}-darwin-#{arch}.zip",
    verified: "github.com/wso2/choreo-cli/"
  name "Choreo CLI"
  homepage "https://github.com/wso2/choreo-cli"

  livecheck do
    url :url
    strategy :github_latest
  end

  # unzip the downloaded file
  binary "choreo"

  # post-install message
  postflight do
    user_home = ENV["HOME"]
    choreo_home = "#{user_home}/.choreo"

    detected_profile = ""
    completion_script = ""

    # Create the .choreo directory
    FileUtils.mkdir_p choreo_home

    if ENV["SHELL"].include? "bash"
      if File.exist?("#{user_home}/.bashrc")
        detected_profile = "#{user_home}/.bashrc"
      elsif File.exist?("#{user_home}/.bash_profile")
        detected_profile = "#{user_home}/.bash_profile"
      end
      # Genereate the completion script for the Choreo CLI
      # save output to a variable
      completion_script = `#{staged_path}/choreo completion bash`
    elsif ENV["SHELL"].include? "zsh"
      if File.exist?("#{user_home}/.zshrc")
        detected_profile = "#{user_home}/.zshrc"
      elsif File.exist?("#{user_home}/.zprofile")
        detected_profile = "#{user_home}/.zprofile"
      end
      # Genereate the completion script for the Choreo CLI
      # save output to a variable
      completion_script = `#{staged_path}/choreo completion zsh`
    end

    if !completion_script.empty?
      # Create the file to store the completion script
      FileUtils.mkdir_p "#{choreo_home}/bin"

      # write the completion script to a file
      File.open("#{choreo_home}/bin/choreo-completion", "w") { |file| file.write(completion_script) }
    end

    if detected_profile.empty?
      if File.exist?("#{user_home}/.profile")
        detected_profile = "#{user_home}/.profile"
      elsif File.exist?("#{user_home}/.bashrc")
        detected_profile = "#{user_home}/.bashrc"
      elsif File.exist?("#{user_home}/.bash_profile")
        detected_profile = "#{user_home}/.bash_profile"
      elsif File.exist?("#{user_home}/.zshrc")
        detected_profile = "#{user_home}/.zshrc"
      elsif File.exist?("#{user_home}/.zprofile")
        detected_profile = "#{user_home}/.zprofile"
      end
    end


    if File.exist? detected_profile
      # Check if the profile file already contains the Choreo CLI completion script
      unless File.foreach(detected_profile).grep(/choreo-completion/).any?
        File.open(detected_profile, "a") do |file|
          file.write("\n# Choreo CLI\n")
          file.write("[ -f \$CHOREO_DIR/bin/choreo-completion ] && source \$CHOREO_DIR/bin/choreo-completion")
        end
      end

      # Source the profile file
      system("source #{detected_profile}")
    end
  end
end
