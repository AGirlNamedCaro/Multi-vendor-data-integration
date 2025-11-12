require_relative "test_helper"
require_relative "../credit_report"
require "json"
$stdout.sync = true

class CreditReportTest < Minitest::Test
  def test_parses_complete_valid_json
    data = File.read("test/fixtures/credit_report.json")
    normalized_report = CreditReport.new(data, "creditscore360").get_report
    assert_equal "Joe's Pizza LLC", normalized_report[:business_name]
    assert_equal "12-3456789", normalized_report[:tax_id]
    assert_equal "Joseph Smith", normalized_report[:owner_name]
    assert_equal "123-45-6789", normalized_report[:owner_ssn]
    assert_equal 720, normalized_report[:business_credit_score]
    assert_equal 680, normalized_report[:personal_credit_score]
    assert_equal "2025-01-15", normalized_report[:report_date]
    assert_equal "creditscore360", normalized_report[:data_source]
  end

  def test_parses_complete_valid_xml
    data = File.read("test/fixtures/credit_report.xml")
    normalized_report = CreditReport.new(data, "bizcreditplus").get_report
    assert_equal "Joe's Pizza LLC", normalized_report[:business_name]
    assert_equal "12-3456789", normalized_report[:tax_id]
    assert_equal "Joseph Smith", normalized_report[:owner_name]
    assert_equal "123-45-6789", normalized_report[:owner_ssn]
    assert_equal 720, normalized_report[:business_credit_score]
    assert_equal 680, normalized_report[:personal_credit_score]
    assert_equal "2025-01-15", normalized_report[:report_date]
    assert_equal "bizcreditplus", normalized_report[:data_source]
  end

  def test_parses_complete_valid_csv
    data = File.read("test/fixtures/credit_report.csv")
    normalized_report = CreditReport.new(data, "enterprisecreditdata").get_report
    assert_equal "Joe's Pizza LLC", normalized_report[:business_name]
    assert_equal "12-3456789", normalized_report[:tax_id]
    assert_equal "Joseph Smith", normalized_report[:owner_name]
    assert_equal "123-45-6789", normalized_report[:owner_ssn]
    assert_equal 720, normalized_report[:business_credit_score]
    assert_equal 680, normalized_report[:personal_credit_score]
    assert_equal "2025-01-15", normalized_report[:report_date]
    assert_equal "enterprisecreditdata", normalized_report[:data_source]
  end
end
