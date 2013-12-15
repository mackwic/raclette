require './test/test_helper'

describe Raclette::Scheduler do

  describe "me is a valid instance" do
    it "should never be nil, always the same" do
      refute_nil first = Raclette::Scheduler.me
      refute_nil second = Raclette::Scheduler.me
      assert_same first, second
    end

    it "should exposes its internal queue" do
      refute_nil Raclette::Scheduler.me.queue
      assert_respond_to Raclette::Scheduler.me.queue, :<<
      assert_respond_to Raclette::Scheduler.me.queue, :pop
    end
  end

  #describe "plan" do

  #  before do
  #    @mock = []
  #  end

  #  class QueueStub
  #    def queue

  #    end
  #  end

  #  class Raclette::Scheduler
  #    def self.me
  #    end
  #  end
  #  it "can enqueue jobs" do

  #  end
  #end
end
