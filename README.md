# takarazuka-list-generator
宝塚歌劇団に在籍した人の一覧を作成するスクリプト。  
Wikipediaの「宝塚歌劇団n期生」というページを、1期生から存在しなくなるまでカウントアップして、CSVファイルに出力します。  
あくまでWikipedia情報なので、公式なものではありません。

出力されるCSVファイルの内容は、以下の形式です。  
|期|芸名|読み仮名|誕生日|出身地|出身校|芸名の由来|愛称|役柄|退団年|備考|

# How to use
Rubyが実行できる環境で、scraping.rbを実行するだけです。  
$ ruby scraping.rb
