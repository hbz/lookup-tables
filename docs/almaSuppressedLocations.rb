#! /usr/bin/env ruby

require 'csv'

input_file       = ARGV.first or abort "Usage: #{$0} <TSV>"
output_directory = File.join(__dir__, '..', 'data', 'almaSuppressedLocations').freeze

unambiguous = true

INSTITUTION_CODE          = 'Institution Code'.freeze
LIBRARY_CODE              = 'Library Code'.freeze
LIBRARY_NAME              = 'Library Name'.freeze
LOCATION_CODE             = 'Location Code'.freeze
LOCATION_NAME             = 'Location Name'.freeze
SUPPRESSED_FROM_DISCOVERY = 'Suppressed from Discovery'.freeze
YES                       = 'Yes'.freeze

MEMBER_PREFIX = '49HBZ_'.freeze
SEPARATOR     = "\t".freeze
SUPPRESSED    = 'suppressed'.freeze

hash, select = Hash.new { |h, k| h[k] = Hash.new { |i, j| i[j] = [] } },
  ->(records) { records.select { |record| record[SUPPRESSED_FROM_DISCOVERY] == YES } }

CSV.foreach(input_file, 'rb:bom|utf-8', headers: true) { |record|
  hash[record[INSTITUTION_CODE]][record[LOCATION_CODE]] << record
}

hash.each { |institution_code, locations|
  member_code = institution_code.sub(MEMBER_PREFIX, '')
  output_file = File.join(output_directory, "#{member_code}.tsv")

  ambiguous_locations = {}

  if unambiguous && File.exist?(output_file)
    File.foreach(output_file, chomp: true) { |line|
      columns      = line.split(SEPARATOR)
      records      = locations[columns[1]]
      library_code = columns[0]

      # location and library in analytics?
      next if records.any? { |record| record[LIBRARY_CODE] == library_code }

      # - location not in analytics (deleted or currently no holdings)
      # - library not in analytics (deleted or currently no holdings)
      # - legacy location

      records << { SUPPRESSED_FROM_DISCOVERY => YES, LIBRARY_CODE => library_code }
    }
  end

  File.open(output_file, 'w') { |file|
    locations.sort.each { |location_code, records|
      suppressed = select[records]
      next if suppressed.empty?

      if unambiguous
        suppressed.map { |record| record[LIBRARY_CODE] }.sort.uniq.each { |library_code|
          file.puts [library_code, location_code, SUPPRESSED].join(SEPARATOR) }
      else
        ambiguous_locations[location_code] = records if suppressed.size != records.size
        file.puts [location_code, SUPPRESSED].join(SEPARATOR)
      end
    }
  }

  File.delete(output_file) unless File.size?(output_file)

  next if ambiguous_locations.empty?

  warn "#{member_code}:"

  ambiguous_locations.each { |location_code, records|
    warn "- #{location_code}:"

    records.sort_by { |record| record[LIBRARY_CODE] }.each { |record|
      warn '  - %s (%s) = %s (%s)' % record.values_at(
        LIBRARY_CODE, LIBRARY_NAME, SUPPRESSED_FROM_DISCOVERY, LOCATION_NAME)
    }
  }
}
