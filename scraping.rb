require 'open-uri'
require 'rexml/document'
require 'kconv'

# 出力ファイル名
OUTPUT = "members.csv"

# MediaWiki API
URI1 = "https://ja.wikipedia.org/w/api.php?action=query&titles=%E5%AE%9D%E5%A1%9A%E6%AD%8C%E5%8A%87%E5%9B%A3"
URI2 = "%E6%9C%9F%E7%94%9F&prop=revisions&rvprop=content&format=xml"

# wikitableの記号
START_TAG = "{|"
END_TAG = "|}"
TR_TAG = "|-"
TD_TAG = "|"
CAPTION = "|+"
HEADER = "!"

# 出力項目数
ITEM_NO = 10

# リンクなどを削除して、出力要素を取り出す
# @param [String] contentsの1行
# @return [String] 1セルの要素
def cutOutTd(msg)
  delRegexps = Array[
  /\[\[[^\]]+\|/,
  /\{\{.*\}\}/,
  /<ref.*\/>/,
  /<ref.*>.*<\/ref>/,
  /\[\[/,
  /\]\]/,
  /<!--.*-->/]
  delRegexps.each {|regexp|
    msg = msg.gsub(regexp,'')
  }
  td = msg.rpartition(TD_TAG)
  return td[td.length-1].chomp.strip
end

# 出力ファイルの初期化
if File.exist?(OUTPUT)
  File.delete(OUTPUT)
end

existPage = true
count = 0
class_no = ""
wikitable = false

while existPage
  count += 1
  if count == 7
    # 7・8期生対応
    class_no = "7%E3%83%BB8"
  else
    class_no = count.to_s
  end

  doc = REXML::Document.new(open(URI1 + class_no + URI2))
  idx = doc.elements['api/query/pages/page'].attributes["_idx"]
  if idx.to_i < 0
    existPage = false
    break
  end
  contents = doc.elements['api/query/pages/page/revisions/rev'].text
  column_no = 0
  pre_line = nil
  File.open(OUTPUT, "a") do |file|
    contents.lines {|line|

      # 要素の判定に邪魔になるので、行頭、行末の空白を削除
      trimmed_line = line.chomp.gsub(/^[\s　]+|[\s　]+$/,'')

      # テーブルの開始、終了を判定
      if trimmed_line.start_with?(START_TAG)
        wikitable = true
      end
      if trimmed_line.end_with?(END_TAG)
        wikitable = false
      end

      # テーブル内容の出力
      if wikitable
        if trimmed_line.end_with?(TR_TAG)
          if pre_line != nil && !(pre_line.start_with?(HEADER, START_TAG, TR_TAG))
            file.printf("\n")
            column_no = 0
          end
        elsif trimmed_line.start_with?(CAPTION)
          # タイトル行を読み飛ばし
        elsif trimmed_line.start_with?(TD_TAG)
          td = cutOutTd(line)
          if column_no == 0
            # 1つ目の項目として、期の数を出力する
            file.print("\"")
            file.print(count)
            file.print("\",")
          end
          file.print("\"")
          file.print(td)
          file.print("\"")
          unless column_no >= ITEM_NO - 1
            file.print(",")
            column_no += 1
          end
        end
      end
      pre_line = trimmed_line
    }
  end
end
