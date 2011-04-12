require File.expand_path(File.dirname(__FILE__) + '/spec_helper')


describe "Burp" do
  before(:each) do
    @nice_array = [{:id => :a, :data => "A"},
                   {:id => :b, :data => "B"},
                   {:id => :c, :data => "C"}]
    @nice_burped = {:a => {:id => :a, :data => "A"},
                    :b => {:id => :b, :data => "B"},
                    :c => {:id => :c, :data => "C"}}

    @not_an_array = @nice_burped #its a hash now

    #notice the last id typo
    @dirty_array = [{:id => :a, :data => "A"},
                   {:id => :b, :data => "B"},
                   {:id => :c, :data => "C"},
                   {:iidd => :d, :data => "D"}]

    @dirty_burped = @nice_burped

    @dirty_left_overs = [{:iidd => :d, :data => "D"}]
  end

  it "makes a hash out of a nicely formed array" do
    my_burp = Burp.new(@nice_array, :id)
    my_burp.should == @nice_burped
  end

  it "raises an informative error message when it panics" do
    expect { Burp.new(@not_an_array) }.to raise_error(ArgumentError)
  end

  it "handles a dirty hash" do
    my_dirty_burp = Burp.new(@dirty_array, :id)
    my_dirty_burp.should == @dirty_burped
    my_dirty_burp.left_overs.should == @dirty_left_overs
  end
end
