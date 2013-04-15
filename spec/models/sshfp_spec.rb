require File.dirname(__FILE__) + '/../spec_helper'

# As described in RFC 4255 ( http://tools.ietf.org/html/rfc4255 ), an SSHFP
# record consists of three parts: an algorithm number, fingerprint type and the
# fingerprint of the public host key. Algorithms can be RSA (value: 1) or DSA
# (value: 2), there is currently only SHA-1 (value: 1) available as fingerprint
# type. A Fingerprint is hex number with 40 digits.

describe SSHFP do
  context "when new" do

    it "should be invalid by default" do
      subject.should_not be_valid
    end

    it "must accept a RSA key with a 40 digit hex SHA-1 fingerprint" do
      subject.content = '1 1 40ff0748d3c77616494546759a2095ecf13e6a3a'
      subject.should have(:no).errors_on(:content)
    end

    it "must accept a RSA key with a less than 40 digit hex SHA-1 fingerprint" do
      subject.content = '1 1 40ff0748d3c77616494546759a2095ecf13e6a3'
      subject.should have(1).error_on(:content)
    end

    it "must accept a RSA key with a more than 40 digit hex SHA-1 fingerprint" do
      subject.content = '1 1 40ff0748d3c77616494546759a2095ecf13e6a3a1'
      subject.should have(1).error_on(:content)
    end

    it "must accept a DSA key with a 40 digit hex SHA-1 fingerprint" do
      subject.content = '2 1 d6d934e46c1c0993ab861d3302abdd1e11682e0e'
      subject.should have(:no).errors_on(:content)
    end

    it "must not accept a DSA key with a less than 40 digit hex SHA-1 fingerprint" do
      subject.content = '2 1 d6d934e46c1c0993ab861d3302abdd1e11682e0'
      subject.should have(1).error_on(:content)
    end

    it "must not accept a DSA key with a more than 40 digit hex SHA-1 fingerprint" do
      subject.content = '2 1 d6d934e46c1c0993ab861d3302abdd1e11682e0e3'
      subject.should have(1).error_on(:content)
    end

    it "must not accept a key of type 0 (reserved)" do
      subject.content = '0 1 d6d934e46c1c0993ab861d3302abdd1e11682e0e'
      subject.should have(1).error_on(:content)
    end

    it "must not accept a key of type higher than 3 (undefined)" do
      subject.content = '4 1 d6d934e46c1c0993ab861d3302abdd1e11682e0e'
      subject.should have(1).error_on(:content)
    end

    it "must not accept a key with a fingerprint type 0 (reserved)" do
      subject.content = '1 0 d6d934e46c1c0993ab861d3302abdd1e11682e0e'
      subject.should have(1).error_on(:content)
    end

    it "must not accept a key with a fingerprint type higher than 2 (undefined)" do
      subject.content = '1 3 d6d934e46c1c0993ab861d3302abdd1e11682e0e'
      subject.should have(1).error_on(:content)
    end

    it "must not accept a key with a fingerprint consisting of non-hex digits" do
      subject.content = '1 0 d6d934e46c1c0993ab861d3302abdd1e11682e0Y'
      subject.should have(1).error_on(:content)
    end
  end
end
