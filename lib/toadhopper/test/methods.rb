require 'toadhopper'

module Toadhopper
module Test
# Helper methods for testing Toadhopper posting
module Methods
  # Stub the posting of the error, storing the post params for accessing via
  # last_toadhopper_post_params
  def stub_toadhopper_post!
    def Toadhopper.post!(*args)
      Toadhopper.instance_variable_set(:@last_post_arguments, args)
    end
  end
  def last_toadhopper_post_arguments
    Toadhopper.instance_variable_get(:@last_post_arguments)
  end
end
end
end
