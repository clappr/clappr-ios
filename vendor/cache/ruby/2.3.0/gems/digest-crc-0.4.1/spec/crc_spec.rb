require 'spec_helper'
require 'digest/crc'

describe Digest::CRC do
  it "should define block_length of 1" do
    crc = subject

    crc.block_length.should == 1
  end

  it "should pack to an empty String by default" do
    described_class.pack(0).should be_empty
  end

  context "when inherited" do
    subject do
      Class.new(described_class).tap do |klass|
        klass::WIDTH = 16

        klass::INIT_CRC = 0x01

        klass::XOR_MASK = 0x02

        klass::TABLE = [0x01, 0x02, 0x03, 0x04].freeze
      end
    end

    it "should override WIDTH" do
      subject::WIDTH.should_not == described_class::WIDTH
    end

    it "should override INIT_CRC" do
      subject::INIT_CRC.should_not == described_class::INIT_CRC
    end

    it "should override XOR_MASK" do
      subject::XOR_MASK.should_not == described_class::XOR_MASK
    end

    it "should override TABLE" do
      subject::TABLE.should_not == described_class::TABLE
    end

    describe "#initialize" do
      let(:instance) { subject.new }

      it "should initialize @init_crc" do
        instance.instance_variable_get("@init_crc").should == subject::INIT_CRC
      end

      it "should initialize @xor_mask" do
        instance.instance_variable_get("@xor_mask").should == subject::XOR_MASK
      end

      it "should initialize @width" do
        instance.instance_variable_get("@width").should == subject::WIDTH
      end

      it "should initialize @table" do
        instance.instance_variable_get("@table").should == subject::TABLE
      end
    end
  end
end
