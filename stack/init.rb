package :init do
  description "Initial Ubuntu configuration"
  requires :build_essential
  requires :imagemagick
end

package :build_essential do
  description 'Build tools'
  apt 'build-essential' do
    pre :install, 'apt-get update'
  end
end

package :imagemagick do
  description "Image Magick"
  apt 'imagemagick librmagick-ruby'
  verify do
    has_executable "convert"
  end
end
