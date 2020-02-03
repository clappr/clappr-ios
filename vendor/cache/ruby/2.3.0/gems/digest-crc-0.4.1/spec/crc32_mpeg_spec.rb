require 'spec_helper'
require 'crc_examples'
require 'digest/crc32_mpeg'

describe Digest::CRC32Mpeg do
  let(:string)   { '1234567890' }
  let(:expected) { 'af97ac49' }

  it_should_behave_like "CRC"
end
