require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module BurpSpecH

  #Food Stuff for Advanced Burp
  class Food
    attr_accessor :name, :tastiness, :prep_effort
    def initialize(name, tastiness, prep_effort)
      @name = name
      @tastiness = tastiness
      @prep_effort = prep_effort
    end
  end

  Foods = {'bacon' => {:taste =>  'awesome', :prep => 'nuke it'},
           'tofu' => {:taste => 'meh', :prep => 'mix it in something'},
           'beer' => {:taste => 'essential to life', :prep => 'mooch from buddy'},
           'sky' => {}
          }
  FoodNames = Foods.keys

  def self.make_food
    #make us an array of Food objects
    FoodNames.map do |food_name| Food.new(food_name, 
                                        Foods[food_name][:taste],
                                        Foods[food_name][:prep])
    end
  end

  #Baseic stuff for Basic (and Advanced) Burp

  NiceArray = [{:id => :a, :data => "A", :other_stuff => "aaa"},
               {:id => :b, :data => "B", :other_stuff => "bbb"},
               {:id => :c, :data => "C", :other_stuff => "ccc"}]
 
  #notice the last id typo
  DirtyArray = [{:id => :a, :data => "A", :other_stuff => "aaa"},
                {:id => :b, :data => "B", :other_stuff => "bbb"},
                {:id => :c, :data => "C", :other_stuff => "ccc"},
                {:iidd => :d, :data => "D"}]
end

describe "Basic Burp" do
  before(:each) do
    @nice_array = BurpSpecH::NiceArray

    @nice_burped = {:a => {:id => :a, :data => "A", :other_stuff => "aaa"},
                    :b => {:id => :b, :data => "B", :other_stuff => "bbb"},
                    :c => {:id => :c, :data => "C", :other_stuff => "ccc"}}

    @not_an_array = @nice_burped #its a hash now

    #notice the last id typo
    @dirty_array = BurpSpecH::DirtyArray

    @dirty_burped = @nice_burped

    @dirty_left_overs = [{:iidd => :d, :data => "D"}]

    @filtered_burp =  {:a => {:data => "A"},
                       :b => {:data => "B"},
                       :c => {:data => "C"}}
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

  it "filters data" do
    filtered_burp = Burp.new(@dirty_array, :id, :data)
    filtered_burp.should == @filtered_burp
  end

  
end

describe "Advanced Burp" do
  include BurpSpecH

  before(:each) do
    @food_list = BurpSpecH.make_food
    @id_block = lambda{|item| item.name}
    @filtered_food_block = lambda{|item| item.prep_effort} 
    @filtered_simple_block = lambda{|item| item[:data].downcase}                    
    @nice_array = NiceArray
    @nice_burped_proc = {:a => "a",
                         :b => "b",
                         :c => "c"}
    @dirty_array = DirtyArray
    @dirty_bupred_proc = @nice_burped_proc
    @dirty_left_overs = [{:iidd => :d, :data => "D"}]
    @filtered_burp = {'bacon' => 'nuke it',
                      'tofu' => 'mix it in something',
                      'beer' => 'mooch from buddy',
                      'sky' => nil}
  end

  it "is passed a food list" do
    @food_list.should be_an Array
  end

  it "uses blocks for ids without vomiting" do
    my_burp = Burp.new(@food_list, @id_block)
    my_burp['bacon'].should be_a Food
    my_burp['bacon'].tastiness.should == "awesome"
    my_burp['bacon'].prep_effort.should == "nuke it"
    
    #comprehensive test
    FoodNames.each do |food_name|
      my_burp[food_name].should be_a Food
      my_burp[food_name].tastiness.should == Foods[food_name][:taste]
      my_burp[food_name].prep_effort.should == Foods[food_name][:prep]
    end
  end

  it "uses blocks for nice data without vomiting" do
    my_burp = Burp.new(@nice_array, :id, @filtered_simple_block)
    my_burp.should == @nice_burped_proc
  end

  it "uses blocks for dirty data without vomiting" do
    my_dirty_burp = Burp.new(@dirty_array, :id, @filtered_simple_block)
    my_dirty_burp.should == @nice_burped_proc
    my_dirty_burp.left_overs.should == @dirty_left_overs
  end

  it "uses blocks for both ids and data without vomiting" do
    my_burp = Burp.new(@food_list, @id_block, @filtered_food_block)
    my_burp.should == @filtered_burp
  end

end
