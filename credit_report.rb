require "json"
require "nokogiri"
require "csv"

class CreditReport
  APPROVED_VENDORS = ["creditscore360", "bizcreditplus", "enterprisecreditdata"].freeze

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

    if @vendor == "creditscore360"
      credit_score_360_adapter(parsed_data)
    elsif @vendor == "bizcreditplus"
      bizcreditplus_adapter(parsed_data)
    else
      enterprisecreditdata_adapter(parsed_data)
    end
  end

  def parse_data
    begin
      return JSON.parse(@data)
    rescue JSON::ParserError
      xml_doc = Nokogiri::XML(@data)
      if xml_doc.root.nil? || (xml_doc.errors.any? && xml_doc.root.name == "parsererror")
        begin
          csv = CSV.parse(@data, headers: true)
          return csv
        rescue CSV::MalformedCSVError
          raise "Unsupported data format"
        end
      else
        return xml_doc
      end
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

  def bizcreditplus_adapter(parsed_data)
    {
      business_name: parsed_data.xpath("//business_info/business_name").text,
      tax_id: parsed_data.xpath("//business_info/tax_id").text,
      owner_name: parsed_data.xpath("//business_info/owner/name").text,
      owner_ssn: parsed_data.xpath("//business_info/owner/ssn").text,
      business_credit_score: parsed_data.xpath("//credit_data/business_score").text.to_i,
      personal_credit_score: parsed_data.xpath("//credit_data/personal_score").text.to_i,
      report_date: parsed_data.xpath("//credit_data/report_date").text,
      data_source: @vendor,
    }
  end

  def enterprisecreditdata_adapter(parsed_data)
    row = parsed_data.first.to_h
    {
      business_name: row["business_name"],
      tax_id: row["tax_id"],
      owner_name: row["owner_name"],
      owner_ssn: row["owner_ssn"],
      business_credit_score: row["business_score"].to_i,
      personal_credit_score: row["personal_score"].to_i,
      report_date: row["report_date"],
      data_source: @vendor,
    }
  end
end
