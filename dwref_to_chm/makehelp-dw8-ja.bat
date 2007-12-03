echo off
mkdir dw8
ruby preprocess-ja.rb "C:\Program Files\Macromedia\Dreamweaver 8\Configuration\Content\Reference\HTML" ./dw8/HTML
ruby preprocess-ja.rb "C:\Program Files\Macromedia\Dreamweaver 8\Configuration\Content\Reference\CSS" ./dw8/CSS
ruby preprocess-ja.rb "C:\Program Files\Macromedia\Dreamweaver 8\Configuration\Content\Reference\JavaScript" ./dw8/JavaScript
copy /Y josh.css .\dw8\HTML
copy /Y josh.css .\dw8\CSS
copy /Y josh.css .\dw8\JavaScript
rem --この修正を強制的に検索置換で行った--
rem echo .\dw8\JavaScript\Reference.xmlには致命的な問題があるので修正してください
rem echo XML書式の破損 /book/topic/subtopic(name="frame")
rem echo XML書式の破損 /book/topic/subtopic(name="rules")
rem pause
rem echo 本当にできましたか
rem pause
ruby createhhp-ja.rb dwref8 dw8 "Macromedia Dreamweaver8 リファレンスパネル"
"C:\Program Files\HTML Help Workshop\hhc.exe" dwref8.hhp
