require './test/test_helper'

describe Scheduler do
  describe "me" do
    it "should never be nil, always the same" do
      refute_nil first = Scheduler.me
      refute_nil second = Scheduler.me
      assert_same first, second
    end

    it "should exposes its internal queue" do
      refute_nil Scheduler.me.queue
      assert_respond_to Scheduler.me.queue, :<<
      assert_respond_to Scheduler.me.queue, :pop
    end
  end

  describe "plan" do
    it "can enqueue jobs" do
      @i, @j = 0, 0
      Scheduler.plan {|q| @j = 1337}
      Scheduler.plan {|q| @i = 42}
      sleep 0.001
      Scheduler.flush
      assert_equal 42, @i
      assert_equal 1337, @j
    end
  end
end
