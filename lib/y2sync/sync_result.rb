
module Y2sync
  class SyncResult
    attr_reader :success
    attr_reader :empty_repo
    attr_reader :error_msg

    def initialize(success:, empty_repo:, error_msg:)
      @success = success
      @empty_repo = empty_repo
      @error_msg = error_msg
    end
  end
end
