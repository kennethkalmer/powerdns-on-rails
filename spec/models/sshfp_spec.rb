require File.dirname(__FILE__) + '/../spec_helper'

# As described in RFC 4255 ( http://tools.ietf.org/html/rfc4255 ), an SSHFP
# record consists of three parts: an algorithm number, fingerprint type and the
# fingerprint of the public host key. Algorithms can be RSA (value: 1) or DSA
# (value: 2), there is currently only SHA-1 (value: 1) available as fingerprint
# type. A Fingerprint is hex number with 40 digits.

describe SSHFP, "when new" do
  before(:each) do
    @sshfp = SSHFP.new
  end

  it "should be invalid by default" do
    @sshfp.should_not be_valid
  end
  
  it "must accept a RSA key with a 40 digit hex SHA-1 fingerprint" do
    @sshfp.content = '1 1 40ff0748d3c77616494546759a2095ecf13e6a3a'
    @sshfp.should have(:no).errors_on(:content)
  end

  it "must accept a RSA key with a less than 40 digit hex SHA-1 fingerprint" do
    @sshfp.content = '1 1 40ff0748d3c77616494546759a2095ecf13e6a3'
    @sshfp.should have(1).error_on(:content)
  end

  it "must accept a RSA key with a more than 40 digit hex SHA-1 fingerprint" do
    @sshfp.content = '1 1 40ff0748d3c77616494546759a2095ecf13e6a3a1'
    @sshfp.should have(1).error_on(:content)
  end

  it "must accept a DSA key with a 40 digit hex SHA-1 fingerprint" do
    @sshfp.content = '2 1 d6d934e46c1c0993ab861d3302abdd1e11682e0e'
    @sshfp.should have(:no).errors_on(:content)
  end

  it "must not accept a DSA key with a less than 40 digit hex SHA-1 fingerprint" do
    @sshfp.content = '2 1 d6d934e46c1c0993ab861d3302abdd1e11682e0'
    @sshfp.should have(1).error_on(:content)
  end

  it "must not accept a DSA key with a more than 40 digit hex SHA-1 fingerprint" do
    @sshfp.content = '2 1 d6d934e46c1c0993ab861d3302abdd1e11682e0e3'
    @sshfp.should have(1).error_on(:content)
  end

  it "must not accept a key of type 0 (reserved)" do
    @sshfp.content = '0 1 d6d934e46c1c0993ab861d3302abdd1e11682e0e'
    @sshfp.should have(1).error_on(:content)
  end

  it "must not accept a key of type higher than 2 (undefined)" do
    @sshfp.content = '3 1 d6d934e46c1c0993ab861d3302abdd1e11682e0e'
    @sshfp.should have(1).error_on(:content)
  end

  it "must not accept a key with a fingerprint type 0 (reserved)" do
    @sshfp.content = '1 0 d6d934e46c1c0993ab861d3302abdd1e11682e0e'
    @sshfp.should have(1).error_on(:content)
  end

  it "must not accept a key with a fingerprint type higher than 1 (undefined)" do
    @sshfp.content = '1 2 d6d934e46c1c0993ab861d3302abdd1e11682e0e'
    @sshfp.should have(1).error_on(:content)
  end

  it "must not accept a key with a fingerprint consisting of non-hex digits" do
    @sshfp.content = '1 0 d6d934e46c1c0993ab861d3302abdd1e11682e0Y'
    @sshfp.should have(1).error_on(:content)
  end
end
