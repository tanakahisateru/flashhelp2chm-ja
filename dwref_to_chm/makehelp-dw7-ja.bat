echo off
mkdir dw7
ruby preprocess-ja.rb "C:\Program Files\Macromedia\Dreamweaver MX 2004\Configuration\Content\Reference\HTML" ./dw7/HTML
ruby preprocess-ja.rb "C:\Program Files\Macromedia\Dreamweaver MX 2004\Configuration\Content\Reference\CSS" ./dw7/CSS
ruby preprocess-ja.rb "C:\Program Files\Macromedia\Dreamweaver MX 2004\Configuration\Content\Reference\JavaScript" ./dw7/JavaScript
copy /Y josh.css .\dw7\HTML
copy /Y josh.css .\dw7\CSS
copy /Y josh.css .\dw7\JavaScript
rem --この修正を強制的に検索置換で行った--
rem echo .\dw7\JavaScript\Reference.xmlには致命的な問題があるので修正してください
rem echo XML書式の破損 /book/topic/subtopic(name="frame")
rem echo XML書式の破損 /book/topic/subtopic(name="rules")
rem pause
rem echo 本当にできましたか
rem pause
ruby createhhp-ja.rb dwref7 dw7 "Macromedia Dreamweaver MX 2004 リファレンスパネル"
"C:\Program Files\HTML Help Workshop\hhc.exe" dwref7.hhp
