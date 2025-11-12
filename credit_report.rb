require "json"

class CreditReport
    APPROVED_VENDORS = ["creditscore360"].freeze
  def initialize(data, vendor)
    @data = data
    unless APPROVED_VENDORS.include?(vendor)
      raise ArgumentError, "Vendor not supported"
    end
    @vendor = vendor
  end

  def get_report
    normalize_report
  end

  private

  def normalize_report
    parsed_data = parse_data
    credit_score_360_adapter(parsed_data) if @vendor == "creditscore360"
  end

  def parse_data
    begin
      JSON.parse(@data)
    rescue JSON::ParserError
      puts "not json"
    end
  end

  def credit_score_360_adapter(parsed_data)
    {
      "business_name": parsed_data["business_info"]["business_name"],
      "tax_id": parsed_data["business_info"]["tax_id"],
      "owner_name": parsed_data["business_info"]["owner"]["name"],
      "owner_ssn": parsed_data["business_info"]["owner"]["ssn"],
      "business_credit_score": parsed_data["credit_data"]["business_score"],
      "personal_credit_score": parse_data["credit_data"]["personal_score"],
      "report_date": parsed_data["credit_data"]["report_date"],
      "data_source": @vendor,
    }
  end
end
