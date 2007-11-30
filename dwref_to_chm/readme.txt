
目的
  DreamweaverのリファレンスパネルをWindowsのHTML Helpに変換する。
  Dreamweaverを起動するのが面倒。
  リファレンスパネルは遅すぎて役に立たない。

必要環境
  Windows
  Ruby
  HTML Help Workshop

手順
1.コンテンツにアンカータグを挿入しながら、htmlフォルダにコピーする
  ruby preprocess-ja.rb [リファレンスパネルコンテンツのパス] html/[コンテンツ]

まれにコンテンツの文字コードが誤認識されて文字化けが起こるので、
可能であれば、すべてのHTMLにmetaタグによるcharset指定をしておく

2.html以下にコピーした各コンテンツフォルダにjosh.cssをコピー

3.JavaScript/Reference.xmlには致命的な問題があるので手作業で修正

	修正前
	<subtopic name="frame<table cellpadding="0" cellspacing="0" border="0" width="100%" class="main" id="frame<table cellpadding="0" cellspacing="0" border="0" width="100%" class="main"/>
	<subtopic name="rules<table cellpadding="0" cellspacing="0" border="0" width="100%" class="main" id="rules<table cellpadding="0" cellspacing="0" border="0" width="100%" class="main"/>

	修正後
	<subtopic name="frame" id="frame"/>
	<subtopic name="rules" id="rules"/>

ほか、行っておいたほうがよい修正
	禁止記号URIを避けるため、IDに記号を使う要素をまるごと削除しておくのが安全
	<topic name="Operators" location="Operators.html" id="="> ... </topic>
	<subtopic name="$1、...、$9" id="$1,...,$9"/>

	マルチバイトURIを避けるため、サブトピックレベルにid="説明"が登場するのを避ける
	（これはMacromediaのローカライズ作業中に混入したバグ）
	<subtopic name="description" id="説明"/>
	<subtopic name="description" id="description"/>

	可能であれば、対応するHTMLにあるアンカーを修正する

4.ドキュメントツリーを解析し、HTMLヘルププロジェクトに変換
  ruby createhhp-ja.rb html

5.HTMLヘルププロジェクトをコンパイル
  "C:\Program Files\HTML Help Workshop\hhc.exe" dwref.hhp

ライセンス
  GPL扱い

作者
  田中久輝 htanaka@loop-net.co.jp
