class Api::ImportsController < ApplicationController
  def create
    json_data = parse_json_data
    service = RestaurantImportService.new(json_data)
    result = service.import

    if result[:success]
      render json: result, status: :created
    else
      render json: result, status: :unprocessable_entity
    end
  rescue JSON::ParserError => e
    Rails.logger.debug "JSON ParserError caught: #{e.message}"
    render json: {
      success: false,
      error: "Invalid JSON format",
      logs: [ { level: "error", message: "JSON parsing failed: #{e.message}", timestamp: Time.current } ]
    }, status: :bad_request
  rescue ArgumentError => e
    render json: {
      success: false,
      error: "Invalid request: #{e.message}",
      logs: [ { level: "error", message: "Request error: #{e.message}", timestamp: Time.current } ]
    }, status: :bad_request
  rescue => e
    render json: {
      success: false,
      error: "Import failed: #{e.message}",
      logs: [ { level: "error", message: "Unexpected error: #{e.message}", timestamp: Time.current } ]
    }, status: :internal_server_error
  end

  private

  def parse_json_data
    json_string = extract_json_string
    parse_json_string(json_string)
  end

  def extract_json_string
    if params[:file].present?
      params[:file].read
    elsif params[:json_data].present?
      params[:json_data].to_s
    elsif request.content_type&.include?("application/json")
      request.body.read
    else
      raise ArgumentError, "No JSON data provided"
    end
  end

  def parse_json_string(json_string)
    raise ArgumentError, "Empty JSON data" if json_string.blank?

    begin
      JSON.parse(json_string)
    rescue JSON::ParserError
      raise JSON::ParserError, "Invalid JSON format"
    end
  end

  def is_json?(string)
    begin
      JSON.parse(string)
      true # If parsing succeeds, it's valid JSON
    rescue JSON::ParserError, TypeError
      false # If parsing fails, it's not valid JSON
    end
  end
end
