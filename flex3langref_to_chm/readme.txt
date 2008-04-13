
目的
  Flex2SDKのAPIドキュメントをWindowsのHTML Helpに変換する。
  Flex2BuilderもWebブラウザも、ともにAPI参照時の動作が重い。

必要環境
  Windows
  Ruby
  HTML Help Workshop

手順
1.文字エンコーディングをShiftJISに変換しつつ、htmlにコピーしてくる
  ruby preprocess-ja.rb [Flex2SDK日本語ドキュメント内のlangrefフォルダ] html

  ※このとき、日本語訳の過不足のせいで閲覧時にバグが含まれている箇所にパッチを当てる。

2.日本語ドキュメントにはサンプルswfが不足しているので、サンプルswfを英語ドキュメントからインポート
  これはオプションなので、かならずしも行う必要はない。
  ruby importexamples.rb [Flex2SDK英語ドキュメント内のlangrefフォルダ] html

3.ドキュメントツリーを解析し、HTMLヘルププロジェクトに変換
  ruby createhhp-ja.rb flex2langref html

4.HTMLヘルププロジェクトをコンパイル
  "C:\Program Files\HTML Help Workshop\hhc.exe" flex2langref.hhp

ライセンス
  GPL扱い

作者
  田中久輝 tanakahisateru@gmail.com
