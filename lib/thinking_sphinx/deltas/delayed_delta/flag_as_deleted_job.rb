# A simple job for flagging a specified Sphinx document in a given index as
# 'deleted'.
#
class ThinkingSphinx::Deltas::FlagAsDeletedJob
  @queue = :maintenance # as advised by @akahn

  # Updates the sphinx_deleted attribute for the given document, setting the
  # value to 1 (true). This is not a special attribute in Sphinx, but is used
  # by Thinking Sphinx to ignore deleted values between full re-indexing. It's
  # particularly useful in this situation to avoid old values in the core index
  # and just use the new values in the delta index as a reference point.
  #
  # Please note that the document id is Sphinx's unique identifier, and will
  # almost certainly not be the model instance's primary key value.
  #
  # @param [String] index The index name
  # @param [Integer] document_id The document id
  #
  # @return [Boolean] true
  #
  def self.perform(indices, document_id)
    config = ThinkingSphinx::Configuration.instance

    indices.each do |index|
      if ThinkingSphinx.sphinx_running? && ThinkingSphinx.search_for_id(document_id, index)
        config.client.update(index, ['sphinx_deleted'], {document_id => [1]})
      end
    end

    true
  end
end
