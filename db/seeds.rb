Site.find_or_create_by!(name: "Aサイト") do |site|
  site.capacity    = 4
  site.price       = 5000
  site.description = "ファミリー、グループ用"
end

Site.find_or_create_by!(name: "Bサイト") do |site|
  site.capacity    = 4
  site.price       = 5000
  site.description = "ファミリー、グループ用"
end

Site.find_or_create_by!(name: "Cサイト") do |site|
  site.capacity    = 2
  site.price       = 3000
  site.description = "ソロ、デュオ用"
end

Site.find_or_create_by!(name: "Dサイト") do |site|
  site.capacity    = 2
  site.price       = 3000
  site.description = "ソロ、デュオ用"
end