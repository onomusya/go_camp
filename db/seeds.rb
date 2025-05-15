# ── サイト登録 ──
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


# ── アイテム登録 ──
items = [
  # レンタル品
  { name: "テント",     item_type: :rental, price: 2000 },
  { name: "タープ",     item_type: :rental, price: 1000 },
  { name: "コット",     item_type: :rental, price: 1000 },
  { name: "マット",     item_type: :rental, price: 1000 },
  { name: "寝袋",       item_type: :rental, price: 1000 },
  { name: "焚き火台",   item_type: :rental, price:  800 },
  { name: "BBQセット",  item_type: :rental, price: 2000 },
  { name: "テーブル",   item_type: :rental, price:  800 },
  { name: "チェア",     item_type: :rental, price:  500 },

  # 販売品
  { name: "薪（1束）",      item_type: :sale, price: 800 },
  { name: "炭（1kg）",      item_type: :sale, price: 600 },
  { name: "マシュマロ",     item_type: :sale, price: 300 },
  { name: "スナック菓子",   item_type: :sale, price: 300 },
  { name: "水",            item_type: :sale, price: 200 },
  { name: "着火剤",         item_type: :sale, price: 200 }
]

items.each do |attrs|
  Item.find_or_create_by!(name: attrs[:name]) do |item|
    item.item_type = attrs[:item_type]
    item.price     = attrs[:price]
  end
end