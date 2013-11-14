require 'yaml'

# A simple job class that processes a given index.
#
class ThinkingSphinx::Deltas::DeltaJob
  @queue = :maintenance # as advised by @akahn

  # Runs Sphinx's indexer tool to process the index. Currently assumes Sphinx
  # is running.
  #
  # @return [Boolean] true
  #
  def self.perform(indices)
    config = ThinkingSphinx::Configuration.instance
    data = YAML.load_file "config/sphinx.yml"
    sphinx_node = data[Rails.env]["address"].first

    # this job may not be running on the Sphinx node; SSH to it as paperless (the default) to sidestep the issue
    command = "ssh #{sphinx_node} '#{config.bin_path}#{config.indexer_binary_name} --config #{config.config_file} --rotate #{indices.join(' ')}'"

    output = `#{command}`
    puts output unless ThinkingSphinx.suppress_delta_output?

    true
  end
end
