require 'RMagick'
include Magick

# = Rmagickable
# === A simple rails plugin that exposes RMagick functionality in Rails controllers
#
# :title:Rmagicable
# Author:: Zohar Arad
# Requires:: RMagic

module Rmagickable
  # include Rmagickable modules
  include Resizable
  def self.included(base)
    base.extend(Resizable::ClassMethods)
  end
end