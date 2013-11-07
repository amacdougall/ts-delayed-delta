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

    output = `#{config.bin_path}#{config.indexer_binary_name} --config "#{config.config_file}" --rotate #{indices.join(' ')}`
    puts output unless ThinkingSphinx.suppress_delta_output?

    true
  end
end
