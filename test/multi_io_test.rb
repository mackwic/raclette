require './test/test_helper.rb'
require 'stringio'

describe Raclette::MultiIO do
  it 'can duplicate IO streams' do
    io1, io2, io3 = StringIO.new, StringIO.new, StringIO.new
    io0 = MultiIO.new(io1, io2, io3)

    io0.write 'RACLETTE TIME !'
    io0.write ' Raclette du fromage !'
    expected = 'RACLETTE TIME ! Raclette du fromage !'
    assert_equal expected, io1.string
    assert_equal expected, io2.string
    assert_equal expected, io3.string
  end
end
