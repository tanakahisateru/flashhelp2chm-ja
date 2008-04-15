
目的
  Flex3SDKのオンラインAPIドキュメントをWindowsのHTML Helpに変換する。
  Adobe Livedocsサーバは高負荷になるときわめてレスポンスが悪化し、誤ったコンテンツを
  配信するので、Flex3リファレンスのページスナップショットをローカル保存して使用する。

必要環境
  Windows
  Ruby
  HTML Help Workshop

手順
0.不具合ファイルの代替を事前に準備しておく
  Flex2のオンラインドキュメント
  http://livedocs.adobe.com/flex/2_jp/langref/migration.html
  を、ローカルの
  langref/migration.html
  に事前に保存しておく。

  mkdir langref
  wget -P langref http://livedocs.adobe.com/flex/2_jp/langref/migration.html

  === 注：重要 ===
  2008/4/15現在、オンラインドキュメントの
  http://livedocs.adobe.com/flex/3_jp/langref/migration.html
  は壊れている。この壊れたHTMLは、
  
  * 存在しないページへのリンクが大量にあり、クローラを邪魔する。
  * あまりにも誤った記述のために、HtmlHelpコンパイラをクラッシュさせてしまう。
  
  という問題を起こす。

1.Livedocsサーバを走査してコンテンツを網羅的に取得する
  ruby download.rb livedocs.adobe.com /flex/3_jp/langref index.html langref

  この処理はHTMLページからリンクらしきものをパターン検索してクロールする。
  この処理をCtrl+Cで中断しても、次回再開したとき、ローカルに取得済み、
  および、デッドリンクとわかっているURLはスキップする。

  === 注：重要 ===
  サーバが誤ったコンテンツを返したり、特定のドキュメントで急に応答が悪化する
  ことがあるので、Livedocsサーバの調子が悪いときは中止し、しばらく待ってから
  再開しよう。サーバが混雑していると調子が悪いかもしれないが、サーバにもっとも
  負荷をかけているのは自分だということを認識し、普通に閲覧しているユーザに
  道を譲ろう。

2.文字エンコーディングをShiftJISに変換しつつ、オフライン用に変換してhtmlにコピーしてくる
  ruby preprocess-ja.rb langref html

3.ドキュメントツリーを解析し、HTMLヘルププロジェクトに変換
  ruby createhhp-ja.rb flex3langref html "Adobe Flex 3 リファレンスガイド"

4.HTMLヘルププロジェクトをコンパイル
  "C:\Program Files\HTML Help Workshop\hhc.exe" flex3langref.hhp

ライセンス
  GPL扱い

作者
  田中久輝 tanakahisateru@gmail.com
