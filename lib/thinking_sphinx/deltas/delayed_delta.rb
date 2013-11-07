require 'thinking_sphinx'
require 'thinking_sphinx/deltas/delayed_delta/delta_job'
require 'thinking_sphinx/deltas/delayed_delta/flag_as_deleted_job'
require 'thinking_sphinx/deltas/delayed_delta/job'
require 'thinking_sphinx/deltas/delayed_delta/version'

# Delayed Deltas for Thinking Sphinx, using Resque.
#
# This documentation is aimed at those reading the code. If you're looking for
# a guide to Thinking Sphinx and/or deltas, I recommend you start with the
# Thinking Sphinx site instead - or the README for this library at the very
# least.
#
# @author Patrick Allan, modified to use Resque by Alan MacDougall for Paperless Post
# @see http://ts.freelancing-gods.com Thinking Sphinx
#
class ThinkingSphinx::Deltas::DelayedDelta < ThinkingSphinx::Deltas::DefaultDelta

  # Adds a job to the queue for processing the given model's delta index. A job
  # for hiding the instance in the core index is also created, if an instance is
  # provided.
  #
  # Neither job will be queued if updates or deltas are disabled, or if the
  # instance (when given) is not toggled to be in the delta index. The first two
  # options are controlled via ThinkingSphinx.updates_enabled? and
  # ThinkingSphinx.deltas_enabled?.
  #
  # @param [Class] model the ActiveRecord model to index.
  # @param [ActiveRecord::Base] instance the instance of the given model that
  #   has changed. Optional.
  # @return [Boolean] true
  #
  def index(model, instance = nil)
    return true if skip? instance
    return true if instance && !toggled(instance)

    Resque.enqueue(ThinkingSphinx::Deltas::DeltaJob, model.delta_index_names)

    # Delete from core index, since it will be in the delta index now; a full
    # indexer run will periodically merge the delta index into core.
    if instance
      Resque.enqueue(ThinkingSphinx::Deltas::FlagAsDeletedJob,
                     model.core_index_names, instance.sphinx_document_id)
    end

    true
  end

  private

  # Checks whether jobs should be enqueued. Only true if updates and deltas are
  # enabled, and the instance (if there is one) is toggled.
  #
  # @param [ActiveRecord::Base, NilClass] instance
  # @return [Boolean]
  #
  def skip?(instance)
    !ThinkingSphinx.updates_enabled? ||
    !ThinkingSphinx.deltas_enabled?  ||
    (instance && !toggled(instance))
  end
end
