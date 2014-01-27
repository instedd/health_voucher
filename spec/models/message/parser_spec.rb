require 'spec_helper'

describe Message::Parser do
  before(:each) do
    @service1 = Service.make!
    @service2 = Service.make!
    @service3 = Service.make!
    @provider = Provider.make!
    @patient = Patient.make!
    @patient7 = Patient.make!(:agep_id_7)
    @card = Card.make!
    @voucher = Voucher.make!

    @s1 = @service1.code
    @s2 = @service2.code
    @s3 = @service3.code
    @pc = @provider.code
    @a10 = @patient.agep_id
    @a7 = @patient7.agep_id
    @sn = @card.full_serial_number
    @pin = @voucher.code
  end

  describe "token split" do
    it "should strip leading and trailing whitespace" do
      p = Message::Parser.new('  12*32  ')
      p.parse
      p.tokens.should eq(['12', '32'])
    end

    it "should accept either + or * as separator" do
      p = Message::Parser.new('12*34+56')
      p.parse
      p.tokens.should eq(['12', '34', '56'])
    end

    it "should strip whitespace between separators" do
      p = Message::Parser.new('12 *34+ 56 * 78')
      p.parse
      p.tokens.should eq(['12', '34', '56', '78'])
    end

    it "should ignore multiple consecutive separators" do
      p = Message::Parser.new('12**34++56+*78')
      p.parse
      p.tokens.should eq(['12', '34', '56', '78'])
    end
  end

  describe "parsing" do
    it "should recognize valid authorization messages" do
      ["#{@pc}*#{@a7}*#{@sn}*#{@s1}",
       "#{@pc}*#{@a10}*#{@sn}*#{@s1}",
       "#{@pc}*#{@a10}*#{@sn}*#{@s1}*#{@s2}",
       "#{@pc}*#{@a7}*#{@sn}*#{@s1}*#{@s2}*#{@s3}"].each do |body|
        Message::Parser.new(body).parse.should eq(:authorization), "#{@body} should be a valid authorization"
      end
    end

    it "should recognize valid confirmation messages" do
      ["#{@s1}*#{@pin}"].each do |body|
        Message::Parser.new(body).parse.should eq(:confirmation), "#{body} should be a valid confirmation"
      end
    end

    it "should reject invalid messages" do
      ["3742", "abcde",
       "1*1", "12*1", "123*123456789012",
       "12*1234567", "123*1234567", "123*1234567890",
       "123*1234567*1234567", "123*1234567890*1234567",
       "123*1234567*1234567*1",
       "123*1234567*1234567*111",
       "123*1234567*1234567*11*222"].each do |body|
        Message::Parser.new(body).parse.should be_nil, "#{body} expected invalid"
      end
    end
  end

  describe "error messages conditions" do
    def parser_error(body)
      parser = Message::Parser.new(body)
      parser.parse.should be_nil, "#{body} expected invalid"
      parser.error
    end

    it "Non digit characters in fields" do
      parser_error("abc").should eq(:invalid_message)
      parser_error("374*abc").should eq(:invalid_message)
    end

    it "Missing 1st field separator" do
      parser_error("3742").should eq(:missing_separators)
      parser_error("#{@pc}").should eq(:missing_separators)
    end

    it "Provider code doesn't have exact 4 digits" do
      parser_error("3*4222332").should eq(:provider_invalid)
      # 2 digits and 2 tokens are interpreted as confirmation message
      parser_error("33*4222332*878879").should eq(:provider_invalid)
      parser_error("333*4222332").should eq(:provider_invalid)
      parser_error("33333*4222332").should eq(:provider_invalid)
    end

    it "Provider code not valid or disabled" do
      parser_error("0000*4222332").should eq(:provider_disabled)
      @provider.update_attribute :enabled, false
      parser_error("#{@pc}*4222332").should eq(:provider_disabled)
    end

    it "Missing 2nd field separator" do
      parser_error("#{@pc}*4222332").should eq(:missing_2nd_sep)
      parser_error("#{@pc}*#{@a7}").should eq(:missing_2nd_sep)
      parser_error("#{@pc}*#{@a10}").should eq(:missing_2nd_sep)
    end

    it "AGEP ID doesn't have exact 7 or 10 digits" do
      parser_error("#{@pc}*123456*0000000").should eq(:agep_id_invalid)
      parser_error("#{@pc}*12345678*0000000").should eq(:agep_id_invalid)
      parser_error("#{@pc}*123456789*0000000").should eq(:agep_id_invalid)
      parser_error("#{@pc}*12345678901*0000000").should eq(:agep_id_invalid)
    end

    it "AGEP ID don't exist in database" do
      parser_error("#{@pc}*1234567*0000000").should eq(:agep_id_not_exists)
      parser_error("#{@pc}*1234567890*0000000").should eq(:agep_id_not_exists)
    end

    it "Missing 3erd field separator" do
      parser_error("#{@pc}*#{@a7}*1234567").should eq(:missing_3rd_sep)
      parser_error("#{@pc}*#{@a10}*#{@sn}").should eq(:missing_3rd_sep)
    end

    it "Serial Number doesn't have exact 7digits" do
      parser_error("#{@pc}*#{@a7}*123456*11").should eq(:serial_number_invalid)
      parser_error("#{@pc}*#{@a7}*12345678*11").should eq(:serial_number_invalid)
    end

    it "Serial Number is invalid (CRC doesn't match)" do
      parser_error("#{@pc}*#{@a7}*0000100*11").should eq(:serial_number_crc_invalid)
    end

    it "Serial Number doesn't exists in database" do
      parser_error("#{@pc}*#{@a7}*7000100*11").should eq(:serial_number_not_exists)
    end

    it "Service Code is invalid" do
      parser_error("#{@pc}*#{@a7}*#{@sn}*1").should eq(:service_code_invalid)
      parser_error("#{@pc}*#{@a7}*#{@sn}*111").should eq(:service_code_invalid)
    end

    it "Any of Service Codes is invalid" do
      parser_error("#{@pc}*#{@a7}*#{@sn}*#{@s1}*1").should eq(:service_code_invalid)
      parser_error("#{@pc}*#{@a7}*#{@sn}*#{@s1}*001").should eq(:service_code_invalid)
    end

    it "Service Code invalid" do
      parser_error("01*#{@pin}").should eq(:service_code_invalid)
    end

    it "PIN code invalid" do
      parser_error("#{@s1}*12345678901").should eq(:voucher_code_invalid)
      parser_error("#{@s1}*1234567890123").should eq(:voucher_code_invalid)
    end

    it "PIN Code invalid (CRC doesn't match)" do
      parser_error("#{@s1}*123456789012").should eq(:voucher_code_crc_invalid)
    end

    it "PIN Code invalid (doesn't exists)" do
      parser_error("#{@s1}*123456789018").should eq(:voucher_code_not_exists)
    end
  end
end
