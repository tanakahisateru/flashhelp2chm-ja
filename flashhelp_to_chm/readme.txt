
目的
  FlashのヘルプパネルをWindowsのHTML Helpに変換する。
  技術Q&AのためにFlashを起動するのが面倒。
  WebサイトのリファレンスもFlashのヘルプパネルも、全般的に重い。

必要環境
  Windows
  Ruby
  HTML Help Workshop

手順
1.文字エンコーディングをShiftJISに変換しつつ、htmlフォルダにコピーする
  ruby preprocess-ja.rb <FlashのHelpPanelフォルダのパス> html

  FlashのHelpPanelフォルダのパスはデフォルトで以下の場所にある。
  Flash8:
  C:\Documents and Settings\All Users\Application Data\Macromedia\Flash 8\ja\Configuration\HelpPanel
  Flash CS3:
  C:\Documents and Settings\All Users\Application Data\Adobe\Flash CS3\ja\Configuration\HelpPanel

2.オプション：不要なドキュメントセットを除外する
  もし不要なドキュメントセットがある場合、変換コピーしたhtmlフォルダ内の不要フォルダを削除してもかまわない。
  FlashLiteのドキュメントは不要、AS3関連のみ、など、用途に応じて構成物を除外することができる。

3.ドキュメントツリーを解析し、HTMLヘルププロジェクトに変換

  Flash8:
  ruby createhhp-ja.rb  flashhelp8 html "Macromedia Flash8 ヘルプ"
  Flash CS3:
  ruby createhhp-ja.rb  flashhelp_cs3 html "Adobe Flash CS3 ヘルプ"

4.HTMLヘルププロジェクトをコンパイル
  "C:\Program Files\HTML Help Workshop\hhc.exe" flashhelp8.hhp

ライセンス
  GPL扱い

作者
  田中久輝 htanaka@loop-net.co.jp
