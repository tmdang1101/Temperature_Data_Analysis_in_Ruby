require 'csv'

def do_thing(filename)
  '''
  compute the number and percentage of missing records for max temperature
  '''
  tmax_nil = 0
  tmax_ok = 0
  CSV.parse(File.read(filename), headers: true, converters: [:integer]) do |row|
    if row['TMAX'] == nil
      tmax_nil += 1
    else
      tmax_ok += 1
    end
  end
  puts "ok #{tmax_ok}, nil #{tmax_nil}, #{tmax_nil.to_f / (tmax_nil + tmax_ok)}"
end

def min_max_avg(filename)
  '''
  average min and max temperatures in the data
  '''
  total_max = 0
  num_max = 0
  total_min = 0
  num_min = 0
  CSV.parse(File.read(filename), headers: true, converters: [:integer]) do |row|
    if row['TMAX'] != nil
      num_max += 1
      total_max += row['TMAX']
    end
    if row['TMIN'] != nil
      num_min += 1
      total_min += row['TMIN']
    end
  end

  puts "max: #{num_max} #{total_max} #{total_max.to_f / num_max}"
  puts "min: #{num_min} #{total_min} #{total_min.to_f / num_min}"
end

def monthly_max(filename)
  '''
  max temperature each month
  '''
  data = Hash.new
  CSV.parse(File.read(filename), headers: true, converters: [:integer]) do |row|
    raw = row['DATE']
    tmax = row['TMAX']
    if raw != nil && tmax != nil
      month = raw.split('-')[1]
      if !data.has_key? month
        data[month] = tmax
      elsif tmax > data[month] 
        data[month] = tmax
      end
    end
  end
  puts data
  #puts data.sort_by { |month, tmax| month }
  data.sort_by { |month, tmax| month }.each do |month, tmax| 
    puts "#{month} #{tmax}"
  end
end

def monthly_min(filename)
  '''
  max temperature each month
  '''
  data = Hash.new
  CSV.parse(File.read(filename), headers: true, converters: [:integer]) do |row|
    raw = row['DATE']
    tmin = row['TMIN']
    if raw != nil && tmin != nil
      month = raw.split('-')[1]
      if !data.has_key? month
        data[month] = tmin
      elsif tmin < data[month] 
        data[month] = tmin
      end
    end
  end
  puts data
end

def avg_hottest_year(filename)
  '''
  by popular demand! avg hottest day of the year

  Also suggested by the class this year:
  * avg min/max by decade
  * largest gap between min and max by month
  * largest annual temperature gap by year
  * where are the missing records?
  '''
  data = Hash.new
  CSV.parse(File.read(filename), headers: true, converters: [:integer]) do |row|
    date = row['DATE']
    tmax = row['TMAX']
    # dates are of form:
    # 2001-01-07
    if date != nil && tmax != nil
      year = date.split('-')[0]
      if !data.has_key? year
        data[year] = [tmax]
      else
        data[year] << tmax
      end
    end
  end
  data.each do |year, temps| 
    avg = temps.sum / temps.length.to_f
    puts "#{year} #{avg}"
  end
end





#Q1
def avg_max_decade(filename)
  '''
  Average max temperatures by decade
  '''
  data = Hash.new
  CSV.parse(File.read(filename), headers: true, converters: [:integer]) do |row|
    date = row['DATE']
    tmax = row['TMAX']
    # dates are of form:
    # 2001-01-07
    if date != nil && tmax != nil
      decade = (date.split('-')[0].to_i-date.split('-')[0].to_i.modulo(10)).to_s + 's'
      if !data.has_key? decade
        data[decade] = [tmax]
      else
        data[decade] << tmax
      end
    end
  end
  data.each do |decade, temps| 
    avg = (temps.sum / temps.length.to_f).round(2)
    puts "#{avg}"
  end
end

def avg_min_decade(filename)
  '''
  Average min temperatures by decade
  '''
  data = Hash.new
  CSV.parse(File.read(filename), headers: true, converters: [:integer]) do |row|
    date = row['DATE']
    tmin = row['TMIN']
    # dates are of form:
    # 2001-01-07
    if date != nil && tmin != nil
      decade = (date.split('-')[0].to_i-date.split('-')[0].to_i.modulo(10)).to_s + 's'
      if !data.has_key? decade
        data[decade] = [tmin]
      else
        data[decade] << tmin
      end
    end
  end
  data.each do |decade, temps| 
    avg = (temps.sum / temps.length.to_f).round(2)
    puts "#{decade} #{avg}"
  end
end


#Q2
def largest_min_max_gap_by_month(filename)
  '''
  Largest gap between min and max by month
  '''
  data = Hash.new
  CSV.parse(File.read(filename), headers: true, converters: [:integer]) do |row|
    raw = row['DATE']
    tmax = row['TMAX']
    tmin = row['TMIN']
    if raw != nil && tmax != nil && tmin != nil
      month = raw.split('-')[1]
      if !data.has_key? month
        data[month] = tmax-tmin
      elsif tmax-tmin > data[month] 
        data[month] = tmax-tmin
      end
    end
  end
  data.sort_by { |month, gap| month }.each do |month, gap| 
    puts "#{month} #{gap}"
  end
end


#Q3
def largest_temp_gap_by_year(filename)
  '''
  The largest annual temperature gap by year (max temp all year - min temp all year)
  '''
  #record tmax
  data = Hash.new
  CSV.parse(File.read(filename), headers: true, converters: [:integer]) do |row|
    date = row['DATE']
    tmax = row['TMAX']
    # dates are of form:
    # 2001-01-07
    if date != nil && tmax != nil
      year = date.split('-')[0]
      if !data.has_key? year
        data[year] = tmax
      elsif tmax > data[year]
        data[year] = tmax
      end
    end
  end

  #record tmin
  data2 = Hash.new
  CSV.parse(File.read(filename), headers: true, converters: [:integer]) do |row|
    date = row['DATE']
    tmin = row['TMIN']
    # dates are of form:
    # 2001-01-07
    if date != nil && tmin != nil
      year = date.split('-')[0]
      if !data2.has_key? year
        data2[year] = tmin
      elsif tmin < data[year]
        data2[year] = tmin
      end
    end
  end


  data.sort_by { |year, temp| year }.each do |year, temp| 
    gap = temp-data2[year]
    puts "#{year} #{gap}"
  end
end


#Q4
def daily_min_max_gap_by_year(filename)
  '''
  The largest daily temperature gap by year
  '''
  data = Hash.new
  CSV.parse(File.read(filename), headers: true, converters: [:integer]) do |row|
    raw = row['DATE']
    tmax = row['TMAX']
    tmin = row['TMIN']
    if raw != nil && tmax != nil && tmin != nil
      year = raw.split('-')[0]
      if !data.has_key? year
        data[year] = tmax-tmin
      elsif tmax-tmin > data[year] 
        data[year] = tmax-tmin
      end
    end
  end


  data.each do |year, gap| 
    puts "#{year} #{gap}"
  end
end


#Q5
def snow_missing_records_by_month(filename)
  '''
  Missing Records
  '''
  data = Hash.new
  CSV.parse(File.read(filename), headers: true, converters: [:integer]) do |row|
    raw = row['DATE']
    if row['SNWD'] == nil
      month = raw.split('-')[1]
      if !data.has_key? month
        data[month] = 1
      else 
        data[month] += 1
      end
    end
  end
  data.sort_by { |month, mssing| month }.each do |month, missing| 
    puts "#{missing}"
  end
  
  sum = 0
  data.each do |month, missing| 
    sum += missing
  end
  puts sum
end


#Q6
def snow_and_snowdepth_by_month(filename)
  '''
  Snow and Snow Depth Correlation - Chicago and Galesburg:
  '''
  snow_data = Hash.new
  CSV.parse(File.read(filename), headers: true, converters: [:integer]) do |row|
    date = row['DATE']
    snow = row['SNOW'].to_f
    # dates are of form:
    # 2001-01-07
    if date != nil && snow != nil
      year = date.split('-')[0]
      if !snow_data.has_key? year
        snow_data[year] = [snow]
      else
        snow_data[year] << snow
      end
    end
  end


  snowdepth_data = Hash.new
  CSV.parse(File.read(filename), headers: true, converters: [:integer]) do |row|
    date = row['DATE']
    snowdepth = row['SNWD'].to_f
    # dates are of form:
    # 2001-01-07
    if date != nil && snowdepth != nil
      year = date.split('-')[0]
      if !snowdepth_data.has_key? year
        snowdepth_data[year] = [snowdepth]
      else
        snowdepth_data[year] << snowdepth
      end
    end
  end


  snow_data.sort_by { |year, temp| year }.each do |year, snow| 
    avg_snow = (snow.sum / snow.length.to_f).round(2)
    avg_snowdepth = (snowdepth_data[year].sum / snowdepth_data[year].length.to_f).round(2)
    puts "#{year} #{avg_snow} #{avg_snowdepth}"
  end
end

#filename = 'chicago.csv'
filename = 'galesburg.csv'
#filename = 'hanoi.csv'

#do_thing(filename)
#min_max_avg(filename)
#monthly_max(filename)
#monthly_min(filename)
#avg_hottest_year(filename)



#Q1
#avg_max_decade(filename)
#avg_min_decade(filename)

#Q2
#largest_min_max_gap_by_month(filename)

#Q3
#largest_temp_gap_by_year(filename)

#Q4
#daily_min_max_gap_by_year(filename)

#Q5
snow_missing_records_by_month(filename)

#Q6
#snow_and_snowdepth_by_month(filename)