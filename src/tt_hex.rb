#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'sketchup.rb'
require 'extensions.rb'

#-------------------------------------------------------------------------------

module TT
 module Plugins
  module Hex

  ### CONSTANTS ### ------------------------------------------------------------

  # Resource paths
  file = __FILE__.dup
  file.force_encoding("UTF-8") if file.respond_to?(:force_encoding)
  SUPPORT_FOLDER_NAME = File.basename(file, '.*').freeze
  PATH_ROOT           = File.dirname(file).freeze
  PATH                = File.join(PATH_ROOT, SUPPORT_FOLDER_NAME).freeze

  # Extension information
  PLUGIN          = self
  PLUGIN_ID       = 'TT_Hex'.freeze
  PLUGIN_NAME     = 'Hex'.freeze
  PLUGIN_VERSION  = File.read(File.join(PATH, "version.txt")).strip.freeze


  ### EXTENSION ### ------------------------------------------------------------

  unless file_loaded?(__FILE__)
    loader = File.join(PATH, 'bootstrap')
    ex = SketchupExtension.new(PLUGIN_NAME, loader)
    ex.description = 'Hexagonal goodness :)'
    ex.version     = PLUGIN_VERSION
    ex.copyright   = 'Thomas Thomassen © 2016'
    ex.creator     = 'Thomas Thomassen (thomas@thomthom.net)'
    @extension = ex
    Sketchup.register_extension(@extension, true)
  end

  end # module HEx
 end # module Plugins
end # module TT

#-------------------------------------------------------------------------------

file_loaded(__FILE__)

#-------------------------------------------------------------------------------