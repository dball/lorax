require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Diffaroo::DeltaSetGenerator do
  describe "#generate_delta_set" do
    it "should generate an InsertDelta for an atomic node" do
      doc1 = xml { root1 }
      doc2 = xml { root2 }
      match_set = Diffaroo::MatchSet.new doc1, doc2
      delta_set = Diffaroo::DeltaSetGenerator.generate_delta_set(match_set)
      delta_set.deltas.length.should == 1
      delta_set.deltas.first.should be_instance_of(Diffaroo::InsertDelta)
    end

    it "should generate an InsertDelta for a subtree" do
      doc1 = xml { root1 }
      doc2 = xml { root2 { a1 ; a2 "hello" } }
      match_set = Diffaroo::MatchSet.new doc1, doc2
      delta_set = Diffaroo::DeltaSetGenerator.generate_delta_set(match_set)
      delta_set.deltas.length.should == 1
      delta_set.deltas.first.should be_instance_of(Diffaroo::InsertDelta)
    end

    it "does not generate InsertDeltas for children of a perfect match" do
      doc1 = xml { root { a1 "hello" } }
      doc2 = xml { root { a1 "hello" ; a2 } }
      match_set = Diffaroo::MatchSet.new doc1, doc2
      match_set.add Diffaroo::Match.new(doc1.at_css("root"), doc2.at_css("root"))
      match_set.add Diffaroo::Match.new(doc1.at_css("a1"),   doc2.at_css("a1"), :perfect => true)
      delta_set = Diffaroo::DeltaSetGenerator.generate_delta_set(match_set)
      puts delta_set.deltas.inspect
      delta_set.deltas.length.should == 1
      delta_set.deltas.first.should be_instance_of(Diffaroo::InsertDelta)
    end
  end
end
