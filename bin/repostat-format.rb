#!/usr/bin/ruby
#

require 'json'

class Colorizator
  COLOURS    = {default:    '38', black: '30', red: '31', green: '32', brown: '33', blue: '34', purple: '35',
                cyan:       '36', gray: '37', dark_gray: '1;30', light_red: '1;31', light_green: '1;32', yellow: '1;33',
                light_blue: '1;34', light_purple: '1;35', light_cyan: '1;36', white: '1;37'}.freeze
  BG_COLOURS = {default: '0', black: '40', red: '41', green: '42', brown: '43', blue: '44',
                purple:  '45', cyan: '46', gray: '47', dark_gray: '100', light_red: '101', light_green: '102',
                yellow:  '103', light_blue: '104', light_purple: '105', light_cyan: '106', white: '107'}.freeze

  FONT_OPTIONS = {bold: '1', dim: '2', italic: '3', underline: '4', reverse: '7', hidden: '8'}.freeze

  def self.colorize(text, colour = :default, bg_colour = :default, **options)
    colour_code    = COLOURS[colour]
    bg_colour_code = BG_COLOURS[bg_colour]
    font_options   = options.select { |k, v| v && FONT_OPTIONS.key?(k) }.keys
    font_options   = font_options.map { |e| FONT_OPTIONS[e] }.join(';').squeeze
    return "\e[#{bg_colour_code};#{font_options};#{colour_code}m#{text}\e[0m".squeeze(';')
  end
end

json = JSON.load(ARGF.read)
json.insert(0, {
    'type'        => 'header',
    'branch'      => 'Branch', 'age' => 'Age',
    'aheadOrigin' => 'orgn+', 'behindOrigin' => 'orgn-',
    'aheadSync'   => 'trgt+', 'behindSync' => 'trgt-',
    'fix'         => ''.ljust(70)
})

def column_width(list, colname)
  return list.map { |row| row[colname]&.to_s&.length || 0 }.max
end

widths = {
    :branch       => column_width(json, 'branch'),
    :age          => column_width(json, 'age'),
    :aheadOrigin  => column_width(json, 'aheadOrigin'),
    :behindOrigin => column_width(json, 'behindOrigin'),
    :aheadSync    => column_width(json, 'aheadSync'),
    :behindSync   => column_width(json, 'behindSync'),
    :fix          => column_width(json, 'fix'),

}

# format = "%%-%ds | %%%ds | %%%ds | %%%ds | %%%ds | %%%ds | %%-%ds " % [branch, age, aheadOrigin, behindOrigin, aheadSync, behindSync, fix]

def print_row(row, widths)
  r = ''
  r += (row['fix'] || '').ljust(widths[:fix]) + Colorizator.colorize('    # ', :black)
  r += (row['branch'].to_s || '').ljust(widths[:branch]) + Colorizator.colorize(' | ', :black)
  r += (row['age'] || '').rjust(widths[:age]) + Colorizator.colorize(' | ', :black)
  r += Colorizator.colorize((row['aheadOrigin']&.to_s || '').rjust(widths[:aheadOrigin]), :green, :default, bold: (row['aheadOrigin'] != 0)) + Colorizator.colorize(' | ', :black)
  r += Colorizator.colorize((row['behindOrigin']&.to_s || '').rjust(widths[:behindOrigin]), :red, :default, bold: (row['behindOrigin'] != 0)) + Colorizator.colorize(' | ', :black)
  r += Colorizator.colorize((row['aheadSync']&.to_s || '').rjust(widths[:aheadSync]), :green, :default, bold: (row['aheadSync'] != 0)) + Colorizator.colorize(' | ', :black)
  r += Colorizator.colorize((row['behindSync']&.to_s || '').rjust(widths[:behindSync]), :red, :default, bold: (row['behindSync'] != 0)) + Colorizator.colorize(' | ', :black)
  puts r
end

def print_type(json, header, type, widths)
  if json.find_all { |row| row['type'] == type }.size > 0
    if header != ''
      puts ''
      h = ''.ljust(widths[:fix]) + Colorizator.colorize('    # ', :black)
      h += Colorizator.colorize(header, :white, :default, bold: true)
      puts h
    end
    json.find_all { |row| row['type'] == type }
        .each { |row| print_row(row, widths) }
  end
end

print_type(json, '', 'header', widths)
print_type(json, 'Local', 'local', widths)
print_type(json, 'Remote', 'remote', widths)
print_type(json, 'Tracked', 'synced', widths)
